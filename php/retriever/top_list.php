<?php

// start up session
session_start();

// login isn't set, redirect
if (!isset($_SESSION['login']))
	header('Location: login.php');
	
else {
	header('Location: main.php');
}


if (!isset($_SESSION['login']))  
	header('Location: login.php');	


require './_db_open.php'; 


$topic_arr = array();
while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
	array_push($topic_arr, $row);	
}

if (strlen($_GET['a']) > 0) {
	$form_act = $_GET['a'];
	$topic_id = $_POST['selTopics'];
	
	$query = 'SELECT * FROM `tblArticles` WHERE `tweet_id` = "'. $_POST['hidTweetID'] .'";';
	$result = mysql_query($query);
	$row = mysql_fetch_assoc($result);
	
	if ($row) {
		switch ($form_act) {
			case "1":
				//echo ("MOST LIKED [". $row['id'] ."]");
				$query = 'UPDATE `tblTopArticles` SET `article_id` = "'. $row['id'] .'" WHERE `id` = '. $_POST['hidID'] .' AND `type_id` = 1;';
				$result = mysql_query($query);
				break;
			
			case "2":
				//echo ("TOP 10 [". $row['id'] ."]");
				$query = 'UPDATE `tblTopArticles` SET `article_id` = "'. $row['id'] .'" WHERE `id` = '. $_POST['hidID'] .' AND `type_id` = 2;';
				$result = mysql_query($query);
				break;	
		}
		
		//echo ($query);
	}
}


$query = 'SELECT * FROM `tblTopArticles` WHERE `type_id` = 1 ORDER BY `total` DESC;';
$result = mysql_query($query);

$liked_arr = array();
while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
	$query = 'SELECT * FROM `tblArticles` WHERE `id` = '. $row['article_id'] .';';
	$article_result = mysql_query($query);
	$article_row = mysql_fetch_assoc($article_result);
	
	array_push($liked_arr, $article_row);
} 

$query = 'SELECT * FROM `tblTopArticles` WHERE `type_id` = 2 ORDER BY `total` DESC;';
$result = mysql_query($query);

$top10_arr = array();
while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
	$query = 'SELECT * FROM `tblArticles` WHERE `id` = '. $row['article_id'] .';';
	$article_result = mysql_query($query);
	$article_row = mysql_fetch_assoc($article_result);
	
	array_push($top10_arr, $article_row);
} 

$query = 'SELECT * FROM `tblTopics` WHERE `active` = "Y" ORDER BY `order` ASC;';
$result = mysql_query($query);

?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="Content-language" value="en" />
		
		<script type="text/javascript">
			function updateMostLiked(ind) {
				var tweetTxt_obj = document.getElementById('txtLiked_'+ind);
				
				//alert ("MOST LIKED ["+ind+"]["+tweetTxt_obj.value+"]");
								
				document.frmMostLiked.hidTweetID.value = tweetTxt_obj.value;
				document.frmMostLiked.hidID.value = parseInt(ind) + 1;
				document.frmMostLiked.submit();
			}        232191378485026816
			
			function updateTop10(ind) {
				//alert ("TOP 10 ["+ind+"]");
				var tweetTxt_obj = document.getElementById('txtTop10_'+ind);
				document.frmTop10.hidTweetID.value = tweetTxt_obj.value;
				document.frmTop10.hidID.value = parseInt(ind) + 11;
				document.frmTop10.submit();
			}
		</script>
	</head>
	
	<body>
		<table cellpadding="0" cellspacing="0" border="0">
			<tr><td><strong>Most Liked</strong></td></tr>
			<tr>
				<td valign="top"><form id="frmMostLiked" name="frmMostLiked" method="post" action="index.php?a=1"><table cellpadding="0" cellspacing="0" border="0"><?php echo ("\n");
					$cnt = 0;
					foreach ($liked_arr as $key => $val) {						
						echo ("\t\t\t\t\t<tr>");
						echo ("\t<td width=\"32\">". ($cnt + 1) ."</td>");
						echo ("<td><input type=\"text\" id=\"txtLiked_". $cnt ."\" name=\"txtLiked_". $cnt ."\" size=\"25\" value=\"". $liked_arr[$cnt]['tweet_id'] ."\" />");												
						echo ("<input type=\"button\" value=\"Update\" onclick=\"updateMostLiked('". $cnt ."')\" />");
						echo ("</td></tr>\n");
						echo ("\t\t\t\t\t<tr><td colspan=\"2\">". $liked_arr[$cnt]['tweet_msg'] ."</td></tr>\n");
						echo ("\t\t\t\t\t<tr><td colspan=\"2\"><hr /></td></tr>\n");
						
						$cnt++;
					}
				?></table><input type="hidden" id="hidTweetID" name="hidTweetID" value="" /><input type="hidden" id="hidID" name="hidID" value="" /></form></td>				
			</tr>
			<tr><td><br /><br /></td></tr>
			<tr><td><strong>Top 10</strong></td></tr>
			<tr>
				<td valign="top"><form id="frmTop10" name="frmTop10" method="post" action="index.php?a=2"><table cellpadding="0" cellspacing="0" border="0"><?php echo ("\n");
					$cnt = 0;
					foreach ($top10_arr as $key => $val) {						
						echo ("\t\t\t\t\t<tr>");
						echo ("\t<td width=\"32\">". ($cnt + 1) ."</td>");
						echo ("<td><input type=\"text\" id=\"txtTop10_". $cnt ."\" name=\"txtTop10_". $cnt ."\" size=\"25\" value=\"". $top10_arr[$cnt]['tweet_id'] ."\" />");												
						echo ("<input type=\"button\" value=\"Update\" onclick=\"updateTop10('". $cnt ."')\" />");
						echo ("</td></tr>\n");
						echo ("\t\t\t\t\t<tr><td colspan=\"2\">". $top10_arr[$cnt]['tweet_msg'] ."</td></tr>\n");
						echo ("\t\t\t\t\t<tr><td colspan=\"2\"><hr /></td></tr>\n");
						
						$cnt++;
					}
				?></table><input type="hidden" id="hidTweetID" name="hidTweetID" value="" /><input type="hidden" id="hidID" name="hidID" value="" /></form></td>				
			</tr>
		</table>
	</body>
</html>