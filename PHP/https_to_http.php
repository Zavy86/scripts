<?php
 // definitions
 $url=null;
 $get_array=array();
 // cycle all get parameters
 foreach($_GET as $key=>$value){if($key=="url"){$url=$value;}else{$get_array[$key]=$value;}}
 // check url
 if(!$url){
  echo "inserisci l'url";
  die();
 }
 // builld https url
 $https_url=$url."?".http_build_query($get_array);
 // get https content
 $https_content=file_get_contents($https_url);
 // print https content
 echo $https_content;
 /** @todo check for headers */
?>