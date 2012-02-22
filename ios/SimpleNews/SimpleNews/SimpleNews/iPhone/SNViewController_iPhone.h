//
//  SNViewController_iPhone.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 02.20.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "SNActiveListViewController_iPhone.h"
#import "SNCategoryListView_iPhone.h"

@interface SNViewController_iPhone : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
	UIUserInterfaceIdiom _userInterfaceIdiom;
	
	UIScrollView *_scrollView;
	SNActiveListViewController_iPhone *_activeListViewController;
	
	NSMutableArray *_videoItems;
	NSMutableArray *_itemViews;
	
	BOOL _isSwiped;
	SNCategoryListView_iPhone *_categoryListView;
}

-(id)initWithUserInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom;

@end
