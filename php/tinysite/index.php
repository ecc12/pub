<?php

$masterpw = 'fa9beb99e4029ad5a6615399e7bbae21356086b3';

define(MGT_DIR, './mgt/');
define(TINY_DATA, MGT_DIR.'data/');
define(SMARTY_DIR, TINY_DATA.'/smarty/');
define(TINYMCE_DIR, MGT_DIR.'/tinymce/');

require(SMARTY_DIR.'Smarty.class.php');
$smarty = new Smarty();

$smarty->left_delimiter = '{{{';
$smarty->right_delimiter = '}}}';
$smarty->template_dir = TINY_DATA.'templates';
$smarty->compile_dir = SMARTY_DIR.'templates_c';
$smarty->cache_dir = SMARTY_DIR.'cache';
$smarty->config_dir = SMARTY_DIR.'configs';

function pathsafe($path) {
  if(preg_match('/^[a-zA-Z0-9\-\_]+$/',$path)) { return TRUE; }
  return FALSE;
}

$extrahead = '';
$errmessage = '';
$body = '';
$p = 'index';

if(isset($_GET['p']) && strlen($_GET['p']) && pathsafe($_GET['p'])) {
  $p = $_GET['p'];
}

if(file_exists(TINY_DATA.'pages/'.$p)) {
  $body = file_get_contents(TINY_DATA.'pages/'.$p);
} else {
  $body = "This page does not exist yet.";
}

$saveok=0;
if(isset($_GET['save']) && isset($_POST['body'])) {
  $body = stripslashes($_POST['body']);
  if(file_exists(TINY_DATA.'meta/'.$p.'.pw')) {
    $pwl = explode("\n",file_get_contents(
      TINY_DATA.'meta/'.$p.'.pw'));
    foreach($pwl as $pw) {
      if(strlen($pw) && $pw == $_POST['pw']) { $saveok=1; }
    }
  } 
  if(sha1($_POST['pw']) == $masterpw ||
     md5($_POST['pw']) == $masterpw ||
     $_POST['pw'] == $masterpw) { $saveok=1; }
  if($ok==0) { $errmessage = "Incorrect password!"; }
}
if($saveok) {
  $fh = fopen(TINY_DATA.'pages/'.$p, 'w+');
  fwrite($fh, $body);
  fclose($fh);

} elseif(isset($_GET['edit'])) {
  if(file_exists(TINYMCE_DIR.'head.tmpl')) { 
    $extrahead = file_get_contents(TINYMCE_DIR.'head.tmpl');
  }

  $body = <<<MMM

<form action="./$p?edit&save" method="POST">
<textarea class="mceEditor" rows="20" cols="40" name="body">$body</textarea><br>
<input type="submit" value="Save Page">
<input type="password" name="pw">
</form>

MMM;

  if(strlen($errmessage)) {
    $body = "<p><font color=\"red\"><b>$errmessage</b></font></p>\n$body";
  }

}

$smarty->assign('editlink', "./$p?edit");
$smarty->assign('extrahead', $extrahead);
$smarty->assign('body', $body);
$smarty->display('index.tpl');

?>
