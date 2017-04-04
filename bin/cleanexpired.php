#!/usr/bin/php
<?php

 /** 
  * spamina_cleanexpired. 
  * Script que corre desde el cron diariamente y limpia las tuplas vencidas
  * del sistema de greylisting y trustlist.
  */
  
  $CONF_PATH="/root/bin";
  /**
   *  Configuracion de la base de datos postgresql.
   */
  require_once $CONF_PATH.'/postgre.conf.php';

  /**
   *  Libreria PEAR para manejo generico de bases de datos.
   */
  require_once 'MDB2.php';

  $dsn="$db_backend://$db_user:$db_password@$db_host/$db_greylist";
  $mdb2 =& MDB2::factory($dsn);

  if (PEAR::isError($mdb2)) {
    echo "\n";
    echo ($mdb2->getMessage().' - '.$mdb2->getUserinfo());
  } else {  
    //grey listing
    $delete_expired = 'DELETE FROM greylist.domains WHERE now()>expire';
    $result=$mdb2->exec($delete_expired);
    if (PEAR::isError($result)) {
      echo ($result->getMessage().' - '.$result->getUserinfo());
    } else 
      echo $result." expired tuple(s) has been deleted (Greylisting)\n";
    // trust list
    $delete_expired = 'DELETE FROM trustlist.froms WHERE now()>expiry_time';
    $result=$mdb2->exec($delete_expired);
    if (PEAR::isError($result)) {
      echo ($result->getMessage().' - '.$result->getUserinfo());
    } else
      echo $result." expired tuple(s) has been deleted (Trustlist)\n";
  }  
  $mdb2->disconnect();
?>
