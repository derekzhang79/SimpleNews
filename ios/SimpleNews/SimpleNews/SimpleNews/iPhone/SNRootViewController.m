//
//  SNRootViewController.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>
//#import <FBiOSSDK/FacebookSDK.h>
#import "GANTracker.h"

#import "SNProtocols.h"
#import "SNRootViewController.h"
#import "SNTopicVO.h"
#import "SNNetworkAppVO.h"
#import "SNImageVO.h"
#import "SNFacebookCaller.h"

#import "SNProfileViewController.h"
#import "SNWebPageViewController.h"
#import "SNComposerViewController.h"
#import "SNHeaderView.h"
#import "SNMenuHeaderView.h"
#import "SNNetworkAppViewCell.h"
#import "SNBaseRootViewCell.h"
#import "SNAppDelegate.h"
#import "SNArticleDetailsViewController.h"
#import "SNArticleCommentsViewController.h"
#import "SNFindFriendsViewController.h"
#import "SNDiscoveryListViewController.h"
#import "SNProfileTimelineViewController.h"

#import "MBProgressHUD.h"
#import "MBLResourceLoader.h"

@interface SNRootViewController () <MBLResourceObserverProtocol, FBLoginViewDelegate>
@property(nonatomic, strong) MBLAsyncResource *topicsListResource;
@property(nonatomic, strong) MBLAsyncResource *fullscreenImgResource;
- (void)_refreshUserAccount;
- (void)_refreshTopicsList;
- (void)_hideFullscreenMedia:(NSNotification *)notification;
- (void)_cancelPopover;
@end

@implementation SNRootViewController

@synthesize topicsListResource = _topicsListResource;
@synthesize fullscreenImgResource = _fullscreenImgResource;


- (id)init {
	if ((self = [super init])) {
		_topicsList = [NSMutableArray new];
		_profileItems = [NSMutableArray new];
		
		_isIntro = YES;
		_isMainShare = NO;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showMainShareSheet:) name:@"SHOW_MAIN_SHARE_SHEET" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSubShareSheet:) name:@"SHOW_SUB_SHARE_SHEET" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showArticlePage:) name:@"SHOW_ARTICLE_PAGE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showArticleDetails:) name:@"SHOW_ARTICLE_DETAILS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showArticleComments:) name:@"SHOW_ARTICLE_COMMENTS" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showComposer:) name:@"SHOW_COMPOSER" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showFeed:) name:@"SHOW_FEED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showPopular:) name:@"SHOW_POPULAR" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showActivity:) name:@"SHOW_ACTIVITY" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showProfile:) name:@"SHOW_PROFILE" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showTwitterProfile:) name:@"SHOW_TWITTER_PROFILE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showAssemblyProfile:) name:@"SHOW_ASSEMBLY_PROFILE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_timelineReturn:) name:@"TIMELINE_RETURN" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_discoveryReturn:) name:@"DISCOVERY_RETURN" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showFullscreenMedia:) name:@"SHOW_FULLSCREEN_MEDIA" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_hideFullscreenMedia:) name:@"HIDE_FULLSCREEN_MEDIA" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showDiscovery:) name:@"SHOW_DISCOVERY" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showTimeline:) name:@"SHOW_TIMELINE" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_composeSourceCamera:) name:@"COMPOSE_SOURCE_CAMERA" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_composeSourceCameraRoll:) name:@"COMPOSE_SOURCE_CAMERA_ROLL" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_composeSourceFriends:) name:@"COMPOSE_SOURCE_FRIENDS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_composeSourceArticle:) name:@"COMPOSE_SOURCE_ARTICLE" object:nil];
	}
	
	return self;
}

- (void)dealloc
{
	self.topicsListResource = nil;
	self.fullscreenImgResource = nil;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView:self.view];
	if ([touch view] == [_baseTimelineViewController overlayView]) {
		_touchPt = CGPointMake(_baseTimelineViewController.view.center.x - location.x, _baseTimelineViewController.view.center.y - location.y);
	
	} else if ([touch view] == [_discoveryListView overlayView]) {
		_touchPt = CGPointMake(_discoveryListView.view.center.x - location.x, _discoveryListView.view.center.y - location.y);
		
	} else
		_touchPt = location;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {	
	UITouch *touch = [touches anyObject];
	
	
	// If the touch was in the placardView, move the placardView to its location
	if ([touch view] == [_baseTimelineViewController overlayView]) {
		CGPoint touchLocation = [touch locationInView:self.view];
		CGPoint location = CGPointMake(MIN(MAX(_touchPt.x + touchLocation.x, 160.0), 386.0), _baseTimelineViewController.view.center.y);
		
		_baseTimelineViewController.view.center = location;
		_shadowImgView.center = CGPointMake(_baseTimelineViewController.view.center.x - 123.0, _shadowImgView.center.y);
		
		//NSLog(@"TOUCHED:[%f, %f]", _topicTimelineView.center.x, _topicTimelineView.center.y);
		return;
	} else if ([touch view] == [_discoveryListView overlayView]) {
		CGPoint touchLocation = [touch locationInView:self.view];
		CGPoint location = CGPointMake(MIN(MAX(_touchPt.x + touchLocation.x, 160.0), 386.0), _discoveryListView.view.center.y);
		
		_discoveryListView.view.center = location;
		_shadowImgView.center = CGPointMake(_discoveryListView.view.center.x - 123.0, _shadowImgView.center.y);
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self.view];
	
	if (!_blackMatteView.hidden) {
		if (CGRectContainsPoint(_videoPlayerView.frame, touchPoint))
			[_videoPlayerView toggleControls];//NSLog(@"TOUCHED:(%f, %f)", touchPoint.x, touchPoint.y);
		
		if (CGRectContainsPoint(_fullscreenImgView.frame, touchPoint))
			[self _hideFullscreenMedia:nil];
		
		//NSLog(@"TOUCHED:[%f, %f] BLACK MATTE(%d)", touchPoint.x, touchPoint.y, !_blackMatteView.hidden);
	}
	
	if (_blackMatteView.hidden && _baseTimelineViewController != nil) {
		if (touchPoint.x < 180.0 && !CGPointEqualToPoint(_touchPt, touchPoint)) {
			[self _cancelPopover];
			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^(void) {
				_baseTimelineViewController.view.frame = CGRectMake(0.0, 0.0, _baseTimelineViewController.view.frame.size.width, _baseTimelineViewController.view.frame.size.height);
				_shadowImgView.frame = CGRectMake(-19.0, 0.0, _shadowImgView.frame.size.width, _shadowImgView.frame.size.height);
			
			} completion:^(BOOL finished) {
				[_baseTimelineViewController interactionEnabled:YES];
				_topicsTableView.contentOffset = CGPointZero;
				
			}];
		} 
		
		if (touchPoint.x >= 180.0 && !CGPointEqualToPoint(_touchPt, touchPoint)) {
			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^(void) {
				_baseTimelineViewController.view.frame = CGRectMake(kTopicOffset, 0.0, _baseTimelineViewController.view.frame.size.width, _baseTimelineViewController.view.frame.size.height);
				_shadowImgView.frame = CGRectMake(kTopicOffset - 19.0, 0.0, _shadowImgView.frame.size.width, _shadowImgView.frame.size.height);
				
			} completion:^(BOOL finished) {
				[_baseTimelineViewController interactionEnabled:NO];
			}];
		}
	
	} else if (_blackMatteView.hidden && _discoveryListView != nil) {
		if (touchPoint.x < 180.0 && !CGPointEqualToPoint(_touchPt, touchPoint)) {
			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^(void) {
				_discoveryListView.view.frame = CGRectMake(0.0, 0.0, _discoveryListView.view.frame.size.width, _discoveryListView.view.frame.size.height);
				_shadowImgView.frame = CGRectMake(-19.0, 0.0, _shadowImgView.frame.size.width, _shadowImgView.frame.size.height);
				
			} completion:^(BOOL finished) {
				[_discoveryListView interactionEnabled:YES];
				_topicsTableView.contentOffset = CGPointZero;
				
			}];
		} 
		
		if (touchPoint.x >= 180.0 && !CGPointEqualToPoint(_touchPt, touchPoint)) {
			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^(void) {
				_discoveryListView.view.frame = CGRectMake(kTopicOffset, 0.0, _discoveryListView.view.frame.size.width, _discoveryListView.view.frame.size.height);
				_shadowImgView.frame = CGRectMake(kTopicOffset - 19.0, 0.0, _shadowImgView.frame.size.width, _shadowImgView.frame.size.height);
				
			} completion:^(BOOL finished) {
				[_discoveryListView interactionEnabled:NO];
			}];
		}
	}
}

