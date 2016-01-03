<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
  <title>HomeNet - Sensor Statistics</title>
</head>
<body>
<?php
	$db_link = @mysql_connect("localhost", "root", "ksudcc")
             or die("MySQL Server Error!<br>");  
	$select_db = @mysql_select_db("HomeDB");
	mysql_query("SET CHARACTER SET 'UTF8';");	
	mysql_query('SET NAMES UTF8;');
	mysql_query('SET CHARACTER_SET_CLIENT=UTF8;');
	mysql_query('SET CHARACTER_SET_RESULTS=UTF8;');
  
	echo "<p><b><font size=\"6\" color=\"#0000FF\">HomeNet - Sensor Statistics</font></b></size></p>";
?>

<?php	
	//----------------------------	1
	echo "<p></p><p></p>";		
	echo "<table border = '1'><tr align='center'><b><font color=\"#0000D0\">Today Hourly Statistics: </font></b><font color=#A0A0A0></font></tr>";
 		
    $sql_query = "SELECT HOUR(`Time`) , AVG(`Temperature`) , AVG(`Humidity`)";
	$sql_query = $sql_query." FROM `sensor`";
	$sql_query = $sql_query." WHERE `Date` = CURDATE( )";
	$sql_query = $sql_query." GROUP BY HOUR( `Time` );";
 	$result = mysql_query($sql_query);	

	echo "<tr>";
	$field_name = array("Hour","Temperature","Humidity");
	for($i=0; $i<count($field_name); $i++)
	{
	  echo "<td><b>".$field_name[$i]."</b></td>"; 
	}
	echo "</tr>";

	while ($row=mysql_fetch_row($result))
	{
		echo"<tr>";
		echo "<td align=\"center\"><font color=#404040>".$row[0]."</font></td>";
		for($i=1; $i<count($field_name); $i++)
		{
			printf("<td align=\"right\"><font color=#404040>%1\$.3f</font></td>",$row[$i]);	
		}
		echo "</tr>";
	}
	echo "</table>";	
	
	//----------------------------	2	
	echo "<p></p><p></p>";
	echo "<table border = '1'><tr align='center'><b><font color=\"#0000D0\">30 Days Statistics:</font></b><font color=#A0A0A0></font></tr>";
		
    $sql_query = "SELECT `Date`, AVG(`Temperature`) , AVG(`Humidity`)";
	$sql_query = $sql_query." FROM `sensor`";
	$sql_query = $sql_query." GROUP BY `Date`";
	$sql_query = $sql_query." ORDER BY `Date` DESC LIMIT 30;";
	$result = mysql_query($sql_query);	

	echo "<tr>";
 	$field_name = array("Date","Temperature","Humidity");
	for($i=0; $i<count($field_name); $i++)
	{
	  echo "<td><b>".$field_name[$i]."</b></td>"; 
	}
	echo "</tr>";
	
	while ($row=mysql_fetch_row($result))
	{
		echo"<tr>";
		echo "<td align=\"center\"><font color=#404040>".$row[0]."</font></td>";
		for($i=1; $i<count($field_name); $i++)
		{
			printf("<td align=\"right\"><font color=#404040>%1\$.3f</font></td>",$row[$i]);	
		}
		echo "</tr>";
	}
	echo "</table>";	
	//----------------------------	5
	
	echo "<p></p>";
    mysql_close($db_link);
?>
</body>
</html>