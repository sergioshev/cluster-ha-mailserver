#!/usr/bin/perl
do 'exim4.pl';
use constant SENDERS_WHITELIST => "/etc/exim4/white_senders.list";

my $Hfrom='"M Y C SERVICIO" <mycservicio@speedy.com.ar>';
if (&inList(&extractFrom($Hfrom),SENDERS_WHITELIST)) {
  print(&extractFrom($Hfrom)." esta\n"); 
} else {
  print("no esta\n");
}