#pragma mark - View lifecycle

- (void)loadView {
	[super loadView];
	
	self.view.clipsToBounds = YES;
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_root.png"];
	[self.view addSubview:bgImgView];
	
	_holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.view addSubview:_holderView];
	
//	SNMenuHeaderView *menuHeaderView = [[SNMenuHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, 230.0, 45.0)];
//	[[menuHeaderView btn] addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
//	[_holderView addSubview:menuHeaderView];
	
	_topicsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, kTopicOffset, self.view.frame.size.height - 0.0) style:UITableViewStylePlain];
	[_topicsTableView setBackgroundColor:[UIColor clearColor]];
	_topicsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_topicsTableView.rowHeight = 50.0;
	_topicsTableView.delegate = self;
	_topicsTableView.dataSource = self;
	_topicsTableView.scrollsToTop = NO;
	_topicsTableView.showsVerticalScrollIndicator = NO;
	_topicsTableView.userInteractionEnabled = NO;
	[_holderView addSubview:_topicsTableView];
	
	_shadowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(207.0, 0.0, 113.0, 480.0)];
	_shadowImgView.image = [UIImage imageNamed:@"dropShadow.png"];
	[_holderView addSubview:_shadowImgView];
	
	_blackMatteView = [[UIView alloc] initWithFrame:self.view.frame];
	[_blackMatteView setBackgroundColor:[UIColor blackColor]];
	_blackMatteView.hidden = YES;
	_blackMatteView.alpha = 0.0;
	[self.view addSubview:_blackMatteView];
		
	UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(19.0, 12.0, 256.0, 28.0)];
	infoLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
	infoLabel.textColor = [UIColor blackColor];
	infoLabel.backgroundColor = [UIColor clearColor];
	[_blackMatteView addSubview:infoLabel];
	
	if (FBSession.activeSession.isOpen) {
		[[FBRequest requestForMe] startWithCompletionHandler:
		 ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
			 if (!error) {
				 NSLog(@"user.id [%@]", [user objectForKey:@"id"]);
				 //NSLog(@"user [%@]", user);
				 
				 [SNAppDelegate writeFBProfile:user];
				 [FBRequestConnection startWithGraphPath:@"me/home" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
					 ASIFormDataRequest *feedRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kUsersAPI]]];
					 [feedRequest setPostValue:[NSString stringWithFormat:@"%d", 8] forKey:@"action"];
					 [feedRequest setPostValue:[NSString stringWithFormat:@"%@", [[SNAppDelegate fbProfileForUser] objectForKey:@"id"]] forKey:@"fbID"];
					 [feedRequest setPostValue:[NSString stringWithFormat:@"%@", (NSDictionary *)result] forKey:@"feed"];
					 [feedRequest startAsynchronous];
				 }];
			 }
		 }];		
	}
	
	// wall
//	[FBRequest startWithGraphPath:@"me/home" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//		NSLog(@"%@", (NSDictionary *)result);
//	}];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	_holderView = nil;
	_profileButton = nil;
	_topicsTableView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
		// Refresh any network resources that need loading
	[self _refreshTopicsList];
	[self _refreshUserAccount];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (_isIntro) {
//		[UIView animateWithDuration:0.33 delay:1.67 options:UIViewAnimationCurveEaseInOut animations:^(void) {
//			_discoveryListView.view.frame = CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
//			_shadowImgView.frame = CGRectMake(-19.0, 0.0, _shadowImgView.frame.size.width, _shadowImgView.frame.size.height);
//			
//		} completion:^(BOOL finished) {
//			_isIntro = NO;
//			[_discoveryListView interactionEnabled:YES];
//			_topicsTableView.userInteractionEnabled = YES;
//		}];
	}
}

#pragma mark - Navigation
-(void)_goProfile {
	
	if (![SNAppDelegate twitterHandle]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	
	} else {
		SNProfileViewController *profileViewController = [[SNProfileViewController alloc] init];
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
		[navigationController setNavigationBarHidden:YES];
		[self.navigationController presentModalViewController:navigationController animated:YES];
	}
}

-(void)_goShare {
	if (_articleVO.type_id < 4)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_MAIN_SHARE_SHEET" object:_articleVO];
	
	else
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUB_SHARE_SHEET" object:_articleVO];
}

- (void)_goCompose{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SOURCE_ARTICLE" object:_articleVO];
}

-(void)_goDetails {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_ARTICLE_DETAILS" object:_articleVO];
	[self performSelector:@selector(_hideFullscreenMedia:) withObject:nil afterDelay:0.5];
}

- (void)_goAppStore {
	[SNAppDelegate openWithAppStore:_articleVO.article_url];
}

-(void)_goTwitterProfile {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TWITTER_PROFILE" object:_articleVO.twitterHandle];
}

- (void)_goTopic {
	[self _hideFullscreenMedia:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_TOPIC" object:[NSNumber numberWithInt:_articleVO.topicID]];
}

-(void)_goLike {
	if (![SNAppDelegate twitterHandle]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		
	} else {		
		[_likeButton removeTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
		[_likeButton addTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"leftBottomUIB_Active.png"] forState:UIControlStateNormal];
		
		_likeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kArticlesAPI]]];
		[_likeRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[_likeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[_likeRequest setPostValue:[NSString stringWithFormat:@"%d", _articleVO.article_id] forKey:@"articleID"];
		_likeRequest.delegate = self;
		[_likeRequest startAsynchronous];
		
		_articleVO.hasLiked = YES;
		
		[SNFacebookCaller postToActivity:_articleVO withAction:@"vote_up"];
	}
}

