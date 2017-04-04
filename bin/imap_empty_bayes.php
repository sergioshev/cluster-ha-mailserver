#!/usr/bin/php
<?php

  include 'imap.conf.php';

  define ("CYRUS_RIGHTS","lrswipcda");

  function connectToImap()
  {
    global $phpImapServer,$imapAdminUser,$imapAdminPasswd;
    global $cannonicMbox;
 
    $imap = imap_open($phpImapServer,$imapAdminUser,
                      $imapAdminPasswd);
                      //$imapAdminPasswd,OP_HALFOPEN);

    if ( $imap === false) {
      echo "Can't connect: " . imap_last_error() . "\n";
      return false;
    }
    return $imap;
  }


  function empty_folder($folder)
  {
    global $phpImapServer,$cannonicMbox,$imapAdminUser;

    if ( ( $imap = connectToImap() ) === false) return false;
    echo "To folder [$folder]\n";
    imap_reopen($imap, $phpImapServer.$folder);
    imap_setacl($imap, $phpImapServer.$folder, $imapAdminUser, CYRUS_RIGHTS);
    $result = imap_search($imap,"ALL", SE_UID);
    if ($result === false) return true;
    echo "Deleting mail for mailbox [".$folder."]\n";
    echo "  ".count($result)." messages.\n";
    imap_delete($imap, '1:*');
/*
    foreach ($result as $m) {
      echo "    msg uid=$m\n";
      imap_delete($imap, $m, FT_UID);
    }
*/
    imap_expunge($imap);
    imap_close($imap);
    return true;
  }

  $result = empty_folder('user/tqbayes/ValidoErroneo');

  if ( ! $result ) {
    echo "Something wrong!\n";
    exit(1);
  }
  exit(0);
?>
