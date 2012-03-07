//
//  SNChannelGridViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//



#import "SNChannelGridViewController_iPhone.h"
#import "SNVideoItemVO.h"
#import "SNAppDelegate.h"
#import "SNChannelItemView_iPhone.h"

@interface SNChannelGridViewController_iPhone()
-(NSUInteger)screenNumber;
-(void)_resetToTop;
@end

@implementation SNChannelGridViewController_iPhone

-(NSUInteger)screenNumber {
	NSUInteger  result      = 1;
	UIWindow    *_window    = nil;
	UIScreen    *_screen    = nil;
	NSArray     *_screens   = nil;
	
	_screens = [UIScreen screens];
	
	if ([_screens count] > 1) {
		_window = [self.view window];
		_screen = [_window screen];
		
		if (_screen) {
			for (int i=0; i<[_screens count]; ++i){
				NSLog(@"TEST SCREEN #%d", i);
				UIScreen *_currentScreen = [_screens objectAtIndex:i];
				
				if (_currentScreen == _screen)
					result = i + 1;
			}
		}
	}
	
	return (result);
}


-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_optionsReturn:) name:@"OPTIONS_RETURN" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_detailsReturn:) name:@"DETAILS_RETURN" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_channelTapped:) name:@"CHANNEL_TAPPED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoDuration:) name:@"VIDEO_DURATION" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_nextVideo:) name:@"NEXT_VIDEO" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changeVideo:) name:@"CHANGE_VIDEO" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_cancelReset:) name:@"CANCEL_RESET" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_searchEntered:) name:@"SEARCH_ENTERED" object:nil];
		
		_videoItems = [NSMutableArray new];
		_channels = [NSMutableArray new];
		_itemViews = [NSMutableArray new];
		_isDetails = NO;
		_isOptions = NO;
		_scrollOffset = 0;
		_playingIndex = 0;
		
		//NSLog(@"USER INTERFACE:[%d]", _userInterfaceIdiom); 0 == iPhone // 1 == iPad
		
		NSString *testVideoItemsPath = [[NSBundle mainBundle] pathForResource:@"video_items" ofType:@"plist"];
		NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:testVideoItemsPath] options:NSPropertyListImmutable format:nil error:nil];
		
		for (NSDictionary *testVideoItem in plist)
			[_videoItems addObject:[SNVideoItemVO videoItemWithDictionary:testVideoItem]];
		
		
		NSString *testChannelItemsPath = [[NSBundle mainBundle] pathForResource:@"channels" ofType:@"plist"];
		NSDictionary *channelsPlist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:testChannelItemsPath] options:NSPropertyListImmutable format:nil error:nil];
		
		for (NSDictionary *testChannelItem in channelsPlist)
			[_channels addObject:[SNChannelVO channelWithDictionary:testChannelItem]];
		
		
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"START_VIDEO_PLAYBACK" object:((SNVideoItemVO *)[_videoItems objectAtIndex:0]).video_url];
	}
	
	return (self);
}