-(void)_goDislike {
	
	[_likeButton removeTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
	[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	[_likeButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
	
	_likeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kArticlesAPI]]];
	[_likeRequest setPostValue:[NSString stringWithFormat:@"%d", 7] forKey:@"action"];
	[_likeRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[_likeRequest setPostValue:[NSString stringWithFormat:@"%d", _articleVO.article_id] forKey:@"articleID"];
	_likeRequest.delegate = self;
	[_likeRequest startAsynchronous];
	
	_articleVO.hasLiked = NO;
}


-(void)_goComments {
	[self.navigationController pushViewController:[[SNArticleCommentsViewController alloc] initWithArticleVO:_articleVO] animated:YES];
}


-(void)_startVideo {
	[_videoPlayerView startPlayback];
}


- (void)_cancelPopover {
	[_popoverTimer invalidate];
	_popoverTimer = nil;
	
	[_composePopOverView removeFromSuperview];
}




#pragma mark - Network Requests
- (void)setFullscreenImgResource:(MBLAsyncResource *)fullscreenImgResource 
{
	if (_fullscreenImgResource != nil) {
		[_fullscreenImgResource unsubscribe:self];
		_fullscreenImgResource = nil;
	}
	
	_fullscreenImgResource = fullscreenImgResource;
	
	if (_fullscreenImgResource != nil)
		[_fullscreenImgResource subscribe:self];
}

- (void)setTopicsListResource:(MBLAsyncResource *)topicsListResource
{
	if (_topicsListResource != nil) {
		[_topicsListResource unsubscribe:self];
		_topicsListResource = nil;
	}
	
	_topicsListResource = topicsListResource;
	
	if (_topicsListResource != nil)
		[_topicsListResource subscribe:self];
}

- (void)_refreshTopicsList
{
	if (_topicsListResource == nil) {
//		_hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//		_hud.labelText = NSLocalizedString(@"Loading Topics…", @"Status message when loading topics list");
//		_hud.mode = MBProgressHUDModeIndeterminate;
//		_hud.graceTime = 2.0;
//		_hud.taskInProgress = YES;
		
		NSMutableDictionary *formValues = [NSMutableDictionary dictionary];
		[formValues setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, kNetworkAppsAPI];
		self.topicsListResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:formValues forceFetch:NO expiration:[NSDate dateWithTimeIntervalSinceNow:(60.0 * 60.0 * 24.0)]]; // 1 day expiration for now
	}
}

- (void)_refreshUserAccount
{
	if ((_userResource == nil) && ([SNAppDelegate twitterHandle] != nil)) {
		NSMutableDictionary *userFormValues = [NSMutableDictionary dictionary];
		[userFormValues setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[userFormValues setObject:[SNAppDelegate deviceToken] forKey:@"token"];
		[userFormValues setObject:[SNAppDelegate twitterHandle] forKey:@"handle"];
		[userFormValues setObject:[SNAppDelegate twitterID] forKey:@"twitterID"]; 
		
		NSString *url = [NSString stringWithFormat:@"%@/%@", kServerPath, kUsersAPI];
		_userResource = [[MBLResourceLoader sharedInstance] downloadURL:url withHeaders:nil withPostFields:userFormValues forceFetch:YES expiration:[NSDate date]];
		[_userResource subscribe:self];
	}
}

#pragma mark - Helpers


#pragma mark - AsyncResource Observers
- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data
{
	NSLog(@"MBLAsyncResource.data [%@]", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	if (resource == _userResource) {
		_hud.taskInProgress = NO;
		
		NSError *error = nil;
		NSDictionary *parsedUser = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		if (error != nil) {
			NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
			_hud.graceTime = 0.0;
			_hud.mode = MBProgressHUDModeCustomView;
			_hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
			_hud.labelText = NSLocalizedString(@"Download Failed", @"Status message when downloading fails");
			[_hud show:NO];
			[_hud hide:YES afterDelay:1.5];
			_hud = nil;
		}
		else {
			//_twitterRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/users/show.json?screen_name=%@", [SNAppDelegate twitterHandle]]]];
			//[_twitterRequest setDelegate:self];
			//[_twitterRequest startAsynchronous];
			
			[SNAppDelegate writeUserProfile:parsedUser];
			
			[_hud hide:YES];
			_hud = nil;
		}
	}
	
	else if (resource == _topicsListResource) {
		_hud.taskInProgress = NO;
		
		NSError *error = nil;
		//NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		//NSArray *unsortedLists = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];//[unsortedLists sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
		
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedDescription]);
			_hud.graceTime = 0.0;
			_hud.mode = MBProgressHUDModeCustomView;
			_hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
			_hud.labelText = NSLocalizedString(@"Download Failed", @"Status message when downloading fails");
			[_hud show:NO];
			[_hud hide:YES afterDelay:1.5];
			_hud = nil;
		}
		else {
			NSMutableArray *list = [NSMutableArray array];
			for (NSDictionary *serverList in parsedLists) {
				SNNetworkAppVO *vo = [SNNetworkAppVO appWithDictionary:serverList];
				//NSLog(@"LIST \"@%@\" %d", vo.list_name, vo.totalInfluencers);
				if (vo != nil)
					[list addObject:vo];
			}
			
			[_hud hide:YES];
			_hud = nil;
			
			_topicsList = list;
			[_topicsTableView reloadData];
			_topicsTableView.userInteractionEnabled = YES;
			
//			_discoveryListView = [[SNDiscoveryListView_iPhone alloc] initWithHeaderTitle:@"Top 10" isTop10:YES];
//			_discoveryListView.view.frame = CGRectMake(226.0, 0.0, 320.0, 480.0);
//			[_holderView addSubview:_discoveryListView.view];
			
			_baseTimelineViewController = [[SNBaseTimelineViewController alloc] initAsFeed];
			[_holderView addSubview:_baseTimelineViewController.view];
			
			[UIView animateWithDuration:0.33 animations:^(void) {
				_baseTimelineViewController.view.frame = CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
				_shadowImgView.frame = CGRectMake(-19.0, 0.0, _shadowImgView.frame.size.width, _shadowImgView.frame.size.height);
				
			} completion:^(BOOL finished) {
				_topicsTableView.contentOffset = CGPointZero;
				[_baseTimelineViewController interactionEnabled:YES];
			}];
		}
	
	} else if (resource == _fullscreenImgResource) {
		_fullscreenImgView.image = [UIImage imageWithData:data];
		
		_blackMatteView.hidden = NO;
		[UIView animateWithDuration:0.33 animations:^(void) {
			_blackMatteView.alpha = 0.95;
			_fullscreenHeaderView.alpha = 1.0;
			_fullscreenFooterImgView.alpha = 1.0;
			_fullscreenImgView.frame = CGRectMake(0.0, ((self.view.frame.size.height - 44.0) - (320.0 * ((SNImageVO *)[_articleVO.images objectAtIndex:0]).ratio)) * 0.5, 320.0, 320.0 * ((SNImageVO *)[_articleVO.images objectAtIndex:0]).ratio);
			
		} completion:^(BOOL finished) {
			UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_hideFullscreenMedia:)];
			tapRecognizer.numberOfTapsRequired = 1;
			[_blackMatteView addGestureRecognizer:tapRecognizer];
			
			UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(_fullscreenPinch:)];
			[_fullscreenImgView addGestureRecognizer:pinchRecognizer];
			
			UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_fullscreenPan:)];
			[_fullscreenImgView addGestureRecognizer:panRecognizer];
		}];
	}
}

- (void)_fullscreenPinch:(UIPinchGestureRecognizer *)recognizer {
	
	//NSLog(@"%f", recognizer.scale);
	
	//if (recognizer.view.transform.a >= 1.0 && recognizer.view.transform.a <= 2.0) {
		recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
		recognizer.scale = 1.0;
	//}
	
	if (recognizer.state == UIGestureRecognizerStateEnded) {
		if (recognizer.view.transform.a < 1.0) {
			[UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
				recognizer.view.transform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
			} completion:nil];
		}
		
		
		if (recognizer.view.transform.a > 2.5) {
			[UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
				recognizer.view.transform = CGAffineTransformMake(2.5, 0.0, 0.0, 2.5, 0.0, 0.0);
			} completion:nil];
		}
		
		CGPoint finalPoint = recognizer.view.center;
		if (recognizer.view.frame.size.width < self.view.bounds.size.width) 
			finalPoint.x = MIN(MAX(finalPoint.x, recognizer.view.frame.size.width * 0.5), self.view.bounds.size.width - (recognizer.view.frame.size.width * 0.5));
		else
			finalPoint.x = MAX(MIN(finalPoint.x, recognizer.view.frame.size.width * 0.5), self.view.bounds.size.width - (recognizer.view.frame.size.width * 0.5));
		
		if (recognizer.view.frame.size.height < self.view.bounds.size.height) 
			finalPoint.y = MIN(MAX(finalPoint.y, recognizer.view.frame.size.height * 0.5), self.view.bounds.size.height - (recognizer.view.frame.size.height * 0.5));
		else
			finalPoint.y = MAX(MIN(finalPoint.y, recognizer.view.frame.size.height * 0.5), self.view.bounds.size.height - (recognizer.view.frame.size.height * 0.5));
		
		[UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			recognizer.view.center = finalPoint;
		} completion:nil];
		
		
		
	}
	
	//CGFloat scale = MIN(MAX(recognizer.view.transform.a, 1.0), 2.0);
	//recognizer.view.transform = CGAffineTransformMake(scale, 0.0, 0.0, scale, 0.0, 0.0);
	NSLog(@"(%f, %f)", recognizer.view.transform.a, recognizer.view.transform.a);	
}


