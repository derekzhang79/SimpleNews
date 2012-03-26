//
//  SNArticleListViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <Twitter/Twitter.h>
#import "SNGraphCaller.h"
#import "SNTwitterCaller.h"

#import "SNArticleListViewController_iPhone.h"
#import "SNArticleCardView_iPhone.h"

#import "SNAppDelegate.h"
#import "SNTweetVO.h"

#import "SNFacebookCardView_iPhone.h"
#import "SNVideoPlayerViewControlller_iPhone.h"

@interface SNArticleListViewController_iPhone()
-(void)_goBack;
-(void)_introFirstCard;
-(void)_prevCard;
-(void)_nextCard;
-(void)_transitionBtns;
@end

@implementation SNArticleListViewController_iPhone

#define kImageScale 0.9

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startVideo:) name:@"START_VIDEO" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoStarted:) name:@"VIDEO_STARTED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoEnded:) name:@"VIDEO_ENDED" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tagSearch:) name:@"TAG_SEARCH" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_leaveArticles:) name:@"LEAVE_ARTICLES" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_shareSheet:) name:@"SHARE_SHEET" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_facebookShare:) name:@"FACEBOOK_SHARE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_twitterShare:) name:@"TWITTER_SHARE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_emailShare:) name:@"EMAIL_SHARE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_cancelShare:) name:@"CANCEL_SHARE" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showButtons:) name:@"SHOW_BUTTONS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_hideButtons:) name:@"HIDE_BUTTONS" object:nil];
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_twitterTimeline:) name:@"TWITTER_TIMELINE" object:nil];
		
		
		_articles = [NSMutableArray new];
		_cardViews = [NSMutableArray new];
		_timelineTweets = [NSMutableArray new];
		
		_isSwiping = NO;
		
		[[SNTwitterCaller sharedInstance] userTimeline];
	}
	return (self);
}

-(id)initAsMostRecent {
	if ((self = [self init])) {
		_articlesRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
		[_articlesRequest setTimeOutSeconds:30];
		[_articlesRequest setDelegate:self];
		[_articlesRequest startAsynchronous];
	}
	
	return (self);
}

-(id)initWithFollowers {
	if ((self = [self init])) {
		_articlesRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
		[_articlesRequest setPostValue:[SNAppDelegate subscribedFollowers] forKey:@"followers"];
		[_articlesRequest setTimeOutSeconds:30];
		[_articlesRequest setDelegate:self];
		[_articlesRequest startAsynchronous];
	}
	
	return (self);
}

-(id)initWithTag:(int)tag_id {
	if ((self = [self init])) {
		_articlesRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", 4] forKey:@"action"];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", tag_id] forKey:@"tagID"];
		[_articlesRequest setTimeOutSeconds:30];
		[_articlesRequest setDelegate:self];
		[_articlesRequest startAsynchronous];
	}
	
	return (self);
}

