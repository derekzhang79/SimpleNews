<?php

// start the session engine
session_start();

if (!isset($_SESSION['login']))  
	header('Location: login.php');

require './_db_open.php';

if (isset($_GET['id'])) {
	
	$query = 'DELETE FROM `tblListsCurators` WHERE `list_id` = "'. $_GET['id'] .'";';
	$result = mysql_query($query);
	
	$query = 'DELETE FROM `tblListsInfluencers` WHERE `list_id` = "'. $_GET['id'] .'";';
	$result = mysql_query($query);
	
	$query = 'DELETE FROM `tblLists` WHERE `id` = "'. $_GET['id'] .'";';
	$result = mysql_query($query);
	
	header('Location: lists.php');
}
	
?>


<?php require './_db_close.php'; ?>