- (void)_fullscreenPan:(UIPanGestureRecognizer *)recognizer {
	CGPoint translation = [recognizer translationInView:self.view];
	recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
	[recognizer setTranslation:CGPointMake(0.0, 0.0) inView:self.view];
	
	
	if (recognizer.state == UIGestureRecognizerStateEnded) {		
		CGPoint velocity = [recognizer velocityInView:self.view];
		float slideFactor = 0.2 * (sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y)) * 0.005);
		
		CGPoint finalPoint = CGPointMake(recognizer.view.center.x + (velocity.x * slideFactor), recognizer.view.center.y + (velocity.y * slideFactor));
		if (recognizer.view.frame.size.width < self.view.bounds.size.width) 
			finalPoint.x = MIN(MAX(finalPoint.x, recognizer.view.frame.size.width * 0.5), self.view.bounds.size.width - (recognizer.view.frame.size.width * 0.5));
		else
			finalPoint.x = MAX(MIN(finalPoint.x, recognizer.view.frame.size.width * 0.5), self.view.bounds.size.width - (recognizer.view.frame.size.width * 0.5));
		
		if (recognizer.view.frame.size.height < self.view.bounds.size.height) 
			finalPoint.y = self.view.center.y;//MIN(MAX(finalPoint.y, recognizer.view.frame.size.height * 0.5), self.view.bounds.size.height - (recognizer.view.frame.size.height * 0.5));
		else
			finalPoint.y = MAX(MIN(finalPoint.y, recognizer.view.frame.size.height * 0.5), self.view.bounds.size.height - (recognizer.view.frame.size.height * 0.5));
		
		[UIView animateWithDuration:slideFactor delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			recognizer.view.center = finalPoint;
		} completion:nil];
	}
}

- (void)resource:(MBLAsyncResource *)resource didFailWithError:(NSError *)error
{
	if (_hud != nil) {
		_hud.graceTime = 0.0;
		_hud.mode = MBProgressHUDModeCustomView;
		_hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
		_hud.labelText = NSLocalizedString(@"Error", @"Error");
		[_hud show:NO];
		[_hud hide:YES afterDelay:1.5];
		_hud = nil;
	}
	
	// Show an error overlay?
	
	if (resource == _userResource)
		_userResource = nil;
}

#pragma mark - Notification handlers

-(void)_showArticleComments:(NSNotification *)notification {
	SNArticleCommentsViewController *articleCommentsViewController = [[SNArticleCommentsViewController alloc] initWithArticleVO:(SNArticleVO *)[notification object]];
	[self.navigationController pushViewController:articleCommentsViewController animated:YES];
}

-(void)_showArticleDetails:(NSNotification *)notification {
	SNArticleDetailsViewController *articleDetailsViewController = [[SNArticleDetailsViewController alloc] initWithArticleVO:(SNArticleVO *)[notification object]];
	[self.navigationController pushViewController:articleDetailsViewController animated:YES];
}

-(void)_showComposer:(NSNotification *)notification {
	_composePopOverView = [[SNComposePopOverView alloc] initWithFrame:CGRectMake(10.0, 350.0, 300.0, 70.0)];
	[self.view addSubview:_composePopOverView];
	
	_popoverTimer = [NSTimer scheduledTimerWithTimeInterval:3.33 target:self selector:@selector(_cancelPopover) userInfo:nil repeats:NO];
}

-(void)_composeSourceCamera:(NSNotification *)notification {
	SNComposerViewController *composerViewController = [[SNComposerViewController alloc] initWithTypeCamera];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:composerViewController];
	[navigationController setNavigationBarHidden:YES];
	[self.navigationController presentModalViewController:navigationController animated:YES];
	
	[self _cancelPopover];
}

-(void)_composeSourceCameraRoll:(NSNotification *)notification {
	SNComposerViewController *composerViewController = [[SNComposerViewController alloc] initWithTypeCameraRoll];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:composerViewController];
	[navigationController setNavigationBarHidden:YES];
	[self.navigationController presentModalViewController:navigationController animated:YES];
	
	[self _cancelPopover];
}

-(void)_composeSourceFriends:(NSNotification *)notification {
	SNComposerViewController *composerViewController = [[SNComposerViewController alloc] initWithTypeFriends];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:composerViewController];
	[navigationController setNavigationBarHidden:YES];
	[self.navigationController presentModalViewController:navigationController animated:YES];
	
	[self _cancelPopover];
}

-(void)_composeSourceArticle:(NSNotification *)notification {
	SNComposerViewController *composerViewController = [[SNComposerViewController alloc] initWithArticle:_articleVO];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:composerViewController];
	[navigationController setNavigationBarHidden:YES];
	[self.navigationController presentModalViewController:navigationController animated:YES];
}

-(void)_showArticlePage:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	SNWebPageViewController *webPageViewController = [[SNWebPageViewController alloc] initWithURL:[NSURL URLWithString:vo.article_url] title:vo.title];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_showMainShareSheet:(NSNotification *)notification {
	_isMainShare = YES;
	
	_articleVO = (SNArticleVO *)[notification object];
	
	NSError *error;
	if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/share/%d", _articleVO.article_id] withError:&error])
		NSLog(@"error in trackPageview");
	
	NSString *openSource;
	if ([_articleVO.article_url rangeOfString:@"itunes.apple.com"].length > 0)
		openSource = @"View in App Store";
	
	else
		openSource = @"Open Web View";
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
																				delegate:self 
																	cancelButtonTitle:@"Cancel" 
																 destructiveButtonTitle:nil 
																	otherButtonTitles:@"View Article", @"Share on Twitter", @"SMS", @"Copy URL", @"Email", openSource, @"Share on Facebook", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.view];
}

-(void)_showSubShareSheet:(NSNotification *)notification {
	_isMainShare = NO;
	
	_articleVO = (SNArticleVO *)[notification object];
	
	NSError *error;
	if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/share/%d", _articleVO.article_id] withError:&error])
		NSLog(@"error in trackPageview");
	
	NSString *openSource;
	if ([_articleVO.article_url rangeOfString:@"itunes.apple.com"].length > 0)
		openSource = @"View in App Store";
	
	else
		openSource = @"Open Web View";
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
																				delegate:self 
																	cancelButtonTitle:@"Cancel" 
															 destructiveButtonTitle:nil 
																	otherButtonTitles:@"Share on Twitter", @"SMS", @"Copy URL", @"Email", openSource, nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.view];
}

