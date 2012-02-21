<?php # vim: ts=4:softtabstop=4:sw=4:expandtab:tw=72

# configuration
$BASEHREF='http://www.sitename.com';

# detect markdown library
$MARK=0;
if(file_exists('lib/markdown.php')) {
    include_once('lib/markdown.php');
    $MARK=1;
}

# determine which page is requested
$page = 'pg/index.txt';
if(isset($_GET['p'])&&strlen($_GET['p'])) {
    $page_requested = $_GET['p'];
    if(!preg_match('/^[a-zA-Z0-9\/\-_]+$/',$page_requested)) {
        continue;
    }
    if($page[sizeof($page)-1] == '/') {
        $page_requested .= 'index';
    }
    $page = $page_requested.'.txt';
}

# fetch the contents of the requested page
$contents = 'Content Unspecified Error';
if(file_exists($page)) {
    $contents = file_get_contents($page);
    if($MARK) { $contents = Markdown($contents); }
} else {
    $contents = "Page not found ($page).";
    $page = 'error';
}

# calculate the page title
$title = $page;
if(substr($title,0,3)=='pg/') { $page=substr($title,2); }
if(strlen($title)>3&&substr($title,sizeof($title)-5)=='.txt') {
    $title=substr($page,0,sizeof($title)-5);
}
$title = $title.' | Sitename';

?>

<html>
<head>
    <title><?=$title?></title>
</head>
<body>

...
... page template
...
... use <?=$BASEHREF?> and <?=contents?> as appropriate
...


</body>
</html>

