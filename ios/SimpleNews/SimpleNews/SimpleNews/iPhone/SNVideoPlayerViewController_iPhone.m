//
//  SNVideoPlayerViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNVideoPlayerViewController_iPhone.h"
#import "SNAppDelegate.h"
#import "UIImage+StackBlur.h"

@implementation SNVideoPlayerViewController_iPhone

@synthesize mpc;

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_orientedLandscape:) name:@"ORIENTED_LANDSCAPE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_orientedPortrait:) name:@"ORIENTED_PORTRAIT" object:nil];
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startPlayback:) name:@"START_VIDEO_PLAYBACK" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_togglePlayback:) name:@"TOGGLE_VIDEO_PLAYBACK" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startScrubbing:) name:@"START_VIDEO_SCRUB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_stopScrubbing:) name:@"STOP_VIDEO_SCRUB" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_ffScrub:) name:@"FF_VIDEO_TIME" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_rrScrub:) name:@"RR_VIDEO_TIME" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_itemTapped:) name:@"ITEM_TAPPED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changeVideo:) name:@"CHANGE_VIDEO" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playbackStateChangedCallback:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadStateChangedCallback:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playingChangeCallback:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

-(void)loadView {
	[super loadView];
	
	_videoHolderView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_videoHolderView];
	
	_overlayHolderView = [[UIView alloc] initWithFrame:self.view.frame];
	_overlayHolderView.hidden = YES;
	[self.view addSubview:_overlayHolderView];
	
	_overlayImgView = [[EGOImageView alloc] initWithFrame:self.view.frame];
	_overlayImgView.alpha = 0.33;
	_overlayImgView.image = [_overlayImgView.image stackBlur:4];
	[_overlayHolderView addSubview:_overlayImgView];
	
	/*
	 UIImage *thumbImage = [_playerController thumbnailImageAtTime:10.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
	 if (thumbImage == nil)
	 NSLog(@"NO THUMB!!");
	 
	 else {
	 UIImageView *thumbImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 360.0, 1280.0, 720.0)] autorelease];
	 thumbImageView.image = thumbImage;
	 //[self addSubview:thumbImageView];
	 }
	 */
	
	_isFirst = YES;
}


-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}

//-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//	NSLog(@"ORIENTATION:[%d]", interfaceOrientation);
//	return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft));
//}


-(void)setupMPC {
	NSLog(@"----[PLAYER SETUP]----(%@)", _videoURL);
	
	//MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Jurassic Park - Dodson & Nedry" ofType:@"mp4"]]];
	MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:_videoURL]];;
	self.mpc = mp;
	[mp release];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_startedCallback:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vcFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	
	self.mpc.controlStyle = MPMovieControlStyleDefault;
	self.mpc.view.frame = self.view.frame;
	self.mpc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.mpc.shouldAutoplay = YES;
	self.mpc.allowsAirPlay = YES;
	self.mpc.movieSourceType = MPMovieSourceTypeFile;
	[self.mpc prepareToPlay];
	[self.mpc setFullscreen:YES];
	//self.mpc.view.hidden = YES;
	
	[_videoHolderView addSubview:self.mpc.view];
	
	_overlayImgView.imageURL = [NSURL URLWithString:_vo.thumb_url];
	_overlayImgView.image = [_overlayImgView.image stackBlur:8];
	
	_hud = [MBProgressHUD showHUDAddedTo:_overlayHolderView animated:YES];
	_hud.labelFont = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	_hud.labelText = @"Loading…";
	_hud.dimBackground = NO;
	
	if (!_isFirst)
		_overlayHolderView.hidden = NO;
}


-(void)_startedCallback:(NSNotification *)notification {
	NSLog(@"----[STARTED PLAYBACK]----");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
	
	_duration = -1.0;
	_isFinished = NO;
	
	_isFirst = NO;
	
	[_timer invalidate];
	_timer = nil;
	
	_timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_timerTick) userInfo:nil repeats:YES];
}

-(void)vcFinished:(NSNotification *)notification {
	NSLog(@"----[FINISHED PLAYBACK](%d)----", (self.mpc.currentPlaybackTime > self.mpc.duration - 1.5));
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	
	_isFinished = YES;
	
	[_timer invalidate];
	_timer = nil;
	
	[self.mpc.view removeFromSuperview];
	//[self setupMPC];
	
	if (self.mpc.currentPlaybackTime > self.mpc.duration - 1.5)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_ENDED" object:nil];
}