-(void)_showTwitterProfile:(NSNotification *)notification {
	SNWebPageViewController *webPageViewController = [[SNWebPageViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@", [notification object]]] title:[NSString stringWithFormat:@"@%@", [notification object]]];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_showAssemblyProfile:(NSNotification *)notification {
	NSNumber *userID = [notification object];
	SNProfileTimelineViewController *profileTimelineViewController = [[SNProfileTimelineViewController alloc] initWithUserID:[userID intValue]];
	[self.navigationController pushViewController:profileTimelineViewController animated:YES];
}


-(void)_timelineReturn:(NSNotification *)notification {
	[_baseTimelineViewController interactionEnabled:NO];
	[self _cancelPopover];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_baseTimelineViewController.view.frame = CGRectMake(kTopicOffset, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		_shadowImgView.frame = CGRectMake(kTopicOffset - 19.0, 0.0, _shadowImgView.frame.size.width, _shadowImgView.frame.size.height);
		
	} completion:^(BOOL finished) {
	}];
}

- (void)_discoveryReturn:(NSNotification *)notification {
	[_discoveryListView interactionEnabled:NO];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_discoveryListView.view.frame = CGRectMake(kTopicOffset, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		_shadowImgView.frame = CGRectMake(kTopicOffset - 19.0, 0.0, _shadowImgView.frame.size.width, _shadowImgView.frame.size.height);
		
	} completion:^(BOOL finished) {
	}];
}

-(void)_twitterShare:(NSNotification *)notification {
	SNArticleVO *vo = (SNArticleVO *)[notification object];
	
	TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
	
	//[twitter addImage:[UIImage imageNamed:@"iOSDevTips.png"]];
	[twitter addURL:[NSURL URLWithString:[NSString stringWithString:[NSString stringWithFormat:@"http://assemb.ly/tweets?id=%@", vo.tweetID]]]];
	[twitter setInitialText:[NSString stringWithFormat:@"via Assembly - %@", vo.title]];
	
	[self presentModalViewController:twitter animated:YES];
	
	twitter.completionHandler = ^(TWTweetComposeViewControllerResult result)  {
		
		ASIFormDataRequest *shareRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kArticlesAPI]]];
		[shareRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
		[shareRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
		[shareRequest setPostValue:[NSString stringWithFormat:@"%d", _articleVO.article_id] forKey:@"articleID"];
		[shareRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"typeID"];
		[shareRequest setDelegate:self];
		[shareRequest startAsynchronous];
				
		[self dismissModalViewControllerAnimated:YES];
	};
}

