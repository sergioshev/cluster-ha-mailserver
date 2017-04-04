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
                      #$imapAdminPasswd,OP_HALFOPEN);

    if ( $imap === false) {
      echo "Can't connect: " . imap_last_error() . "\n";
      return false;
    }
    return $imap;
  }


  function moveAllMail($folders,$toFolder)
  {
    global $phpImapServer,$cannonicMbox,$imapAdminUser;

    if (! is_array($folders)) return false;
    $flag = true;
    if ( ( $imap = connectToImap() ) === false) return false;
    echo "To folder [$toFolder]\n";
    foreach ($folders as $folder)
    {
      echo "$folder\n";
      imap_reopen($imap,$folder);
      $regExpr = "/^\{.*\}/";
      $rFolder = preg_replace($regExpr,'',$folder,1);
      imap_setacl($imap,$rFolder,$imapAdminUser,CYRUS_RIGHTS);
      $result = imap_search($imap,"ALL",SE_UID);
      if ($result === false) continue;
      echo "Moving mail for mailbox [".$folder."]\n";
      echo "  ".count($result)." messages.\n";
      $moveResult = imap_mail_move($imap,implode(',',$result),$toFolder,CP_UID);
      if ($moveResult == false) {
        echo "  Failed to move mail [".imap_last_error()."]\n";
        $flag = false;
      }
      else echo "  Ok.\n";
      echo "\n";
      imap_expunge($imap);
    }
    imap_close($imap);
    return $flag;
  }

  #
  # $type = fn | fp
  # fn => falso negativo - spam en la bandeja de entrada
  # fp => falso positivo - valido en la bandeja de spam
  function getMailboxes($type)
  {
    global $cannonicMbox,$phpImapServer;
    if ( ( $imap = connectToImap() ) === false) return false;
    $list = imap_list($imap,$phpImapServer,"user/%/".$cannonicMbox[$type]);
    $count = 0;
    $result = array();
    if (is_array($list))
      foreach ($list as $folder)
        if (strpos($folder,'tqbayes') === false) {
          $result[$count++] = $folder;
        } else {
          echo "Ignoring $folder\n";
        }
    else
    {
      imap_close($imap);
      echo "Can't get mailboxes list\n";
      return false;
    }
    imap_close($imap);
    return $result;
  }
 
  $result_fn = moveAllMail(getMailboxes('fn'),'user/tqbayes/ValidoErroneo');
  $result_fp = moveAllMail(getMailboxes('fp'),'user/tqbayes/SpamErroneo');

  if ( ! $result_fn || ! $result_fp ) {
    echo "Something wrong!\n";
    exit(1);
  }
  exit(0);
?>