-(id)initWithTags:(NSString *)tags {
	if ((self = [self init])) {
		_articlesRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
		[_articlesRequest setPostValue:[NSString stringWithFormat:@"%d", 5] forKey:@"action"];
		[_articlesRequest setPostValue:tags forKey:@"tags"];
		[_articlesRequest setTimeOutSeconds:30];
		[_articlesRequest setDelegate:self];
		[_articlesRequest startAsynchronous];
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"START_VIDEO" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"VIDEO_ENDED" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"TAG_SEARCH" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"LEAVE_ARTICLES" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SHARE_SHEET" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"FACEBOOK_SHARE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"TWITTER_SHARE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"EMAIL_SHARE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"CANCEL_SHARE" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SHOW_BUTTONS" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"HIDE_BUTTONS" object:nil];
	
	//[_articles release];
	//[_cardViews release];
	
	//[_latestArticlesRequest release];
	//[_olderArticlesRequest release];
	[_articlesRequest release];;
	
	[_overlayView release];
	[_cardHolderView release];
	[_shareSheetView release];
	[_blackMatteView release];
	[_loaderView release];
	
	[_greyGridButton release];
	[_whiteGridButton release];
	[_greyShareButton release];
	[_whiteShareButton release];
	
	
	[_paginationView release];
	
	//[_videoPlayerView release];
	
	[super dealloc];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
//	UIImageView *bgImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
//	bgImgView.image = [UIImage imageNamed:@"background_root.png"];
//	[self.view addSubview:bgImgView];
	
	_cardHolderView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_cardHolderView];
	
	//_overlayView = [[UIView alloc] initWithFrame:self.view.frame];
	//[self.view addSubview:_overlayView];
	
	_greyGridButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_greyGridButton.frame = CGRectMake(4.0, 0.0, 44.0, 44.0);
	[_greyGridButton setBackgroundImage:[UIImage imageNamed:@"gridIconGray_nonActive.png"] forState:UIControlStateNormal];
	[_greyGridButton setBackgroundImage:[UIImage imageNamed:@"gridIconGray_Active.png"] forState:UIControlStateHighlighted];
	[_greyGridButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_greyGridButton];
	
	_whiteGridButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_whiteGridButton.frame = CGRectMake(4.0, 0.0, 44.0, 44.0);
	[_whiteGridButton setBackgroundImage:[UIImage imageNamed:@"gridIcon_nonActive.png"] forState:UIControlStateNormal];
	[_whiteGridButton setBackgroundImage:[UIImage imageNamed:@"gridIcon_Active.png"] forState:UIControlStateHighlighted];
	[_whiteGridButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_whiteGridButton];
	
	_whiteShareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_whiteShareButton.frame = CGRectMake(272.0, 0.0, 44.0, 44.0);
	[_whiteShareButton setBackgroundImage:[UIImage imageNamed:@"shareIcon_nonActive.png"] forState:UIControlStateNormal];
	[_whiteShareButton setBackgroundImage:[UIImage imageNamed:@"shareIcon_Active.png"] forState:UIControlStateHighlighted];
	[_whiteShareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_whiteShareButton];
	
	_blackMatteView = [[UIView alloc] initWithFrame:self.view.frame];
	[_blackMatteView setBackgroundColor:[UIColor blackColor]];
	_blackMatteView.alpha = 0.0;
	[self.view addSubview:_blackMatteView];
	
	//_videoPlayerView = [[SNVideoPlayerView_iPhone alloc] initWithFrame:self.view.frame];
	//_videoPlayerView.hidden = YES;
	//[self.view addSubview:_videoPlayerView];
	
	_paginationView = [[SNPaginationView_iPhone alloc] initWithFrame:CGRectMake(278.0, 460.0, 48.0, 9.0)];
	[self.view addSubview:_paginationView];
	
	_greyShareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_greyShareButton.frame = CGRectMake(272.0, 0.0, 44.0, 44.0);
	[_greyShareButton setBackgroundImage:[UIImage imageNamed:@"shareIconGrey_nonActive.png"] forState:UIControlStateNormal];
	[_greyShareButton setBackgroundImage:[UIImage imageNamed:@"shareIconGrey_Active.png"] forState:UIControlStateHighlighted];
	[_greyShareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_greyShareButton];
	
	_shareSheetView = [[SNShareSheetView_iPhone alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 339.0)];
	[self.view addSubview:_shareSheetView];
	
	_loaderView = [[SNLoaderView_iPhone alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_loaderView];
	
	UIImageView *overlayImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
	[self.view addSubview:overlayImgView];
	
	UIPanGestureRecognizer *panRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_goSwipe:)] autorelease];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[panRecognizer setDelegate:self];
	[_cardHolderView addGestureRecognizer:panRecognizer];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