-(void)_showFullscreenMedia:(NSNotification *)notification {
	NSLog(@"\n--SHOW FULLSCREEN MEDIA--");
	NSMutableDictionary *dict = [notification object];
	
	_articleVO = [dict objectForKey:@"article_vo"];
	SNImageVO *imgVO = [dict objectForKey:@"image_vo"];
	float offset = [[dict objectForKey:@"offset"] floatValue];
	CGRect frame = [[dict objectForKey:@"frame"] CGRectValue];
	NSString *type = [dict objectForKey:@"type"];
	
	frame.origin.y = 44.0 + frame.origin.y + offset;
	_fullscreenFrame = frame;
	
	[SNFacebookCaller postToActivity:_articleVO withAction:@"view"];
	
	NSError *error;
	if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/zoom/%d/", _articleVO.article_id] withError:&error])
		NSLog(@"error in trackPageview");
	
	NSLog(@"OFFSET:[%f]", offset);
	
	
	for (UIView *view in [_blackMatteView subviews])
		[view removeFromSuperview];
	
	_fullscreenHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 55.0)];
	_fullscreenHeaderView.alpha = 0.0;
	[self.view addSubview:_fullscreenHeaderView];
	
	SNNavLogoBtnView *rndBtnView = [[SNNavLogoBtnView alloc] initWithFrame:CGRectMake(273.0, 0.0, 44.0, 44.0)];
	[[rndBtnView btn] addTarget:self action:@selector(_goCompose) forControlEvents:UIControlEventTouchUpInside];
	[_fullscreenHeaderView addSubview:rndBtnView];
	
	SNNavLogoBtnView *closeBtnView = [[SNNavLogoBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
	[[closeBtnView btn] addTarget:self action:@selector(_hideFullscreenMedia:) forControlEvents:UIControlEventTouchUpInside];
	[_fullscreenHeaderView addSubview:closeBtnView];
	
	/*
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 7.0, 256.0, 28.0)];
	titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = _articleVO.title;
	[_fullscreenHeaderView addSubview:titleLabel];
	
	UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[titleButton addTarget:self action:@selector(_goDetails) forControlEvents:UIControlEventTouchUpInside];
	titleButton.frame = titleLabel.frame;
	[_fullscreenHeaderView addSubview:titleButton];
	
	CGSize size = [@"via " sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:11] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *viaLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 34.0, size.width, size.height)];
	viaLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:11];
	viaLabel.textColor = [UIColor colorWithWhite:0.675 alpha:1.0];
	viaLabel.backgroundColor = [UIColor clearColor];
	viaLabel.text = @"via ";
	[_fullscreenHeaderView addSubview:viaLabel];
	
	CGSize size2 = [[NSString stringWithFormat:@"@%@ ", _articleVO.twitterHandle] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11] constrainedToSize:CGSizeMake(180.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(viaLabel.frame.origin.x + size.width, 34.0, size2.width, size2.height)];
	handleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	handleLabel.textColor = [SNAppDelegate snLinkColor];
	handleLabel.backgroundColor = [UIColor clearColor];
	handleLabel.text = [NSString stringWithFormat:@"@%@ ", _articleVO.twitterHandle];
	[_fullscreenHeaderView addSubview:handleLabel];
	
	UIButton *handleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[handleButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
	handleButton.frame = handleLabel.frame;
	[_fullscreenHeaderView addSubview:handleButton];
	 
	size = [@"into " sizeWithFont:[[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:11] constrainedToSize:CGSizeMake(80.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *inLabel = [[UILabel alloc] initWithFrame:CGRectMake(handleLabel.frame.origin.x + size2.width, 34.0, size.width, size.height)];
	inLabel.font = [[SNAppDelegate snHelveticaNeueFontRegular] fontWithSize:11];
	inLabel.textColor = [UIColor colorWithWhite:0.675 alpha:1.0];
	inLabel.backgroundColor = [UIColor clearColor];
	inLabel.text = @"into ";
	[_fullscreenHeaderView addSubview:inLabel];
	 
	size2 = [[NSString stringWithFormat:@"%@", _articleVO.topicTitle] sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11] constrainedToSize:CGSizeMake(180.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	UILabel *topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(inLabel.frame.origin.x + size.width, 34.0, size2.width, size2.height)];
	topicLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	topicLabel.textColor = [SNAppDelegate snLinkColor];
	topicLabel.backgroundColor = [UIColor clearColor];
	topicLabel.text = [NSString stringWithFormat:@"%@", _articleVO.topicTitle];
	[_fullscreenHeaderView addSubview:topicLabel];
	
	UIButton *topicButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[topicButton addTarget:self action:@selector(_goTopic) forControlEvents:UIControlEventTouchUpInside];
	topicButton.frame = topicLabel.frame;
	[_fullscreenHeaderView addSubview:topicButton];
	*/
	
	
	_fullscreenFooterImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 436.0, 320.0, 44.0)];
	_fullscreenFooterImgView.image = [UIImage imageNamed:@"articleDetailsFooterBG.png"];
	_fullscreenFooterImgView.userInteractionEnabled = YES;
	_fullscreenFooterImgView.alpha = 0.0;
	[self.view addSubview:_fullscreenFooterImgView];
	
	NSString *likeCaption = (_articleVO.hasLiked) ? @"Liked" : @"Like";
	_likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_likeButton.frame = CGRectMake(0.0, 1.0, 95.0, 43.0);
	[_likeButton setBackgroundImage:[UIImage imageNamed:@"leftBottomUIB_Active.png"] forState:UIControlStateHighlighted];
	[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	_likeButton.imageEdgeInsets = UIEdgeInsetsMake(1.0, -5.0, -1.0, 5.0);
	[_likeButton setImage:[UIImage imageNamed:@"likeIcon.png"] forState:UIControlStateNormal];
	[_likeButton setImage:[UIImage imageNamed:@"likeIcon_Active.png"] forState:UIControlStateHighlighted];
	_likeButton.titleEdgeInsets = UIEdgeInsetsMake(1.0, 0.0, -1.0, 0.0);
	_likeButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
	[_likeButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	[_likeButton setTitle:likeCaption forState:UIControlStateNormal];
	[_fullscreenFooterImgView addSubview:_likeButton];
	
	if (_articleVO.hasLiked) {
		[_likeButton addTarget:self action:@selector(_goDislike) forControlEvents:UIControlEventTouchUpInside];
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"leftBottomUIB_Active.png"] forState:UIControlStateNormal];
	
	} else {
		[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	}
	
	
	NSString *commentCaption;
	if ([_articleVO.comments count] == 0)
		commentCaption = @"Comment";
	
	else
		commentCaption = [NSString stringWithFormat:@"Comments (%d)", [_articleVO.comments count]];
	
	commentCaption = ([_articleVO.comments count] >= 10) ? [NSString stringWithFormat:@"Comm… (%d)", [_articleVO.comments count]] : [NSString stringWithFormat:@"Comments (%d)", [_articleVO.comments count]];
	_commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_commentButton.frame = CGRectMake(96.0, 1.0, 130.0, 43.0);
	[_commentButton setBackgroundImage:[UIImage imageNamed:@"centerbottomUI_Active.png"] forState:UIControlStateHighlighted];
	[_commentButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
	_commentButton.imageEdgeInsets = UIEdgeInsetsMake(2.0, -5.0, -2.0, 5.0);
	[_commentButton setImage:[UIImage imageNamed:@"commentIcon.png"] forState:UIControlStateNormal];
	[_commentButton setImage:[UIImage imageNamed:@"commentIcon_Active.png"] forState:UIControlStateHighlighted];
	_commentButton.titleEdgeInsets = UIEdgeInsetsMake(1.0, 0.0, -1.0, 0.0);
	_commentButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
	[_commentButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	[_commentButton setTitle:commentCaption forState:UIControlStateNormal];
	[_fullscreenFooterImgView addSubview:_commentButton];
	
	UIButton *sourceButton = [UIButton buttonWithType:UIButtonTypeCustom];
	sourceButton.frame = CGRectMake(226.0, 1.0, 95.0, 43.0);
	[sourceButton setBackgroundImage:[[UIImage imageNamed:@"rightBottomUI_Active.png"] stretchableImageWithLeftCapWidth:32.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	sourceButton.imageEdgeInsets = UIEdgeInsetsMake(1.0, 0.0, -1.0, 0.0);
	[sourceButton setImage:[UIImage imageNamed:@"moreIcon_nonActive.png"] forState:UIControlStateNormal];
	[sourceButton setImage:[UIImage imageNamed:@"moreIcon_Active.png"] forState:UIControlStateHighlighted];
	[sourceButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[_fullscreenFooterImgView addSubview:sourceButton];
	
	if ([type isEqualToString:@"photo"]) {
		_fullscreenImgView = [[UIImageView alloc] initWithFrame:frame];
		_fullscreenImgView.userInteractionEnabled = YES;
		[_blackMatteView addSubview:_fullscreenImgView];
		
		_fullscreenImgResource = nil;
		self.fullscreenImgResource = [[MBLResourceLoader sharedInstance] downloadURL:imgVO.url forceFetch:NO expiration:[NSDate dateWithTimeIntervalSinceNow:(60.0 * 60.0 * 24.0)]]; // 1 day expiration for now
		
		if ([_articleVO.article_url rangeOfString:@"itunes.apple.com"].length > 0) {
			_itunesButton = [UIButton buttonWithType:UIButtonTypeCustom];
			_itunesButton.frame = CGRectMake(197.0, 383.0, 114.0, 44.0);
			[_itunesButton setBackgroundImage:[UIImage imageNamed:@"appStoreBadge.png"] forState:UIControlStateNormal];
			[_itunesButton setBackgroundImage:[UIImage imageNamed:@"appStoreBadge.png"] forState:UIControlStateHighlighted];
			[_itunesButton addTarget:self action:@selector(_goAppStore) forControlEvents:UIControlEventTouchUpInside];
			_itunesButton.alpha = 0.0;
			[self.view addSubview:_itunesButton];
			
			[UIView animateWithDuration:0.33 animations:^(void) {
				_itunesButton.alpha = 1.0;
			} completion:nil];
		}
		
		UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(83.0, 199.0, 154.0, 32.0)];
		[overlayView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
		overlayView.layer.cornerRadius = 8.0;
		[_blackMatteView addSubview:overlayView];
		
		UILabel *overlayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 154.0, 32.0)];
		overlayLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		overlayLabel.textColor = [UIColor whiteColor];
		overlayLabel.backgroundColor = [UIColor clearColor];
		overlayLabel.textAlignment = UITextAlignmentCenter;
		overlayLabel.text = @"Tap anywhere to close";
		[overlayView addSubview:overlayLabel];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			overlayView.alpha = 1.0;
			
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.33 delay:1.5 options:UIViewAnimationCurveEaseOut animations:^(void) {
				overlayView.alpha = 0.0;
				
			} completion:^(BOOL finished) {
				[overlayView removeFromSuperview];
			}];
		}];
				
	} else if ([type isEqualToString:@"video"]) {
		_videoPlayerView = [[SNArticleVideoPlayerView alloc] initWithFrame:frame articleVO:_articleVO];
		[self.view addSubview:_videoPlayerView];
		[self performSelector:@selector(_startVideo) withObject:nil afterDelay:1.0];
	
		_blackMatteView.hidden = NO;
		[UIView animateWithDuration:0.33 animations:^(void) {
			_fullscreenHeaderView.alpha = 1.0;
			_fullscreenFooterImgView.alpha = 1.0;
			
			_blackMatteView.alpha = 0.95;
			[_videoPlayerView reframe:CGRectMake(0.0, (self.view.frame.size.height - 240.0 - 44.0) * 0.5, 320.0, 240.0)];
			
		} completion:^(BOOL finished) {
			UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_hideFullscreenMedia:)];
			tapRecognizer.numberOfTapsRequired = 1;
			[_blackMatteView addGestureRecognizer:tapRecognizer];
		}];
	}
}

-(void)_hideFullscreenMedia:(NSNotification *)notification {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_blackMatteView.alpha = 0.0;
		_fullscreenHeaderView.alpha = 0.0;
		_fullscreenFooterImgView.alpha = 0.0;
		_itunesButton.alpha = 0.0;
		
		_fullscreenImgView.frame = _fullscreenFrame;
		[_videoPlayerView reframe:_fullscreenFrame];
		[_videoPlayerView stopPlayback];
		
	} completion:^(BOOL finished) {
		_blackMatteView.hidden = YES;
		[_fullscreenImgView removeFromSuperview];
		[_videoPlayerView removeFromSuperview];
		[_fullscreenHeaderView removeFromSuperview];
		[_detailsBtnView removeFromSuperview];
		[_itunesButton removeFromSuperview];
		[_fullscreenFooterImgView removeFromSuperview];
		[_itunesButton removeFromSuperview];
		
		_itunesButton = nil;
		_fullscreenImgView = nil;
		_videoPlayerView = nil;
		_detailsBtnView = nil;
		_fullscreenFooterImgView = nil;
		_fullscreenHeaderView = nil;
		_itunesButton = nil;
	}];
}


