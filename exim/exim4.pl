# vim: filetype=perl

do '/etc/exim4/trustlist.conf.pl';
use constant SENDERS_WHITELIST => "/etc/exim4/white_senders.list";

sub str2bool {
  my $txt = shift ;
  return ( lc ("$txt") eq 'true' )? 1 : 0 ;
}

# Realiza una consulta al a DB PostgreSQL y retorna el resultado
# que debe encontrarse en la primer fila / primera columna.
# Si la conexion a la DB falla o el resultado es vacio, retorna el valor por defecto.
# @param Query : la consulta a realizar
# @param Default: Valor a retornar en caso de falla
sub querySQL {
  my $query = shift ;
  my $default = shift ;

  use DBI ;
  use DBD::Pg ;
  my $dbh = DBI->connect(
       "dbi:Pg:dbname=db_tq;host=psql.terminalquequen.com.ar",
       'pg_tq','imaginacion') ;
  if ( $dbh eq ''  ) {
    print( "\nError conectando... Se retorna Default:$default\n" ) ;
    return "$default" ;
  } else {
    my $sth = $dbh->prepare( $query ) ;
    $sth->execute();
    @row = $sth->fetchrow_array;
    $default = $row[0] if ( $row[0] ne '' ) ;
    $sth->finish() ;
    my $rc = $dbh->disconnect() ;
  }
  return $default ;
}


sub InsertTrustlistTuple {
  use Unicode::MapUTF8 qw(to_utf8 from_utf8);

  my @rcptlist = split(/\s*;;@;;\s*/,shift) ;
  my $h_from = shift ;
  $h_from = to_utf8({ -string => $h_from, -charset => 'ISO-8859-1' });

  Exim::log_write( "Trustlist: From:  $h_from To_list: @rcptlist" ) ;
  foreach $rcptto (@rcptlist) {
    if ($rcptto and ($rcptto ne $h_from)) {
      my $mTRUST = "'".$TRUST."'" if ( $TRUST ne 'DEFAULT' ) ;
      my $mOPEN = "'".$OPEN."'" if ( $OPEN ne 'DEFAULT' ) ;
      my $mLACK = "'".$LACK."'" if ( $LACK ne 'DEFAULT' ) ;
      my $mCOEF = "'".$COEF."'" if ( $COEF ne 'DEFAULT' ) ;
      my $mCOUNT = "'".$COUNT."'" if ( $COUNT ne 'DEFAULT' ) ;
#      my $query = 'INSERT INTO trustlist.v_control ("user","from",lack_time,'.
#                           'opened_time,trust_time,coef_grey_window,count_threshold)'.
#			                    'VALUES ('.
#					                         "'$rcptto','$h_from',$mLACK,$mOPEN,$mTRUST,$mCOEF,$mCOUNT)";
#      Exim::log_write( "Trustlist: $query");
      &querySQL( 'INSERT INTO trustlist.v_control ("user","from",lack_time,'.
                     'opened_time,trust_time,coef_grey_window,count_threshold)'.
                 'VALUES ('.
                     "'$rcptto','$h_from',$mLACK,$mOPEN,$mTRUST,$mCOEF,$mCOUNT)" ) ;
    }
  }
  return true;
}


