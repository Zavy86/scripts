<?php
/**
 * Pixel Banner
 *
 * Version: 1.0
 * Author: Manuel Zavatta <manuel.zavatta@gmail.com>
 *
 * Example: pixel_banner.php?txt1=PIXEL&txt2=banner%20by%20Zavynet.org&bg1=ff0000&bg2=DFDFDF&fg1=FFFFFF&fg2=666666&br1=FFFFFF&br2=666666&size=180&bar=43
 *
 */
 // acquire text
 $txt1=$_GET['txt1'];
 $txt2=$_GET['txt2'];
 // acquire background
 $bg1_hex=$_GET['bg1'];
 $bg2_hex=$_GET['bg2'];
 // acquire foreground
 $fg1_hex=$_GET['fg1'];
 $fg2_hex=$_GET['fg2'];
 // acquire border
 $br1_hex=$_GET['br1'];
 $br2_hex=$_GET['br2'];
 // acquire size
 $size=$_GET['size'];
 // acquire bar position
 $bar=$_GET['bar'];
 // default values
 if(!$txt1){$txt1="PIXEL";}
 if(!$txt2){$txt2="banner by Zavynet.org";}
 if(!$bg1_hex){$bg1_hex="DD0000";}
 if(!$bg2_hex){$bg2_hex="DFDFDF";}
 if(!$fg1_hex){$fg1_hex="FFFFFF";}
 if(!$fg2_hex){$fg2_hex="666666";}
 if(!$br1_hex){$br1_hex="666666";}
 if(!$br2_hex){$br2_hex="FFFFFF";}
 if(!$size){$size=180;}
 if(!$bar){$bar=43;}
 // convert hex color code in rgb
 function hex2rgb($html_color_code){
  $hex=str_replace("#","",$html_color_code);
  if(strlen($hex)==3){
   $r=hexdec(substr($hex,0,1).substr($hex,0,1));
   $g=hexdec(substr($hex,1,1).substr($hex,1,1));
   $b=hexdec(substr($hex,2,1).substr($hex,2,1));
  }else{
   $r=hexdec(substr($hex,0,2));
   $g=hexdec(substr($hex,2,2));
   $b=hexdec(substr($hex,4,2));
  }
  $return=new stdClass();
  $return->r=$r;
  $return->g=$g;
  $return->b=$b;
  $return->rgb=array($r,$g,$b);
  return $return;
 }
 // build image resource
 $image=imagecreate($size,18);
 // allocate background colors
 $img_bg1=imagecolorallocate($image,hex2rgb($bg1_hex)->r,hex2rgb($bg1_hex)->g,hex2rgb($bg1_hex)->b);
 $img_bg2=imagecolorallocate($image,hex2rgb($bg2_hex)->r,hex2rgb($bg2_hex)->g,hex2rgb($bg2_hex)->b);
 // allocate foreground colors
 $img_fg1=imagecolorallocate($image,hex2rgb($fg1_hex)->r,hex2rgb($fg1_hex)->g,hex2rgb($fg1_hex)->b);
 $img_fg2=imagecolorallocate($image,hex2rgb($fg2_hex)->r,hex2rgb($fg2_hex)->g,hex2rgb($fg2_hex)->b);
 // allocate border colors
 $img_br1=imagecolorallocate($image,hex2rgb($br1_hex)->r,hex2rgb($br1_hex)->g,hex2rgb($br1_hex)->b);
 $img_br2=imagecolorallocate($image,hex2rgb($br2_hex)->r,hex2rgb($br2_hex)->g,hex2rgb($br2_hex)->b);
 // make external square
 imageline($image,0,0,$size-1,0,$img_br1);
 imageline($image,0,17,$size-1,17,$img_br1);
 imageline($image,0,0,0,17,$img_br1);
 imageline($image,$size-1,0,$size-1,17,$img_br1);
 // make internal square border
 imageline($image,1,1,$size-2,1,$img_br2);
 imageline($image,1,16,$size-2,16,$img_br2);
 imageline($image,1,1,1,16,$img_br2);
 imageline($image,$size-2,1,$size-2,16,$img_br2);
 // make separator
 imageline($image,$bar,1,$bar,16,$img_br2);
 // make left box
 imagefilledrectangle($image,2,2,$bar-1,15,$img_bg1);
 // make right box
 imagefilledrectangle($image,$bar+1,2,$size-3,15,$img_bg2);
 // make text
 imagestring($image,(ctype_upper($txt1)?3:2),5,2,strtoupper($txt1),$img_fg1);
 imagestring($image,(ctype_upper($txt2)?3:2),$bar+4,2,strtoupper($txt2),$img_fg2);
 // output image
 header("Content-type:image/png");
 imagepng($image);
 // clean cache
 imagedestroy($image);
?>