-(void)_showFeed:(NSNotification *)notification {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DISCOVERY_RETURN" object:nil];	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TIMELINE_RETURN" object:nil];	
	
	[_baseTimelineViewController interactionEnabled:NO];
	[_baseTimelineViewController.view removeFromSuperview];
	_baseTimelineViewController = nil;
			
	_baseTimelineViewController = [[SNBaseTimelineViewController alloc] initAsFeed];
	_baseTimelineViewController.view.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
	[_holderView addSubview:_baseTimelineViewController.view];
			
	[UIView animateWithDuration:0.33 animations:^(void) {
		_baseTimelineViewController.view.frame = CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		_shadowImgView.frame = CGRectMake(-19.0, 0.0, _shadowImgView.frame.size.width, _shadowImgView.frame.size.height);
		
	} completion:^(BOOL finished) {
		_topicsTableView.contentOffset = CGPointZero;
		[_baseTimelineViewController interactionEnabled:YES];
	}];
}

-(void)_showPopular:(NSNotification *)notification {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DISCOVERY_RETURN" object:nil];	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TIMELINE_RETURN" object:nil];	
	
	[_baseTimelineViewController interactionEnabled:NO];
	[_baseTimelineViewController.view removeFromSuperview];
	_baseTimelineViewController = nil;
	
	_baseTimelineViewController = [[SNBaseTimelineViewController alloc] initAsPopular];
	_baseTimelineViewController.view.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
	[_holderView addSubview:_baseTimelineViewController.view];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_baseTimelineViewController.view.frame = CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		_shadowImgView.frame = CGRectMake(-19.0, 0.0, _shadowImgView.frame.size.width, _shadowImgView.frame.size.height);
		
	} completion:^(BOOL finished) {
		_topicsTableView.contentOffset = CGPointZero;
		[_baseTimelineViewController interactionEnabled:YES];
	}];
}

-(void)_showActivity:(NSNotification *)notification {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DISCOVERY_RETURN" object:nil];	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TIMELINE_RETURN" object:nil];	
	
	[_baseTimelineViewController interactionEnabled:NO];
	[_baseTimelineViewController.view removeFromSuperview];
	_baseTimelineViewController = nil;
	
//	_userActivityView = [[SNUserActivityView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
//	[_holderView addSubview:_userActivityView];
	
	
	
	
	_baseTimelineViewController = [[SNBaseTimelineViewController alloc] initAsActivity];
	_baseTimelineViewController.view.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
	[_holderView addSubview:_baseTimelineViewController.view];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_baseTimelineViewController.view.frame = CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		_shadowImgView.frame = CGRectMake(-19.0, 0.0, _shadowImgView.frame.size.width, _shadowImgView.frame.size.height);
		
	} completion:^(BOOL finished) {
		_topicsTableView.contentOffset = CGPointZero;
		[_baseTimelineViewController interactionEnabled:YES];
	}];
}

-(void)_showProfile:(NSNotification *)notification {
	//[self _goProfile];
	
	if ([SNAppDelegate fbProfileForUser]) {
	
		[[NSNotificationCenter defaultCenter] postNotificationName:@"DISCOVERY_RETURN" object:nil];	
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TIMELINE_RETURN" object:nil];	
		
		[_baseTimelineViewController interactionEnabled:NO];
		[_baseTimelineViewController.view removeFromSuperview];
		_baseTimelineViewController = nil;
		
		_baseTimelineViewController = [[SNBaseTimelineViewController alloc] initAsProfile];
		_baseTimelineViewController.view.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
		[_holderView addSubview:_baseTimelineViewController.view];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_baseTimelineViewController.view.frame = CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
			_shadowImgView.frame = CGRectMake(-19.0, 0.0, _shadowImgView.frame.size.width, _shadowImgView.frame.size.height);
			
		} completion:^(BOOL finished) {
			_topicsTableView.contentOffset = CGPointZero;
			[_baseTimelineViewController interactionEnabled:YES];
		}];
	}
}


- (void)_showDiscovery:(NSNotification *)notification {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_discoveryListView.view.frame = CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		_shadowImgView.frame = CGRectMake(-19.0, 0.0, _shadowImgView.frame.size.width, _shadowImgView.frame.size.height);
		
	} completion:^(BOOL finished) {
		[_discoveryListView interactionEnabled:YES];
	}];
}

- (void)_showTimeline:(NSNotification *)notification {
	[UIView animateWithDuration:0.33 animations:^(void) {
		_baseTimelineViewController.view.frame = CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
		_shadowImgView.frame = CGRectMake(-19.0, 0.0, _shadowImgView.frame.size.width, _shadowImgView.frame.size.height);
		
	} completion:^(BOOL finished) {
		[_baseTimelineViewController interactionEnabled:YES];
	}];
}

#pragma mark - ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	int ind = -1 + (buttonIndex + (int)!_isMainShare);
	
	if (ind == -1) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_ARTICLE_DETAILS" object:_articleVO];
	
	} else if (ind == 0) {
		if (![SNAppDelegate twitterHandle]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			
		} else {
			TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
			
			//[twitter addURL:[NSURL URLWithString:_articleVO.article_url]];
			[twitter setInitialText:[NSString stringWithFormat:@"%@ via @getassembly %@", _articleVO.title, _articleVO.article_url]];
			[self presentModalViewController:twitter animated:YES];
			
			twitter.completionHandler = ^(TWTweetComposeViewControllerResult result)  {
				[self dismissModalViewControllerAnimated:YES];
				
				ASIFormDataRequest *shareRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kArticlesAPI]]];
				[shareRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
				[shareRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
				[shareRequest setPostValue:[NSString stringWithFormat:@"%d", _articleVO.article_id] forKey:@"articleID"];
				[shareRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"typeID"];
				[shareRequest setDelegate:self];
				[shareRequest startAsynchronous];
			};
		}
		
	} else if (ind == 1) {
		MFMessageComposeViewController *mfViewController = [[MFMessageComposeViewController alloc] init];
		if([MFMessageComposeViewController canSendText]) {
			mfViewController.body = [NSString stringWithFormat:@"%@ via @getassembly %@", _articleVO.title, _articleVO.article_url];
			mfViewController.recipients = [NSArray arrayWithObjects:nil];
			mfViewController.messageComposeDelegate = self;
			mfViewController.wantsFullScreenLayout = NO;
			[self presentViewController:mfViewController animated:YES completion:nil];
			
			[[UIApplication sharedApplication] setStatusBarHidden:YES];
		}
		
		
	} else if (ind == 2) {
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		[pasteboard setValue:_articleVO.article_url forPasteboardType:@"public.utf8-plain-text"];
		//pasteboard.string = _vo.article_url;
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" 
																		message:@"URL has been copied to your clipboard" 
																	  delegate:self 
														  cancelButtonTitle:@"OK" 
														  otherButtonTitles:nil];
		[alert show];
		
	} else if (ind == 3) {
		if ([MFMailComposeViewController canSendMail]) {
			MFMailComposeViewController *mfViewController = [[MFMailComposeViewController alloc] init];
			mfViewController.mailComposeDelegate = self;
			[mfViewController setSubject:[NSString stringWithFormat:@"%@", _articleVO.title]];
			[mfViewController setMessageBody:[NSString stringWithFormat:@"%@ via @getassembly<br />%@", _articleVO.title, _articleVO.article_url] isHTML:YES];
			
			[self presentViewController:mfViewController animated:YES completion:nil];
			
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status:" 
																			message:@"Your phone is not currently configured to send mail." 
																		  delegate:nil 
															  cancelButtonTitle:@"ok" 
															  otherButtonTitles:nil];
			[alert show];
		}
	
	} else if (ind == 4) {
		if ([_articleVO.article_url rangeOfString:@"itunes.apple.com"].length > 0)
			[SNAppDelegate openWithAppStore:_articleVO.article_url];
		
		else {
			SNWebPageViewController *webPageViewController = [[SNWebPageViewController alloc] initWithURL:[NSURL URLWithString:_articleVO.article_url] title:_articleVO.title];
			[self.navigationController pushViewController:webPageViewController animated:YES];
		}
		
	} else if (ind == 5) {
		NSLog(@"%d", _articleVO.article_id);
		[SNFacebookCaller postToTimeline:_articleVO];
	}
}


