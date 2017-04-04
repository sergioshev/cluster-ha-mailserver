<?php

# cyrus(imap) configuration

$imapServer = 'imap.terminalquequen.com.ar';
$imapPort = '143';
$imapAdminUser = 'cyrus';
$imapAdminPasswd = 'xxxxxx';

$phpImapServer = '{'.$imapServer.':'.$imapPort.'/notls}';

# mailbox config
#  inbox      = INBOX
#  spam       = Spam
#  vwarn      = AvisosVirus
#  warn       = Avisos
#  fp         = ValidoErroneo

$cannonicMbox = array (
 'inbox' => 'INBOX',
 'spam' => 'Spam',
 'vwarn' => 'AvisosVirus',
 'warn' => 'Avisos',
 'fn' => 'ValidoErroneo',
 'fp' => 'SpamErroneo'
);

?>