-(void)_loadStateChangedCallback:(NSNotification *)notification {
	NSLog(@"----[LOAD STATE CHANGED[%d]]----", self.mpc.loadState);
	
	switch (self.mpc.loadState) {
		case MPMovieLoadStatePlayable:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_DURATION" object:[NSNumber numberWithFloat:self.mpc.duration]];
			
			break;
			
		case 3:
			_overlayHolderView.hidden = YES;
			self.mpc.view.hidden = NO;
			
			if (_hud != nil) {
				[_hud removeFromSuperview];
				_hud = nil;
			}
			[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_SIZE" object:[NSNumber numberWithFloat:self.mpc.naturalSize.height]];
			break;
	}
}

-(void)_playbackStateChangedCallback:(NSNotification *)notification {
	NSLog(@"----[PLAYBACK STATE CHANGED[%d]]----", self.mpc.playbackState);	
}


-(void)_playingChangeCallback:(NSNotification *)notification {
	NSLog(@"----[PLAYING CHANGED[%d]]----", self.mpc.playbackState);
}


#pragma mark - Notification handlers
-(void)_startPlayback:(NSNotification *)notification {
	NSLog(@"START PLAYBACK");
	
	_videoURL = [notification object];
	[self setupMPC];
}

-(void)_togglePlayback:(NSNotification *)notification {
	NSLog(@"TOGGLE PLAYBACK(%d)", self.mpc.playbackState);
	
	
	switch (self.mpc.playbackState) {
		case MPMoviePlaybackStatePlaying:
			[self.mpc pause];
			break;
			
		case MPMoviePlaybackStatePaused:
			[self.mpc play];
			break;
			
		default:
			[self.mpc play];
			break;
	}
}

-(void)_itemTapped:(NSNotification *)notification {
	_vo = (SNVideoItemVO *)[notification object];
	NSLog(@"---ITEM TAPPED:[%@]---", _vo.video_title);
	
	[self.mpc stop];
	
	_overlayImgView.imageURL = [NSURL URLWithString:_vo.thumb_url];
	_overlayImgView.image = [_overlayImgView.image stackBlur:8];
	
	_hud = [MBProgressHUD showHUDAddedTo:_overlayHolderView animated:YES];
	_hud.labelFont = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	_hud.labelText = @"Loading…";
	_hud.dimBackground = NO;
	
	_overlayHolderView.hidden = NO;
	
	_isPaused = YES;
	_isFinished = NO;
}

-(void)_changeVideo:(NSNotification *)notification {
	_vo = (SNVideoItemVO *)[notification object];
	NSLog(@"---CHANGE VIDEO:[%@]---", _vo.video_url);
	_videoURL = _vo.video_url;
	
	[self setupMPC];
}


-(void)_ffScrub:(NSNotification *)notification {
	NSLog(@"----FF SCRUB----");
	
	self.mpc.currentPlaybackTime++;
}

-(void)_rrScrub:(NSNotification *)notification {
	NSLog(@"----RR SCRUB----");
	
	self.mpc.currentPlaybackTime--;
}


-(void)_startScrubbing:(NSNotification *)notification {
	NSLog(@"----START SCRUBBING----");
	
	if (self.mpc.playbackState == MPMoviePlaybackStatePlaying)
		[self.mpc pause];
}

-(void)_stopScrubbing:(NSNotification *)notification {
	NSLog(@"----STOP SCRUBBING----");
	
	[self.mpc play];
}



-(void)_timerTick {
	NSLog(@"VIDEO POS:[%f/%f]", self.mpc.currentPlaybackTime, self.mpc.duration);
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_TIME" object:[NSNumber numberWithFloat:self.mpc.currentPlaybackTime]];
}


-(void)_orientedLandscape:(NSNotification *)notification {
	NSLog(@"LANDSCAPE");
	self.view.frame = CGRectMake(0.0, 0.0, 480.0, 320.0);
	_videoHolderView.frame = self.view.frame;
	self.mpc.view.frame = self.view.frame;
	_overlayHolderView.frame = self.view.frame;
	_overlayImgView.frame = self.view.frame;
	
}

-(void)_orientedPortrait:(NSNotification *)notification {
	self.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
}


@end