sub extractFrom {
  use Unicode::MapUTF8 qw(to_utf8 from_utf8);

  my $from = shift ;

  # Primer caso, estandar. La direccion se encuentra entre corchetes
  # angulares.

  if( $from =~ /<([^"<() @]+@[^ >()"]+)>/ ) {
    return to_utf8({ -string => "$1", -charset => 'ISO-8859-1' });
  }

  # Segundo caso, cosas raras: Se extrae cualquier direccion de mail que se
  # encuentre en el campo.

  if( $from =~ /(^|["<() ])([^"<() @]+@[^ >()" ]+).*$/ ) {  # "
    return to_utf8({ -string => "$2", -charset => 'ISO-8859-1' });
  }

  # Tercer caso: me rindo. No mandaron nada ni parecido a una direccion de mail
  # en el campo.

  return "" ;
}

sub isVirus {
  return ( &Exim::expand_string( '${if def:acl_m0 {true}{false}}' ) ) ;
}

sub isDSN {
  my $sender = shift ;
  return ( $sender eq '' )? 'true' : 'false' ;
}

sub getLocalPart {
  shift =~ /^([^@]*)@.*$/ ;
  my $user = "$1" ;
  return $user ;
}

sub isList {
  my $user = lc( &getLocalPart( shift ) );

  my $query = '${if or{{def:header_Precedence:}{match {'.$user.'}{^.*-request\$}}'.
                       '{match {'.$user.'}{^owner-.*}}{def:header_List-Id:}'.
                       '{def:header_List-Help:}{def:header_List-Subscribe:}'.
                       '{def:header_List-Unsubscribe:}{def:header_List-Post:}'.
                       '{def:header_List-Owner:}{def:header_List-Archive:}}{true}{false}}' ;
  return ( &Exim::expand_string( "$query" ) ) ;
}

@thresholds=(63,59,54,50,45,41,36,32,28,24) ;

sub computeSpamassassinUmbral {
  my $virtual_threshold = shift ;
  if ( !$virtual_threshold or $virtual_threshold<1 or $virtual_threshold>10 ) {
    return $thresholds[4] ;
  }
  else {
    return $thresholds[$virtual_threshold] ;
  }
}

sub inList()
{
  my $pattern = shift;
  my $fileName = shift;
  my $finalFileName = "< $fileName";
  my $found = 0;

  open(FH,$finalFileName) or die 'Could not open file '.$fileName. ": $! \n";
  while (defined($line = <FH>) and not $found) {
    #if ( $line =~ /^quotemeta($pattern)$/ )
    if ( $line =~ /^$pattern$/ )
    {
      $found = 1;
    }
  }
  close(FH);
  Exim::log_write( "[in list] pattertn '$pattern' result '$found'" ) ;
  return $found;
}

# Decide si un mail es Spam o no
# @param mail
# @param Hfrom (Header From:)
# @param $LISTINGS_RBL
# @param $SPF_DATA
# @param $spam_score_int
# @param $BOGOFILTER
# @param &aclExecResultRCPT
# @param &userContentFilter
sub isSpam {
  my $mail = shift ;
  my $Hfrom = shift ;
  my $rblCount = shift ;
  my $spfData = shift ;
  my $spamScore = shift ;
  my $bogoScore = (shift eq '0' )? true : false ;
  my $tests = shift ;
  my $threshold = 3;

  if ( &inList(&extractFrom($Hfrom),SENDERS_WHITELIST) ) {
    return 'false';
  }

  if ( $tests =~ /(^|\s)trustlist($|\s)/ ) {
    my $test = querySQL( 'select valid from trustlist.froms where "user"=\''.
                 $mail .'\' and "from"=\''.&extractFrom($Hfrom).'\'' , 'true') ;
    return 'false' if ( $test eq '1' ) ;
  }
  if ( $rblCount eq '1' and $tests =~ /(^|\s)rblw($|\s)/ ) {
    return 'true' ;
  }
  if ( $spfData eq '3' and $tests =~ /(^|\s)spfw($|\s)/ ) {
    return 'true' ;
  }
  ## ANTISPAM_CHECK
  if ( $tests !~ /(^|\s)antispam($|\s)/ ) {
    return 'false' ;
  }
  if ( $spamScore eq '' ) {
    return $bogoScore ;
  }
  if ( $spamScore >= &computeSpamassassinUmbral($threshold) ) {
    return 'true' ;
  }
  return 'false' ;
}


# @param sender
# @param rcpt
# @param &isSpam
sub getXTqScanResult {
  my $from = shift ;
  my $to = shift ;
  my $isSpam = shift ;
  my $messageType = 'valid' ;

  if ( &str2bool(&isVirus) ) {
    $messageType = 'virus' ; 
  } elsif ( &str2bool( $isSpam ) ) {
    $messageType = 'spam' ;
  } elsif ( &str2bool(&isList($to)) ) {
    $messageType = 'lists' ;
  } elsif ( &str2bool(&isDSN($from)) ) {
    $messageType = 'warn' ;
  }
  Exim::log_write( "@@ $to Scan-Result: $messageType" ) ;
  return "$messageType" ;
}