-(void)_goBack {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ARTICLES_RETURN" object:nil];	
	[self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)_goShare {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_SHEET" object:(SNArticleVO *)[_articles objectAtIndex:_cardIndex - 1]];
}

#pragma mark - Interaction handlers
-(void)_goSwipe:(id)sender {
	CGPoint translatedPoint = [(UIPanGestureRecognizer *)sender translationInView:self.view];
	//NSLog(@"SWIPE @:(%f)", translatedPoint.x);
	
	if (!_isSwiping && (translatedPoint.x > 20.0 && abs(translatedPoint.y) < 20)) {
		_isSwiping = YES;
		[self _prevCard];
	}
		
	if (!_isSwiping && (translatedPoint.x < -20.0 && abs(translatedPoint.y) < 20)) {
		_isSwiping = YES;
		[self _nextCard];
	}
}

-(void)_introFirstCard {
	SNArticleCardView_iPhone *articleCardView = (SNArticleCardView_iPhone *)[_cardViews lastObject];
	
	CABasicAnimation *zoomAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	zoomAnimation.beginTime = CACurrentMediaTime();
	zoomAnimation.toValue = [NSNumber numberWithDouble:1.0];
	zoomAnimation.duration = 0.15;
	zoomAnimation.fillMode = kCAFillModeForwards;
	zoomAnimation.removedOnCompletion = NO;
	zoomAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	[articleCardView.bgView.layer addAnimation:zoomAnimation forKey:@"zoomAnimation"];
	
	[articleCardView introContent];
	
	NSMutableArray *tweets = [NSMutableArray new];
	SNArticleVO *articleVO = (SNArticleVO *)[_articles objectAtIndex:_cardIndex];
	for (SNTweetVO *tweetVO in _timelineTweets) {
		if ([tweetVO.content rangeOfString:articleVO.article_url].location > 0 || [tweetVO.content rangeOfString:articleVO.short_url].location > 0) {
			[tweets addObject:tweetVO];
		}
	}
	
	[articleCardView setTweets:tweets];
}

-(void)_prevCard {
	NSLog(@"PREV CARD");
	
	if (_cardIndex < [_cardViews count] - 1) {
		SNBaseArticleCardView_iPhone *previousCardView = (SNBaseArticleCardView_iPhone *)[_cardViews objectAtIndex:_cardIndex + 1];
		SNBaseArticleCardView_iPhone *currentCardView = (SNBaseArticleCardView_iPhone *)[_cardViews objectAtIndex:_cardIndex];

		[UIView animateWithDuration:0.25 animations:^(void) {
			previousCardView.frame = CGRectMake(0.0, 0.0, previousCardView.frame.size.width, previousCardView.frame.size.height);
			currentCardView.frame = CGRectMake(self.view.frame.size.width, 0.0, currentCardView.frame.size.width, currentCardView.frame.size.height);
			
		} completion:^(BOOL finished) {
			
			[previousCardView introContent];
			[currentCardView resetContent];
			
			_isSwiping = NO;
			_cardIndex++;
			
			[self _transitionBtns];
			[_paginationView changePage:round((([_cardViews count] - 1) - _cardIndex) / 3)];
		}];
			
	} else {
		if (![_loaderView isLoading]) {
			[_loaderView introMe];
			[self performSelector:@selector(_doneLoading) withObject:nil afterDelay:3.0];
			
			NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
			[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
			
			_latestArticlesRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
			[_latestArticlesRequest setPostValue:[NSString stringWithFormat:@"%d", 7] forKey:@"action"];
			[_latestArticlesRequest setPostValue:[dateFormat stringFromDate:((SNArticleVO *)[_articles lastObject]).added] forKey:@"date"];
			[_latestArticlesRequest setPostValue:[SNAppDelegate subscribedFollowers] forKey:@"followers"];
			[_latestArticlesRequest setTimeOutSeconds:30];
			[_latestArticlesRequest setDelegate:self];
			//[_latestArticlesRequest startAsynchronous];
			
			[dateFormat release];
		}
	}
}

-(void)_nextCard {
	NSLog(@"NEXT CARD");
	
	if (_cardIndex > 0) {
		SNBaseArticleCardView_iPhone *currentCardView = (SNBaseArticleCardView_iPhone *)[_cardViews objectAtIndex:_cardIndex];
		SNBaseArticleCardView_iPhone *nextCardView = (SNBaseArticleCardView_iPhone *)[_cardViews objectAtIndex:_cardIndex - 1];
		
		nextCardView.frame = CGRectMake(0.0, 0.0, nextCardView.frame.size.width, nextCardView.frame.size.height);
		
		CABasicAnimation *zoomAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
		zoomAnimation.beginTime = CACurrentMediaTime() + 0.25;
		zoomAnimation.toValue = [NSNumber numberWithDouble:1.0];
		zoomAnimation.duration = 0.15;
		zoomAnimation.fillMode = kCAFillModeForwards;
		zoomAnimation.removedOnCompletion = NO;
		zoomAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		[nextCardView.bgView.layer addAnimation:zoomAnimation forKey:@"zoomAnimation"];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			currentCardView.frame = CGRectMake(-self.view.frame.size.width, 0.0, currentCardView.frame.size.width, currentCardView.frame.size.height);
			
		} completion:^(BOOL finished) {
			
			[currentCardView resetContent];
			[nextCardView introContent];
			
			_isSwiping = NO;
			_cardIndex--;
			
			[self _transitionBtns];
			[_paginationView changePage:round((([_cardViews count] - 1) - _cardIndex) / 3)];
		}];
				
	} else {
		if (![_loaderView isLoading]) {
			[_loaderView introMe];
			[self performSelector:@selector(_doneLoading) withObject:nil afterDelay:3.0];
			
			NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
			[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
			
			_olderArticlesRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
			[_olderArticlesRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
			[_olderArticlesRequest setPostValue:[dateFormat stringFromDate:((SNArticleVO *)[_articles objectAtIndex:0]).added] forKey:@"date"];
			[_latestArticlesRequest setPostValue:[SNAppDelegate subscribedFollowers] forKey:@"followers"];
			[_olderArticlesRequest setTimeOutSeconds:30];
			[_olderArticlesRequest setDelegate:self];
			//[_olderArticlesRequest startAsynchronous];
			
			[dateFormat release];
		}
	}
}


-(void)_transitionBtns {
	SNArticleVO *vo = (SNArticleVO *)[_articles objectAtIndex:_cardIndex];
	//NSLog(@"Article [%d/%d]", _cardIndex, [_articles count]);
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		if (vo.isDark) {
			_greyGridButton.alpha = 1.0;
			_greyShareButton.alpha = 1.0;
			
			_whiteGridButton.alpha = 0.0;
			_whiteShareButton.alpha = 0.0;
			
		} else {
			_whiteGridButton.alpha = 1.0;
			_whiteShareButton.alpha = 1.0;
			
			_greyGridButton.alpha = 0.0;
			_greyShareButton.alpha = 0.0;
		}
	}];
}