#pragma mark - TableView DataSource Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		default:
			return (0);
			break;
			
		case 0:
			return (3);
			break;
			
		case 1:
			return ([_topicsList count]);
			break;
	}
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (2);
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (30.0);
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 30.0)];
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:headerView.frame];
	bgImgView.image = [UIImage imageNamed:@"leftMenuHeaders"];
	[headerView addSubview:bgImgView];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 0.0, tableView.frame.size.width, 30.0)];
	label.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:10];
	label.textColor = [UIColor colorWithWhite:0.290 alpha:1.0];
	label.backgroundColor = [UIColor clearColor];
	
	switch (section) {
		case 0:
			label.text = @"SETTINGS";
			break;
			
		case 1:
			label.text = @"MORE FUN?";
			break;
	}
	
	[headerView addSubview:label];
	
	return (headerView);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SNBaseRootViewCell *otherCell;
	SNNetworkAppViewCell *topicCell;
	NSArray *titles;
	
	switch (indexPath.section) {
		case 0:
			titles = [NSArray arrayWithObjects:@"Share Assembly", @"Logout", @"Privacy Policy", nil];
			otherCell = [tableView dequeueReusableCellWithIdentifier:[SNBaseRootViewCell cellReuseIdentifier]];
			
			if (otherCell == nil)
				otherCell = [[SNBaseRootViewCell alloc] initWithTitle:[titles objectAtIndex:indexPath.row]];
			
			[otherCell setSelectionStyle:UITableViewCellSelectionStyleNone];
			return (otherCell);
			break;
			
		case 1:
			topicCell = [tableView dequeueReusableCellWithIdentifier:[SNNetworkAppViewCell cellReuseIdentifier]];
			
			if (topicCell == nil)
				topicCell = [[SNNetworkAppViewCell alloc] init];
			
			topicCell.networkAppVO = (SNNetworkAppVO *)[_topicsList objectAtIndex:indexPath.row];
			[topicCell setSelectionStyle:UITableViewCellSelectionStyleNone];
			
			return (topicCell);
			break;

		default:
			return (nil);
			break;
	}
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (41.0);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	
	[((SNBaseRootViewCell *)[tableView cellForRowAtIndexPath:indexPath]) tapped];
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			FBFriendPickerViewController *friendPickerController = [[FBFriendPickerViewController alloc] init];
			friendPickerController.title = @"Pick Friends";
			[friendPickerController loadData];
			
			// Use the modal wrapper method to display the picker.
			[friendPickerController presentModallyFromViewController:self animated:YES handler:
			 ^(FBViewController *sender, BOOL donePressed) {
				 if (!donePressed)
					 return;
				 
				 NSString *message;
				 
				 if (friendPickerController.selection.count == 0)
					 message = @"<No Friends Selected>";
				 
				 else {
					 
					 NSMutableString *text = [[NSMutableString alloc] init];
					 
					 // we pick up the users from the selection, and create a string that we use to update the text view
					 // at the bottom of the display; note that self.selection is a property inherited from our base class
					 for (id<FBGraphUser> user in friendPickerController.selection) {
						 if ([text length])
							 [text appendString:@", "];
						 
						 [text appendString:user.name];
						 
						 [SNFacebookCaller postMessageToFriendTimeline:user.id message:@"You've been invited to Assembly"];
					 }
					 
					 message = text;
				 }
			 }];
			
		} else if (indexPath.row == 1) {
			[[FBSession activeSession] closeAndClearTokenInformation];
		
		} else if (indexPath.row == 2) {
			
		}
		
	} else {
		SNNetworkAppVO *vo = (SNNetworkAppVO *)[_topicsList objectAtIndex:indexPath.row];
		[SNAppDelegate openWithAppStore:[NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%@?mt=8", vo.appStoreID]];
		NSLog(@"OPEN APP:[%@]", [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%@?mt=8", vo.appStoreID]);
		
		/*
		[_topicTimelineView removeFromSuperview];
		_topicTimelineView = nil;
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			
		} completion:^(BOOL finished) {
			_topicTimelineView = [[SNTopicTimelineView alloc] initWithTopicVO:(SNTopicVO *)[_topicsList objectAtIndex:indexPath.row]];
			[_holderView addSubview:_topicTimelineView];
			
			NSError *error;
			if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/topics/%@", ((SNTopicVO *)[_topicsList objectAtIndex:indexPath.row]).title] withError:&error])
				NSLog(@"error in trackPageview");
			
			[UIView animateWithDuration:0.33 animations:^(void) {
				_topicTimelineView.frame = CGRectMake(0.0, 0.0, _holderView.frame.size.width, _holderView.frame.size.height);
				_shadowImgView.frame = CGRectMake(-19.0, 0.0, _shadowImgView.frame.size.width, _shadowImgView.frame.size.height);
				
			} completion:^(BOOL finished) {
				_topicsTableView.contentOffset = CGPointZero;
				[_topicTimelineView interactionEnabled:YES];
			}];
		}];
		 */
	}
}


#pragma mark - MailComposeViewController Delegates
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	switch (result) {
		case MFMailComposeResultCancelled:
			break;
			
		case MFMailComposeResultSaved:
			//[alert show];
			break;
			
		case MFMailComposeResultSent:			
			_shareRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kArticlesAPI]]];
			[_shareRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
			[_shareRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
			[_shareRequest setPostValue:[NSString stringWithFormat:@"%d", _articleVO.article_id] forKey:@"articleID"];
			[_shareRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"typeID"];
			[_shareRequest setDelegate:self];
			[_shareRequest startAsynchronous];
			break;
			
		case MFMailComposeResultFailed:
			break;
			
		default:
			break;
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - MessageCompose Deleagtes
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	//NSLog(@"didFinishWithResult:[%@]", result);
	
	if (result == MessageComposeResultCancelled) {
		//UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Assembly" message:@"Message Cancelled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		//[alertView show];
	
	} else if (result == MessageComposeResultFailed) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Assembly" message:@"Send Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		
	} else if (result == MessageComposeResultSent) {
		//UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Assembly" message:@"Message Sent" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		//[alertView show];
	}
	
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNProfileArticlesViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	
	if ([request isEqual:_shareRequest]) {
		@autoreleasepool {
			NSError *error = nil;
			NSDictionary *sharedResult = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			
			if (error != nil)
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			else {
				NSLog(@"RESULT:%@", [sharedResult objectForKey:@"result"]);
			}
		}
	
	} else if ([request isEqual:_likeRequest]) {
		NSError *error = nil;
		NSDictionary *parsedLike = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			_articleVO.totalLikes = [[parsedLike objectForKey:@"likes"] intValue];
			NSString *likeImg = (_articleVO.hasLiked) ? @"leftBottomUIB_Active.png" : @"";
			[_likeButton setBackgroundImage:[UIImage imageNamed:likeImg] forState:UIControlStateNormal];
			
			NSString *likeCaption = (_articleVO.hasLiked) ? @"Liked" : @"Like";			
			[_likeButton setTitle:likeCaption forState:UIControlStateNormal];
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}


@end