-(void)dealloc {
	[_scrollView release];
	
	[super dealloc];
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


/*
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	NSLog(@"ORIENTATION:[%d]", interfaceOrientation);
	
	
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ORIENTED_PORTRAIT" object:nil];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_tableView.frame = CGRectMake(-self.view.bounds.size.width, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height);
			_playingListViewController.view.frame = CGRectMake(0.0, _playingListViewController.view.frame.origin.y, _playingListViewController.view.bounds.size.width, _playingListViewController.view.frame.size.height);
			_isDetails = YES;
			
		} completion:nil];
		
	} else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ORIENTED_LANDSCAPE" object:nil];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_tableView.frame = CGRectMake(-self.view.bounds.size.width, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height);
			_playingListViewController.view.frame = CGRectMake(0.0, _playingListViewController.view.frame.origin.y, _playingListViewController.view.bounds.size.width, _playingListViewController.view.frame.size.height);
			_isDetails = YES;
			
		} completion:nil];
	}
	
	
	return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft));
}
*/

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	NSLog(@"SCREEN:[%d]", [self screenNumber]);
	
	if ([self screenNumber] == 1)
		[self.view setBackgroundColor:[UIColor colorWithWhite:0.145 alpha:1.0]];
	
	else
		[self.view setBackgroundColor:[UIColor greenColor]];
	
	_holderView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
	[self.view addSubview:_holderView];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height - _holderView.frame.origin.y)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.opaque = YES;
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = NO;
	_scrollView.delegate = self;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.alwaysBounceVertical = NO;
	_scrollView.contentSize = self.view.frame.size;
	_scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0f, 0.0f, 0.0f);
	[_holderView addSubview:_scrollView];
	
	_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -_scrollView.bounds.size.height, self.view.frame.size.width, _scrollView.bounds.size.height)];
	_refreshHeaderView.delegate = self;
	[_scrollView addSubview:_refreshHeaderView];
	[_refreshHeaderView refreshLastUpdatedDate];
	
	_videoSearchView = [[SNVideoSearchView_iPhone alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 50.0)];
	[_scrollView addSubview:_videoSearchView];
	
	int tot = 0;
	for (SNChannelVO *vo in _channels) {
		SNChannelItemView_iPhone *itemView = [[[SNChannelItemView_iPhone alloc] initWithFrame:CGRectMake(80.0 * (tot % 4), 50.0 + (80.0 * (int)(tot / 4)), 80.0, 80.0) channelVO:vo] autorelease];
		[_itemViews addObject:itemView];
		[_scrollView addSubview:itemView];
		
		//NSLog(@"VIDEO ITEM:[%d] \"%@\"", vo.video_id, vo.video_title);
		tot++;
	}
	
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 1.0);
	
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_goSwipe:)];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[panRecognizer setDelegate:self];
	[_holderView addGestureRecognizer:panRecognizer];
	
	UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	[longPressRecognizer setNumberOfTouchesRequired:1];
	[longPressRecognizer setMinimumPressDuration:0.5];
	[longPressRecognizer setDelegate:self];
	[_holderView addGestureRecognizer:longPressRecognizer];
	
	_playingListViewController = [[SNPlayingListViewController_iPhone alloc] initWithVideos:_videoItems];
	_playingListViewController.view.frame = CGRectMake(self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height);
	[self.view addSubview:_playingListViewController.view];
	
	_optionsListView = [[SNOptionsListView_iPhone alloc] initWithFrame:CGRectMake(-self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.view addSubview:_optionsListView];
	
	[_playingListViewController offsetAtIndex:0];
	
	SNChannelVO *vo = (SNChannelVO *)[_channels objectAtIndex:0];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANNEL_TAPPED" object:vo];
	
	/*
	[UIView animateWithDuration:0.33 animations:^(void) {
		_scrollView.frame = CGRectMake(-self.view.bounds.size.width, _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.frame.size.height);
		_playingListViewController.view.frame = CGRectMake(0.0, _playingListViewController.view.frame.origin.y, _playingListViewController.view.bounds.size.width, _playingListViewController.view.frame.size.height);
		_isDetails = YES;
		
	} completion:^(BOOL finished) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_VIDEO" object:vo];
	}];
	*/
	/*
	SNVideoItemVO *vo = (SNVideoItemVO *)[_videoItems objectAtIndex:0];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ITEM_TAPPED" object:vo];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_scrollView.frame = CGRectMake(-self.view.bounds.size.width, _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.frame.size.height);
		_playingListViewController.view.frame = CGRectMake(0.0, _playingListViewController.view.frame.origin.y, _playingListViewController.view.bounds.size.width, _playingListViewController.view.frame.size.height);
		_isDetails = YES;
		
	} completion:^(BOOL finished) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_VIDEO" object:vo];
	}];
	*/
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_holderView.frame = CGRectMake(0.0, _holderView.frame.origin.y, self.view.bounds.size.width, self.view.bounds.size.height - _holderView.frame.origin.y);
	}];
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
-(void)_goOptions {
	_isOptions = YES;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_scrollView.frame = CGRectMake(self.view.bounds.size.width, _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.frame.size.height);
		_optionsListView.frame = CGRectMake(0.0, _optionsListView.frame.origin.y, self.view.bounds.size.width, _optionsListView.frame.size.height);
	}];
}

