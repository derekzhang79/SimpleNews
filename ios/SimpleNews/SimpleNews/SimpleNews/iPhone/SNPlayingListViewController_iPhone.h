//
//  SNPlayingListViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.01.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNPlayingListViewController_iPhone : UIViewController <UIScrollViewDelegate> {
	
	UIScrollView *_scrollView;
	NSMutableArray *_videoItems;
	
}

-(id)initWithVideos:(NSMutableArray *)videos;
-(void)offsetAtIndex:(int)ind;

@end
