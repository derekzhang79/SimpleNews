//
//  SNTopicTimelineView_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.18.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "ASIFormDataRequest.h"
#import "EGORefreshTableHeaderView.h"
#import "EGOImageView.h"
#import "MBProgressHUD.h"

#import "SNTopicVO.h"
#import "SNArticleVideoPlayerView_iPhone.h"

@interface SNTopicTimelineView_iPhone : UIView <MFMailComposeViewControllerDelegate, UIScrollViewDelegate, ASIHTTPRequestDelegate, EGORefreshTableHeaderDelegate, EGOImageViewDelegate> {
	NSMutableArray *_articles;
	ASIFormDataRequest *_articlesRequest;
	ASIFormDataRequest *_updateRequest;
	EGORefreshTableHeaderView *_refreshHeaderView;
	MBProgressHUD *_progressHUD;
	
	BOOL _reloading;
	
	UIScrollView *_scrollView;
	UIButton *_fullscreenShareButton;
	
	NSMutableArray *_cardViews;
	NSMutableArray *_timelineTweets;
	
	SNArticleVO *_articleVO;
	SNTopicVO *_vo;
	SNArticleVideoPlayerView_iPhone *_videoPlayerView;
	
	NSDate *_lastDate;
	int _lastID;
}

-(id)initWithPopularArticles;
-(id)initWithTopicVO:(SNTopicVO *)vo;


@end