-(void)_doneLoading {
	_isSwiping = NO;
	[_loaderView outroMe];	
}


#pragma mark - Notification handlers
-(void)_startVideo:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	
	SNVideoPlayerViewControlller_iPhone *videoPlayerViewController = [[[SNVideoPlayerViewControlller_iPhone alloc] init] autorelease];
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:videoPlayerViewController] autorelease];
	[navigationController setNavigationBarHidden:YES animated:NO];
	[self.navigationController presentModalViewController:navigationController animated:NO];
	
	[videoPlayerViewController changeArticleVO:vo];
}

-(void)_videoStarted:(NSNotification *)notification {
	[UIView animateWithDuration:0.25 delay:0.25 options:UIViewAnimationCurveLinear animations:^(void) {
		_blackMatteView.alpha = 1.0;
	} completion:nil];
}

-(void)_videoEnded:(NSNotification *)notification {
	
	[UIView animateWithDuration:0.5 animations:^(void) {
		_blackMatteView.alpha = 0.0;
	} completion:nil];
}

-(void)_tagSearch:(NSNotification *)notification {
	[self _goBack];
}

-(void)_leaveArticles:(NSNotification *)notification {
	[self _goBack];
}

-(void)_shareSheet:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	[_shareSheetView setVo:vo];
	
	_blackMatteView.hidden = NO;
	[UIView animateWithDuration:0.33 animations:^(void) {
		_blackMatteView.alpha = 0.67;
		_shareSheetView.frame = CGRectMake(0.0, self.view.frame.size.height - _shareSheetView.frame.size.height, _shareSheetView.frame.size.width, _shareSheetView.frame.size.height);
	
	} completion:^(BOOL finished) {
	}];
}


-(void)_facebookShare:(NSNotification *)notification {
	//SNArticleVO *vo = (SNArticleVO *)[notification object];

	//NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"SELECT uid, name, pic FROM user WHERE uid=me()", @"query", nil];
	
	//[[[SNAppDelegate sharedInstance] facebook] requestWithMethodName:@"fql.query" andParams:params andHttpMethod:@"POST" andDelegate:self];
	//[[SNGraphCaller sharedInstance] postFeed:@"DERP"];
	//[[[SNAppDelegate sharedInstance] facebook] requestWithGraphPath:@"me/feed" andDelegate:self];
	[[[SNAppDelegate sharedInstance] facebook] requestWithGraphPath:@"me/feed" andParams:[NSDictionary dictionaryWithObjectsAndKeys:@"DERP", @"feed", nil] andHttpMethod:@"POST" andDelegate:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CANCEL_SHARE" object:nil];	
}
-(void)_twitterShare:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	
	TWTweetComposeViewController *twitter = [[[TWTweetComposeViewController alloc] init] autorelease];
	
	//[twitter addImage:[UIImage imageNamed:@"iOSDevTips.png"]];
	[twitter addURL:[NSURL URLWithString:[NSString stringWithString:[NSString stringWithFormat:@"http://assemb.ly/tweets?id=%@", vo.tweet_id]]]];
	[twitter setInitialText:[NSString stringWithFormat:@"via Assembly - %@", vo.title]];
	
	[self presentModalViewController:twitter animated:YES];
	
	twitter.completionHandler = ^(TWTweetComposeViewControllerResult result)  {
		
		
		//NSString *msg; 
		
		//if (result == TWTweetComposeViewControllerResultDone)
		//	msg = @"Tweet compostion completed.";
		
		//else if (result == TWTweetComposeViewControllerResultCancelled)
		//	msg = @"Tweet composition canceled.";
		
		
		//UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tweet Status" message:msg delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		//[alertView show];
		
		[self dismissModalViewControllerAnimated:YES];
	};
}

