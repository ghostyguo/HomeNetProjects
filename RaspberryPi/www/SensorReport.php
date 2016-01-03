<?php
//The 'password' is required to be setup according to your own mysql installation
$db = mysql_pconnect("localhost","root","password") or 
   die('[{"Msg":"'.mysql_error().'"}]');
mysql_query("SET CHARACTER SET 'UTF8';");	
mysql_query('SET NAMES UTF8;');
mysql_query('SET CHARACTER_SET_CLIENT=UTF8;');
mysql_query('SET CHARACTER_SET_RESULTS=UTF8;');
mysql_select_db("HomeDB");
date_default_timezone_set('Asia/Taipei');
		
$loc="";
$temp=-999;
$hum=-999;

if (isset($_GET['loc'])) {
	$loc= $_GET['loc'];
}
if (isset($_GET['temp'])) {
	$temp = $_GET['temp'];
}
if (isset($_GET['hum'])) {
	$hum = $_GET['hum'];
}

if (isset($_POST['loc'])) {
	$loc = $_POST['loc'];
}
if (isset($_POST['temp'])) {
	$temp= $_POST['temp'];
}
if (isset($_POST['hum'])) {
	$hum= $_POST['hum'];
}

if ($loc=="") {	// invalid location
	die( '[{"Msg":"loc is null"}]'); //result code
}	

$query = 'INSERT INTO `HomeDB`.`sensor` '.
		 '(`Date`, `Time`, `Location`, `Temperature`, `Humidity`)'.
		 ' VALUES '.
		 '(CURDATE(), CURTIME(),"'.$loc. '","' .$temp. '","' .$hum.'");';

if(mysql_query($query)>0) {
	//create successfully
	print  '{"Msg":"OK"},';
} else {
	print  '{"Msg":"FAIL"},';
}
mysql_close();
?>
