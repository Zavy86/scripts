<?php
/* ------------------------------------------------------------------------- *\
|* -[ SHELL EXEC - GIT PULL ]----------------------------------------------- *|
\* ------------------------------------------------------------------------- */
// acquire variables
$g_submit=$_GET['submit'];
// check if submit from web form or cron
if($g_submit<>"form" && $g_submit<>"cron"){
// show form
?>
<html>
 <head>
  <title><?php echo strtoupper(exec('hostname')); ?> - GIT Pull</title>
 </head>
 <body>
  <h1><?php echo strtoupper($_SERVER['SERVER_NAME']); ?> - GIT Pull</h1>
  <form id="form_repositories" action="git_pull.php" method="get">
   <u>Repository to pull:</u><br><br>
   <?php
   $dir="../../";
   if(is_dir($dir)){
    if($dh=opendir($dir)){
     while(($file=readdir($dh))!==false){
      if(is_dir($dir.$file)&&$file<>"."&&$file<>".."){
       if(is_dir($dir.$file."/.git")){
        echo "<input type='checkbox' name='repositories[]' value='".$file."'";
        echo " checked='checked'> ".$file."<br>\n";
       }
       // sub directories
       if($dh2=opendir($dir.$file)){
        while(($file2=readdir($dh2))!==false){
         if(is_dir($dir.$file."/".$file2)&&$file2<>"."&&$file2<>".."){
          if(is_dir($dir.$file."/".$file2."/.git")){
           echo "<input type='checkbox' name='repositories[]' value='".$file."/".$file2."'";
           echo " checked='checked'> ".$file."/".$file2."<br>\n";
          }
         }
        }
       }
      }
     }
     closedir($dh);
    }
   }
   ?>
   <br><input type="button" value="Check All" onClick="jqCheckAll('repositories[]',1);"/>
   <input type="button" value="Uncheck All" onClick="jqCheckAll('repositories[]',0);"/>
   <button type="submit" name="submit" value="form">Pull</button>
  </form>
  <!-- jQuery -->
  <script src="jquery-1.8.0.min.js"></script>
  <script type="text/javascript">
   function jqCheckAll(name,flag){
    if(flag===0){
     $("input[name='"+name+"']").attr('checked',false);
    }else{
     $("input[name='"+name+"']").attr('checked',true);
    }
   }
  </script>
 </body>
</html>
<?php
// do action
}else{
 // disable the time limit
 set_time_limit(0);
 // acquire variables
 if(is_array($_GET['repositories'])){
  foreach($_GET['repositories'] as $repository ) {
   // git pull all selected repository
   $output.=exec('whoami')."@".exec('hostname').":".shell_exec("cd /var/www/".$repository." ; pwd ; git stash ; git pull")."\n\n";
  }
  if($g_submit<>"cron"){echo "<html>\n<head>\n<title>GIT Pull Script</title>\n</head>\n<body>\n<pre>\n";}
  echo $output;
  if($g_submit<>"cron"){echo "</pre>\n</body>\n</html>\n";}
  if($output==NULL){echo "Error executing <b>git pull</b>";}
 }else{
  echo "Error, please select one or more repositories";
 }
}
?>