-(void)_goDetails {
	[SNAppDelegate playMP3:@"fpo_tapVideo"];
	_isDetails = YES;
	
	if (_playingIndex == [_videoItems count])
		_playingIndex = 0;
	
	_playingListViewController.view.hidden = NO;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ITEM_TAPPED" object:(SNVideoItemVO *)[_videoItems objectAtIndex:_playingIndex]];
	[_playingListViewController offsetAtIndex:_playingIndex];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_scrollView.frame = CGRectMake(-self.view.bounds.size.width, _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.frame.size.height);
		_playingListViewController.view.frame = CGRectMake(0.0, _playingListViewController.view.frame.origin.y, _playingListViewController.view.bounds.size.width, _playingListViewController.view.frame.size.height);
		
	} completion:^(BOOL finished) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_VIDEO" object:(SNVideoItemVO *)[_videoItems objectAtIndex:_playingIndex]];
	}];
}


#pragma mark - Interaction handlers
-(void)_goSwipe:(id)sender {
	CGPoint translatedPoint = [(UIPanGestureRecognizer *)sender translationInView:self.view];
	NSLog(@"SWIPE @:(%f)", translatedPoint.x);
	
	if (!_isDetails && !_isOptions) {	
		if (translatedPoint.x > 20.0 && abs(translatedPoint.y) < 20) {
			[self _goOptions];
		}
		
		if (translatedPoint.x < -20.0 && abs(translatedPoint.y) < 20) {
			[self _goDetails];
		}
	}
}

-(void)_goLongPress:(id)sender {
	CGPoint holdPt = [(UIPanGestureRecognizer*)sender locationInView:_holderView];
	holdPt.y = (_scrollView.contentOffset.y + holdPt.y);
}



#pragma mark - Notification handlers
-(void)_videoDuration:(NSNotification *)notification {
	[UIView animateWithDuration:0.25 animations:^(void) {
		self.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
	}];
}

-(void)_nextVideo:(NSNotification *)notification {
	_playingIndex++;
	
	if (_playingIndex == [_videoItems count])
		_playingIndex = 0;
	
	[_playingListViewController offsetAtIndex:_playingIndex];
	
	SNVideoItemVO *vo = (SNVideoItemVO *)[_videoItems objectAtIndex:_playingIndex];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ITEM_TAPPED" object:vo];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_VIDEO" object:vo];
}

-(void)_channelTapped:(NSNotification *)notification {
	SNChannelVO *vo = (SNChannelVO *)[notification object];
	
	[SNAppDelegate playMP3:@"fpo_tapVideo"];
	_playingIndex = vo.channel_id % 10;
}

-(void)_changeVideo:(NSNotification *)notification {
	SNVideoItemVO *vo = (SNVideoItemVO *)[notification object];
	_playingIndex = vo.video_id;
}


-(void)_optionsReturn:(NSNotification *)notification {
	_isOptions = NO;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_scrollView.frame = CGRectMake(0.0, _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.frame.size.height);
		_optionsListView.frame = CGRectMake(-self.view.bounds.size.width, _optionsListView.frame.origin.y, _optionsListView.frame.size.width, _optionsListView.frame.size.height);
	}];
}

-(void)_detailsReturn:(NSNotification *)notification {
	_isDetails = NO;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_scrollView.frame = CGRectMake(0.0, _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.frame.size.height);
		_playingListViewController.view.frame = CGRectMake(self.view.bounds.size.width, _playingListViewController.view.frame.origin.y, _playingListViewController.view.bounds.size.width, _playingListViewController.view.frame.size.height);
	} completion:^(BOOL finished) {
		_playingListViewController.view.hidden = YES;
	}];
}



-(void)_cancelReset:(NSNotification *)notificiation {
	NSLog(@"CANCEL");
}


-(void)_searchEntered:(NSNotification *)notification {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_scrollView.contentOffset = CGPointMake(0.0, 0.0);
		
	} completion:nil];
	
}



#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}


// called on start of dragging (may require some time and or distance to move)
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}


// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:_scrollView];
}


// called on finger up as we are moving
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
}

// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
}

// called when scroll view grinds to a halt
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}



-(void)_reloadData {
	_isReloading = YES;	
}

-(void)_doneLoadingData {
	_isReloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
}


-(void)_resetToTop {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_scrollView.contentOffset = CGPointMake(0.0, 0.0);
	}];
}


#pragma mark EGORefreshTableHeaderDelegate Methods
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
	
	//[self reloadData];
	[self performSelector:@selector(_doneLoadingData) withObject:nil afterDelay:1.33];
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
	return (_isReloading); // should return if data source model is reloading
}

-(NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
	return [NSDate date]; // should return date data source was last changed
}

@end