-(void)_emailShare:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *mfViewController = [[MFMailComposeViewController alloc] init];
		mfViewController.mailComposeDelegate = self;
		[mfViewController setSubject:[NSString stringWithFormat:@"Assembly - %@", vo.title]];
		[mfViewController setMessageBody:vo.content isHTML:NO];
		
		[self presentViewController:mfViewController animated:YES completion:nil];
		[mfViewController release];
		
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status:" message:@"Your phone is not currently configured to send mail." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
		
		[alert show];
		[alert release];
	}
}
-(void)_cancelShare:(NSNotification *)notification {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_blackMatteView.alpha = 0.0;
		_shareSheetView.frame = CGRectMake(0.0, self.view.frame.size.height, _shareSheetView.frame.size.width, _shareSheetView.frame.size.height);
	
	} completion:^(BOOL finished) {
		_blackMatteView.hidden = YES;
	}];
}

-(void)_showButtons:(NSNotification *)notification {
	_greyGridButton.alpha = 1.0;
	_greyShareButton.alpha = 1.0;
	
	_whiteGridButton.alpha = 1.0;
	_whiteShareButton.alpha = 1.0;
}

-(void)_hideButtons:(NSNotification *)notification {
	_greyGridButton.alpha = 0.0;
	_greyShareButton.alpha = 0.0;
	
	_whiteGridButton.alpha = 0.0;
	_whiteShareButton.alpha = 0.0;
}

-(void)_twitterTimeline:(NSNotification *)notification {
	_timelineTweets = (NSMutableArray *)[notification object];
}


#pragma mark - MailComposeViewController Delegates
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status:" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
	
	switch (result) {
		case MFMailComposeResultCancelled:
			alert.message = @"Message Canceled";
			break;
			
		case MFMailComposeResultSaved:
			alert.message = @"Message Saved";
			[alert show];
			break;
			
		case MFMailComposeResultSent:
			alert.message = @"Message Sent";
			break;
			
		case MFMailComposeResultFailed:
			alert.message = @"Message Failed";
			[alert show];
			break;
			
		default:
			alert.message = @"Message Not Sent";
			[alert show];
			break;
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
	
	
	[alert release];
}


#pragma mark - FBRequestDelegate Methods
/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	//NSLog(@"received response");
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}

	NSLog(@"%@", result);
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"Err: %@", error);
	NSLog(@"Err message: %@", [[error userInfo] objectForKey:@"error_msg"]);
	NSLog(@"Err code: %d", [error code]);
}




#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	//NSLog(@"SNArticleListViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	if ([request isEqual:_articlesRequest]) {
	
		@autoreleasepool {
			NSError *error = nil;
			NSArray *parsedArticles = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			if (error != nil)
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			else {
				NSMutableArray *articleList = [NSMutableArray array];
				_cardViews = [NSMutableArray new];
				
				int tot = 0;
				for (NSDictionary *serverArticle in parsedArticles) {
					SNArticleVO *vo = [SNArticleVO articleWithDictionary:serverArticle];
					
					//NSLog(@"ARTICLE \"%@\"", vo.title);
					
					if (vo != nil)
						[articleList addObject:vo];
					
					
					SNArticleCardView_iPhone *articleCardView = [[[SNArticleCardView_iPhone alloc] initWithFrame:_cardHolderView.frame articleVO:vo index:tot] autorelease];
					[_cardViews addObject:(SNBaseArticleCardView_iPhone *)articleCardView];
					
					tot++;
				}
				
				_articles = [articleList retain];
				
				for (SNArticleCardView_iPhone *cardView in _cardViews) {
					[_cardHolderView addSubview:cardView];
				}
				
				[self _introFirstCard];
				
//				SNFacebookCardView_iPhone *facebookCardView = [[[SNFacebookCardView_iPhone alloc] initWithFrame:self.view.frame] autorelease];
//				[_cardViews insertObject:(SNBaseArticleCardView_iPhone *)facebookCardView atIndex:[_cardViews count] - 3];
//				[_cardHolderView insertSubview:facebookCardView atIndex:[_cardViews count] - 3];
				
				_cardIndex = [_cardViews count] - 1;
			}
		}	
	}
}


-(void)requestFailed:(ASIHTTPRequest *)request {
	if (request == _articlesRequest) {
		//[_delegates perform:@selector(jobList:didFailLoadWithError:) withObject:self withObject:request.error];
		//MBL_RELEASE_SAFELY(_jobListRequest);
	}
	
	//[_loadOverlay remove];
}


/*
 -(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */






@end
