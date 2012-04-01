<?php

	class Articles {
		private $db_conn;
	
	  	function __construct() {
		
			$this->db_conn = mysql_connect('internal-db.s41232.gridserver.com', 'db41232_sn_usr', 'dope911t') or die("Could not connect to database.");
			mysql_select_db('db41232_simplenews') or die("Could not select database.");
		}
	
		function __destruct() {	
			if ($this->db_conn) {
				mysql_close($this->db_conn);
				$this->db_conn = null;
			}
		}
		
		
		/**
		 * Helper method to get a string description for an HTTP status code
		 * http://www.gen-x-design.com/archives/create-a-rest-api-with-php/ 
		 * @returns status
		 */
		function getStatusCodeMessage($status) {
			
			$codes = Array(
				100 => 'Continue',
				101 => 'Switching Protocols',
				200 => 'OK',
				201 => 'Created',
				202 => 'Accepted',
				203 => 'Non-Authoritative Information',
				204 => 'No Content',
				205 => 'Reset Content',
				206 => 'Partial Content',
				300 => 'Multiple Choices',
				301 => 'Moved Permanently',
				302 => 'Found',
				303 => 'See Other',
				304 => 'Not Modified',
				305 => 'Use Proxy',
				306 => '(Unused)',
				307 => 'Temporary Redirect',
				400 => 'Bad Request',
				401 => 'Unauthorized',
				402 => 'Payment Required',
				403 => 'Forbidden',
				404 => 'Not Found',
				405 => 'Method Not Allowed',
				406 => 'Not Acceptable',
				407 => 'Proxy Authentication Required',
				408 => 'Request Timeout',
				409 => 'Conflict',
				410 => 'Gone',
				411 => 'Length Required',
				412 => 'Precondition Failed',
				413 => 'Request Entity Too Large',
				414 => 'Request-URI Too Long',
				415 => 'Unsupported Media Type',
				416 => 'Requested Range Not Satisfiable',
				417 => 'Expectation Failed',
				500 => 'Internal Server Error',
				501 => 'Not Implemented',
				502 => 'Bad Gateway',
				503 => 'Service Unavailable',
				504 => 'Gateway Timeout',
				505 => 'HTTP Version Not Supported');

			return (isset($codes[$status])) ? $codes[$status] : '';
		}
		
		
		/**
		 * Helper method to send a HTTP response code/message
		 * @returns body
		 */
		function sendResponse($status=200, $body='', $content_type='text/html') {
			
			$status_header = "HTTP/1.1 ". $status ." ". $this->getStatusCodeMessage($status);
			header($status_header);
			header("Content-type: ". $content_type);
			echo $body;
		}
	    
		function articlesByInfluencer($influencer_id) {
			$article_arr = array();
			$query = 'SELECT * FROM `tblArticles` WHERE `influencer_id` = "'. $influencer_id .'";';
			$article_result = mysql_query($query);
			
			$query = 'SELECT `avatar_url`, `name`, `handle` FROM `tblInfluencers` WHERE `id` = "'. $influencer_id .'";';
			$influencer_arr = mysql_fetch_row(mysql_query($query));
			
				
			$tot = 0;
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) { 
				$query = 'SELECT * FROM `tblTags` INNER JOIN `tblArticlesTags` ON `tblTags`.`id` = `tblArticlesTags`.`tag_id` WHERE `tblArticlesTags`.`article_id` = "'. $article_row['id'] .'";';
				$tag_result = mysql_query($query);
				
				$tag_arr = array();
				while ($tag_row = mysql_fetch_array($tag_result, MYSQL_BOTH)) { 
					array_push($tag_arr, array(
						"tag_id" => $tag_row['id'], 
						"title" => $tag_row['title']
					));
				}
				
				$lorem_arr = array(
					"consequat vel illum dolore eu feugiat nulla facilisis", 
					"commodo consequat duis autem vel eum iriure dolor in hendrerit in vulputate velit esse", 
					"euismod tincidunt ut laoreet dolore magna aliquam erat volutpat ut wisi enim ad minim veniam quis"
				);
				
				
				$reaction_id = 1;
				$reaction_arr = array();
				for ($i=0; $i<rand(0, 5); $i++) {
					$line = "";
					for ($j=0; $j<rand(1, 3); $j++)
						$line .= ucfirst($lorem_arr[$j]) . ".";
					
					array_push($reaction_arr, array(
						"reaction_id" => $reaction_id, 
						"thumb_url" => "https://si0.twimg.com/profile_images/180710325/andvari.jpg", 
						"user_url" => "https://twitter.com/#!/andvari", 
						"reaction_url" => "http://shelby.tv", 
						"content" => $line
					));
					
					$reaction_id++;
				}
	
				
				array_push($article_arr, array(
					"article_id" => $article_row['id'], 
					"type_id" => $article_row['type_id'], 
					"source_id" => $article_row['source_id'], 
					"title" => $article_row['title'], 
					"article_url" => $article_row['article_url'], 
					"short_url" => $article_row['short_url'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $influencer_arr[1], 
					"twitter_handle" => $influencer_arr[2], 
					"bg_url" => $article_row['image_url'], 
					"thumb_url" => $article_row['thumb_url'], 
					"content" => $article_row['content'], 
					"avatar_url" => $influencer_arr[0], 
					"video_url" => $article_row['video_url'], 
					"is_dark" => $article_row['isDark'], 
					"added" => $article_row['added'], 
					"tags" => $tag_arr, 
					"reactions" => $reaction_arr
				));
				
				$tot++;
	    	}
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);	
		}
		
		
		function articlesByInfluencers($influencer_list) {
			
			$article_arr = array();
			$influencer_arr = explode('|', $influencer_list);
			
			foreach ($influencer_arr as $influencer_id) {	
				$query = 'SELECT * FROM `tblArticles` WHERE `influencer_id` = "'. $influencer_id .'";';
				$article_result = mysql_query($query);
			
				$query = 'SELECT `avatar_url`, `name`, `handle` FROM `tblInfluencers` WHERE `id` = "'. $influencer_id .'";';
				$influencer_arr = mysql_fetch_row(mysql_query($query));
			
				
				$tot = 0;
				while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) { 
					$query = 'SELECT * FROM `tblTags` INNER JOIN `tblArticlesTags` ON `tblTags`.`id` = `tblArticlesTags`.`tag_id` WHERE `tblArticlesTags`.`article_id` = "'. $article_row['id'] .'";';
					$tag_result = mysql_query($query);
				
					$tag_arr = array();
					while ($tag_row = mysql_fetch_array($tag_result, MYSQL_BOTH)) { 
						array_push($tag_arr, array(
							"tag_id" => $tag_row['id'], 
							"title" => $tag_row['title']
						));
					}
				    
				    $lorem_arr = array(
						"consequat vel illum dolore eu feugiat nulla facilisis", 
						"commodo consequat duis autem vel eum iriure dolor in hendrerit in vulputate velit esse", 
						"euismod tincidunt ut laoreet dolore magna aliquam erat volutpat ut wisi enim ad minim veniam quis"
					);  
					
					$reaction_id = 1;
					$reaction_arr = array();
					for ($i=0; $i<rand(0, 5); $i++) {
						$line = "";
						for ($j=0; $j<rand(1, 3); $j++)
							$line .= ucfirst($lorem_arr[$j]) . ".";
						
						array_push($reaction_arr, array(
							"reaction_id" => $reaction_id, 
							"thumb_url" => "https://si0.twimg.com/profile_images/180710325/andvari.jpg", 
							"user_url" => "https://twitter.com/#!/andvari", 
							"reaction_url" => "http://shelby.tv", 
							"content" => $line
						));
					
						$reaction_id++;
					}
				
				
					array_push($article_arr, array(
						"article_id" => $article_row['id'], 
						"type_id" => $article_row['type_id'], 
						"source_id" => $article_row['source_id'], 
						"title" => $article_row['title'], 
						"article_url" => $article_row['article_url'], 
						"short_url" => $article_row['short_url'], 
						"tweet_id" => $article_row['tweet_id'], 
						"tweet_msg" => $article_row['tweet_msg'], 
						"twitter_name" => $influencer_arr[1], 
						"twitter_handle" => $influencer_arr[2], 
						"bg_url" => $article_row['image_url'], 
						"thumb_url" => $article_row['thumb_url'], 
						"content" => $article_row['content'], 
						"avatar_url" => $influencer_arr[0], 
						"video_url" => $article_row['video_url'], 
						"is_dark" => $article_row['isDark'], 
						"added" => $article_row['added'], 
						"tags" => $tag_arr,
						"reactions" => $reaction_arr
					));
				
					$tot++;
		    	}  
		    }
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);	
		}
		
		
		
		function getMostRecentArticles() {
			$article_arr = array();
			
			$start_date = mktime(date('H'), date('i'), date('s'), date('m'), date('d') - 5, date('Y'));
			
			$query = 'SELECT * FROM `tblArticles` WHERE (`added` >= "'. date('Y-m-d H:i:s', $start_date) .'" AND `active` = "Y") ORDER BY `added` ASC;';
			$article_result = mysql_query($query); 
			
			$tot = 0;
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) { 
				$query = 'SELECT `avatar_url`, `name`, `handle` FROM `tblInfluencers` WHERE `id` = "'. $article_row['influencer_id'] .'";';
				$influencer_arr = mysql_fetch_row(mysql_query($query));
				
				$query = 'SELECT * FROM `tblTags` INNER JOIN `tblArticlesTags` ON `tblTags`.`id` = `tblArticlesTags`.`tag_id` WHERE `tblArticlesTags`.`article_id` = "'. $article_row['id'] .'";';
				$tag_result = mysql_query($query);
				
				$tag_arr = array();
				while ($tag_row = mysql_fetch_array($tag_result, MYSQL_BOTH)) { 
					array_push($tag_arr, array(
						"tag_id" => $tag_row['id'], 
						"title" => $tag_row['title']
					));
				}
				
				$lorem_arr = array(
					"consequat vel illum dolore eu feugiat nulla facilisis", 
					"commodo consequat duis autem vel eum iriure dolor in hendrerit in vulputate velit esse", 
					"euismod tincidunt ut laoreet dolore magna aliquam erat volutpat ut wisi enim ad minim veniam quis"
				);
				
				$reaction_id = 1;
				$reaction_arr = array();
				for ($i=0; $i<rand(0, 5); $i++) {				
					$line = "";
					for ($j=0; $j<rand(1, 3); $j++)
						$line .= ucfirst($lorem_arr[$j]) . ".";
						
					array_push($reaction_arr, array(
						"reaction_id" => $reaction_id, 
						"thumb_url" => "https://si0.twimg.com/profile_images/180710325/andvari.jpg", 
						"user_url" => "https://twitter.com/#!/andvari", 
						"reaction_url" => "http://shelby.tv", 
						"content" => $line
					));
					
					$reaction_id++;
				}
				
				array_push($article_arr, array(
					"article_id" => $article_row['id'], 
					"type_id" => $article_row['type_id'], 
					"source_id" => $article_row['source_id'], 
					"title" => $article_row['title'], 
					"article_url" => $article_row['article_url'], 
					"short_url" => $article_row['short_url'], 
					"tweet_id" => $article_row['tweet_id'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $influencer_arr[1], 
					"twitter_handle" => $influencer_arr[2], 
					"bg_url" => $article_row['image_url'], 
					"thumb_url" => $article_row['thumb_url'], 
					"content" => $article_row['content'], 
					"avatar_url" => $influencer_arr[0], 
					"video_url" => $article_row['video_url'], 
					"is_dark" => $article_row['isDark'], 
					"added" => $article_row['added'], 
					"tags" => $tag_arr,
					"reactions" => $reaction_arr
				));
				
				$tot++;
	    	}
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);	
		}
		
		
		function getArticlesByTag($tag_id) {
			$article_arr = array();
			
			$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblArticlesTags` ON `tblArticles`.`id` = `tblArticlesTags`.`article_id` WHERE `tblArticlesTags`.`tag_id` = "'. $tag_id .'";';
			$article_result = mysql_query($query); 
			
			$tot = 0;
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) { 
				$query = 'SELECT `avatar_url`, `name`, `handle` FROM `tblFollowers` WHERE `id` = "'. $article_row['influencerr_id'] .'";';
				$influencer_arr = mysql_fetch_row(mysql_query($query));
				
				$query = 'SELECT * FROM `tblTags` INNER JOIN `tblArticlesTags` ON `tblTags`.`id` = `tblArticlesTags`.`tag_id` WHERE `tblArticlesTags`.`article_id` = "'. $article_row['id'] .'";';
				$tag_result = mysql_query($query);
				
				$tag_arr = array();
				while ($tag_row = mysql_fetch_array($tag_result, MYSQL_BOTH)) { 
					array_push($tag_arr, array(
						"tag_id" => $tag_row['id'], 
						"title" => $tag_row['title']
					));
				}
				
				$lorem_arr = array(
					"consequat vel illum dolore eu feugiat nulla facilisis", 
					"commodo consequat duis autem vel eum iriure dolor in hendrerit in vulputate velit esse", 
					"euismod tincidunt ut laoreet dolore magna aliquam erat volutpat ut wisi enim ad minim veniam quis"
				);
				
				$reaction_id = 1;
				$reaction_arr = array();
				for ($i=0; $i<rand(0, 5); $i++) {  
					$line = "";
					for ($j=0; $j<rand(1, 3); $j++)
						$line .= ucfirst($lorem_arr[$j]) . ".";
						
					array_push($reaction_arr, array(
						"reaction_id" => $reaction_id, 
						"thumb_url" => "https://si0.twimg.com/profile_images/180710325/andvari.jpg", 
						"user_url" => "https://twitter.com/#!/andvari", 
						"reaction_url" => "http://shelby.tv", 
						"content" => $line
					));
					
					$reaction_id++;
				}
				
				array_push($article_arr, array(
					"article_id" => $article_row['id'], 
					"type_id" => $article_row['type_id'], 
					"source_id" => $article_row['source_id'], 
					"title" => $article_row['title'], 
					"article_url" => $article_row['article_url'], 
					"short_url" => $article_row['short_url'], 
					"tweet_id" => $article_row['tweet_id'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $influencer_arr[1], 
					"twitter_handle" => $influencer_arr[2], 
					"bg_url" => $article_row['image_url'], 
					"thumb_url" => $article_row['thumb_url'], 
					"content" => $article_row['content'], 
					"avatar_url" => $influencer_arr[0], 
					"video_url" => $article_row['video_url'], 
					"is_dark" => $article_row['isDark'], 
					"added" => $article_row['added'], 
					"tags" => $tag_arr, 
					"reactions" => $reaction_arr
				));
				
				$tot++;
	    	}
			
			$this->sendResponse(200, json_encode($article_arr));
			return (true);	
		}
		
		
		function getArticlesByTags($tag_list) {
			$article_arr = array();			
			$added_arr = array();
			
			$tag_arr = explode('|', $tag_list);			
			foreach ($tag_arr as $tag_id) {
			
				$query = 'SELECT * FROM `tblArticles` INNER JOIN `tblArticlesTags` ON `tblArticles`.`id` = `tblArticlesTags`.`article_id` WHERE `tblArticlesTags`.`tag_id` = "'. $tag_id .'";';
				$article_result = mysql_query($query); 
			    
				$tot = 0;
				while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) {
					
					$isAdded = false;
					foreach ($added_arr as $aID) {
						if ($aID == $article_row['id']) {
							$isAdded = true;
						}
					}
					
					if (!$isAdded) {
						array_push($added_arr, $article_row['id']);
					 
						$query = 'SELECT `avatar_url`, `name`, `handle` FROM `tblInfluencers` WHERE `id` = "'. $article_row['influencer_id'] .'";';
						$influencer_arr = mysql_fetch_row(mysql_query($query));
				
						$query = 'SELECT * FROM `tblTags` INNER JOIN `tblArticlesTags` ON `tblTags`.`id` = `tblArticlesTags`.`tag_id` WHERE `tblArticlesTags`.`article_id` = "'. $article_row['id'] .'";';
						$tag_result = mysql_query($query);
				
						$tag_arr = array();
						while ($tag_row = mysql_fetch_array($tag_result, MYSQL_BOTH)) { 
							array_push($tag_arr, array(
								"tag_id" => $tag_row['id'], 
								"title" => $tag_row['title']
							));
						}
						
						$lorem_arr = array(
							"consequat vel illum dolore eu feugiat nulla facilisis", 
							"commodo consequat duis autem vel eum iriure dolor in hendrerit in vulputate velit esse", 
							"euismod tincidunt ut laoreet dolore magna aliquam erat volutpat ut wisi enim ad minim veniam quis"
						);
					
						$reaction_id = 1;
						$reaction_arr = array();
						for ($i=0; $i<rand(0, 5); $i++) {
							$line = "";
							for ($j=0; $j<rand(1, 3); $j++)
								$line .= ucfirst($lorem_arr[$j]) . ".";
						
							array_push($reaction_arr, array(
								"reaction_id" => $reaction_id, 
								"thumb_url" => "https://si0.twimg.com/profile_images/180710325/andvari.jpg", 
								"user_url" => "https://twitter.com/#!/andvari", 
								"reaction_url" => "http://shelby.tv", 
								"content" => $line
							));
					
							$reaction_id++;
						}
				
						array_push($article_arr, array(
							"article_id" => $article_row['id'], 
							"type_id" => $article_row['type_id'], 
							"source_id" => $article_row['source_id'], 
							"title" => $article_row['title'], 
							"article_url" => $article_row['article_url'], 
							"short_url" => $article_row['short_url'], 
							"tweet_id" => $article_row['tweet_id'], 
							"tweet_msg" => $article_row['tweet_msg'], 
							"twitter_name" => $influencer_arr[1], 
							"twitter_handle" => $influencer_arr[2], 
							"bg_url" => $article_row['image_url'], 
							"thumb_url" => $article_row['thumb_url'], 
							"content" => $article_row['content'], 
							"avatar_url" => $influencer_arr[0], 
							"video_url" => $article_row['video_url'], 
							"is_dark" => $article_row['isDark'], 
							"added" => $article_row['added'], 
							"tags" => $tag_arr, 
							"reactions" => $reaction_arr
						));
				
						$tot++;
					}    
		    	}    
		    }
		
			$this->sendResponse(200, json_encode($article_arr));
			return (true);	
		}
		
		function getArticlesBeforeDate($date, $influencers) {
			$article_arr = array();
			
			$influencers_sql = '';
			if ($influencers) {
				$influencers_sql = ' AND (';
				$influencer_arr = explode('|', $influencers);
				
				foreach ($influencer_arr as $influencer_id)
					$influencers_sql .= '`influencer_id` = "'. $influencer_id .'" OR ';
				
				$influencers_sql = substr($influencers_sql, 0, -4);
				$influencers_sql .= ')';
				
			}
			
			$query = 'SELECT * FROM `tblArticles` WHERE `added` < "'. $date .'"'. $influencers_sql .' ORDER BY `added` DESC;';
			$article_result = mysql_query($query); 
			
			$tot = 0;
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) { 
				$query = 'SELECT `avatar_url`, `name`, `handle` FROM `tblInfluencers` WHERE `id` = "'. $article_row['influencer_id'] .'";';
				$influencer_arr = mysql_fetch_row(mysql_query($query));
				
				$query = 'SELECT * FROM `tblTags` INNER JOIN `tblArticlesTags` ON `tblTags`.`id` = `tblArticlesTags`.`tag_id` WHERE `tblArticlesTags`.`article_id` = "'. $article_row['id'] .'";';
				$tag_result = mysql_query($query);
				
				$tag_arr = array();
				while ($tag_row = mysql_fetch_array($tag_result, MYSQL_BOTH)) { 
					array_push($tag_arr, array(
						"tag_id" => $tag_row['id'], 
						"title" => $tag_row['title']
					));
				}
				
				$lorem_arr = array(
					"consequat vel illum dolore eu feugiat nulla facilisis", 
					"commodo consequat duis autem vel eum iriure dolor in hendrerit in vulputate velit esse", 
					"euismod tincidunt ut laoreet dolore magna aliquam erat volutpat ut wisi enim ad minim veniam quis"
				);
				
				$reaction_id = 1;
				$reaction_arr = array();
				for ($i=0; $i<rand(0, 5); $i++) {
					$line = "";
					for ($j=0; $j<rand(1, 3); $j++)
						$line .= ucfirst($lorem_arr[$j]) . ".";
						
					array_push($reaction_arr, array(
						"reaction_id" => $reaction_id, 
						"thumb_url" => "https://si0.twimg.com/profile_images/180710325/andvari.jpg", 
						"user_url" => "https://twitter.com/#!/andvari", 
						"reaction_url" => "http://shelby.tv", 
						"content" => $line
					));
					
					$reaction_id++;
				}
				
				array_push($article_arr, array(
					"article_id" => $article_row['id'], 
					"type_id" => $article_row['type_id'], 
					"source_id" => $article_row['source_id'], 
					"title" => $article_row['title'], 
					"article_url" => $article_row['article_url'], 
					"short_url" => $article_row['short_url'], 
					"tweet_id" => $article_row['tweet_id'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $influencer_arr[1], 
					"twitter_handle" => $influencer_arr[2], 
					"bg_url" => $article_row['image_url'], 
					"thumb_url" => $article_row['thumb_url'], 
					"content" => $article_row['content'], 
					"avatar_url" => $influencer_arr[0], 
					"video_url" => $article_row['video_url'], 
					"is_dark" => $article_row['isDark'], 
					"added" => $article_row['added'], 
					"tags" => $tag_arr, 
					"reactions" => $reaction_arr
				));
				
				$tot++;
	    	}
			
			 
			$this->sendResponse(200, json_encode($article_arr));
			return (true);   
		}
		
		function getArticlesAfterDate($date, $influencers) {
			$article_arr = array();
			
		   $influencers_sql = '';
			if ($influencers) {
				$influencers_sql = ' AND (';
				$influencer_arr = explode('|', $influencers);
				
				foreach ($influencer_arr as $influencer_id)
					$influencers_sql .= '`influencer_id` = "'. $influencer_id .'" OR ';
				
				$influencers_sql = substr($influencers_sql, 0, -4);
				$influencers_sql .= ')';
				
			}
			
			$query = 'SELECT * FROM `tblArticles` WHERE `added` > "'. $date .'"'. $influencers_sql .';';
			$article_result = mysql_query($query); 
			
			$tot = 0;
			while ($article_row = mysql_fetch_array($article_result, MYSQL_BOTH)) { 
				$query = 'SELECT `avatar_url`, `name`, `handle` FROM `tblFollowers` WHERE `id` = "'. $article_row['influencer_id'] .'";';
				$influencer_arr = mysql_fetch_row(mysql_query($query));
				
				$query = 'SELECT * FROM `tblTags` INNER JOIN `tblArticlesTags` ON `tblTags`.`id` = `tblArticlesTags`.`tag_id` WHERE `tblArticlesTags`.`article_id` = "'. $article_row['id'] .'";';
				$tag_result = mysql_query($query);
				
				$tag_arr = array();
				while ($tag_row = mysql_fetch_array($tag_result, MYSQL_BOTH)) { 
					array_push($tag_arr, array(
						"tag_id" => $tag_row['id'], 
						"title" => $tag_row['title']
					));
				}
				
				$lorem_arr = array(
					"consequat vel illum dolore eu feugiat nulla facilisis", 
					"commodo consequat duis autem vel eum iriure dolor in hendrerit in vulputate velit esse", 
					"euismod tincidunt ut laoreet dolore magna aliquam erat volutpat ut wisi enim ad minim veniam quis"
				);
				
				$reaction_id = 1;
				$reaction_arr = array();
				for ($i=0; $i<rand(0, 5); $i++) { 
					$line = "";
					for ($j=0; $j<rand(1, 3); $j++)
						$line .= ucfirst($lorem_arr[$j]) . ".";
						
					array_push($reaction_arr, array(
						"reaction_id" => $reaction_id, 
						"thumb_url" => "https://si0.twimg.com/profile_images/180710325/andvari.jpg", 
						"user_url" => "https://twitter.com/#!/andvari", 
						"reaction_url" => "http://shelby.tv", 
						"content" => $line
					));
					
					$reaction_id++;
				}
				
				array_push($article_arr, array(
					"article_id" => $article_row['id'], 
					"type_id" => $article_row['type_id'], 
					"source_id" => $article_row['source_id'], 
					"title" => $article_row['title'], 
					"article_url" => $article_row['article_url'], 
					"short_url" => $article_row['short_url'], 
					"tweet_id" => $article_row['tweet_id'], 
					"tweet_msg" => $article_row['tweet_msg'], 
					"twitter_name" => $influencer_arr[1], 
					"twitter_handle" => $influencer_arr[2], 
					"bg_url" => $article_row['image_url'], 
					"thumb_url" => $article_row['thumb_url'], 
					"content" => $article_row['content'], 
					"avatar_url" => $influencer_arr[0], 
					"video_url" => $article_row['video_url'], 
					"is_dark" => $article_row['isDark'], 
					"added" => $article_row['added'], 
					"tags" => $tag_arr, 
					"reactions" => $reaction_arr
				));
				
				$tot++;
	    	}  
	
			$this->sendResponse(200, json_encode($article_arr));
			return (true);
		}
		
		
		function test() {
			$this->sendResponse(200, json_encode(array(
				"result" => true
			)));
			return (true);	
		}
	}
	
	$articles = new Articles;
	////$articles->test();
	
	
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			
			case "0":
				break;
				
			case "1":
				if (isset($_POST['influencerID']))
					$articles->articlesByInfluencer($_POST['influencerID']);
				break;
				
			case "2":
				$articles->getMostRecentArticles();
				break;
				
			case "3":
				if (isset($_POST['influencers']))
					$articles->articlesByInfluencers($_POST['influencers']);
				break;
				
			case "4":
				if (isset($_POST['tagID']))
					$articles->getArticlesByTag($_POST['tagID']);
				break;
				
			case "5":
				if (isset($_POST['tags']))
					$articles->getArticlesByTags($_POST['tags']);
				break; 
				
			case "6":
				if (isset($_POST['date']))
					$articles->getArticlesBeforeDate($_POST['date'], $_POST['influencers']);
				break;
				
			case "7":
				if (isset($_POST['date']))
					$articles->getArticlesAfterDate($_POST['date'], $_POST['influencers']);
				break; 
    	}
	}
?>