<?php
 $string=$_REQUEST['string'];
 if(strlen($string))$md5=md5($string);
?>
<html>
 <head><title>MD5 HASH CALCULATOR</title></head>
 <body>
  <center>
   <h1>MD5 HASH CALCULATOR</h1>
   <form action="md5.php" method="get">
    STRING: <input name="string" type="text" value="<?php echo $string; ?>"><br><br>
    <?php if($md5){echo "<code>HASH: ".$md5."</code><br><br>\n";} ?>
    <input type="submit">
   </form>
  </center>
 </body>
</html>
