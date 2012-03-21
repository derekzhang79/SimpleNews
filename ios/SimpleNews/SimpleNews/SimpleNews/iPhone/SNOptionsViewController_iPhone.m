//
//  SNOptionsViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.16.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNOptionsViewController_iPhone.h"

#import "SNOptionItemView_iPhone.h"
#import "SNOptionVO.h"

#import "SNAppDelegate.h"

@implementation SNOptionsViewController_iPhone

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_optionSelected:) name:@"OPTION_SELECTED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_optionDeselected:) name:@"OPTION_DESELECTED" object:nil];
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"OPTION_SELECTED" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"OPTION_DESELECTED" object:nil];
	
	[super dealloc];
}


#pragma mark - View lifecycle

-(void)loadView {
	[super loadView];
	
	[self.view setBackgroundColor:[UIColor colorWithWhite:0.145 alpha:1.0]];
	
	_optionViews = [[NSMutableArray alloc] init];
	_optionVOs = [[NSMutableArray alloc] init];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 56.0, self.view.frame.size.width, self.view.frame.size.height)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.opaque = NO;
	_scrollView.scrollsToTop = YES;
	_scrollView.pagingEnabled = NO;
	_scrollView.delegate = self;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.alwaysBounceVertical = YES;
	_scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0f, 0.0f, 0.0f);
	_scrollView.contentOffset = CGPointMake(0.0, 0.0);
	_scrollView.contentSize = self.view.frame.size;
	[self.view addSubview:_scrollView];
	
	NSString *testOptionsPath = [[NSBundle mainBundle] pathForResource:@"options" ofType:@"plist"];
	NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:testOptionsPath] options:NSPropertyListImmutable format:nil error:nil];
	
	int cnt = 0;
	for (NSDictionary *testOption in plist) {
		SNOptionVO *vo = [SNOptionVO optionWithDictionary:testOption];
		SNOptionItemView_iPhone *itemView = [[[SNOptionItemView_iPhone alloc] initWithFrame:CGRectMake(0.0, cnt * 64, self.view.frame.size.width, 64) withVO:vo] autorelease];
		
		if (vo.option_id == 2 && [SNAppDelegate notificationsEnabled])
			[itemView toggleSelected:YES];
		
		[_optionViews addObject:itemView];
		[_optionVOs addObject:vo];
		[_scrollView addSubview:itemView];
		cnt++;
	}
	
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, cnt * 64);
	
	
	UIButton *backButton = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
	backButton.frame = CGRectMake(250.0, 12.0, 64.0, 34.0);
	[backButton setBackgroundImage:[[UIImage imageNamed:@"backButton_nonActive.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[[UIImage imageNamed:@"backButton_Active.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	backButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12.0];
	backButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	backButton.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	backButton.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	[backButton setTitle:@"Done" forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_goSwipe:)];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[panRecognizer setDelegate:self];
	//[self.view addGestureRecognizer:panRecognizer];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}



#pragma mark - Navigation
-(void)_goBack {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"OPTIONS_RETURN" object:nil];
	[self dismissModalViewControllerAnimated:YES];
}


-(void)_goSwipe:(id)sender {
	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
	NSLog(@"SWIPE @:(%f, %d)", translatedPoint.x, abs(translatedPoint.y));
	
	
	//if (translatedPoint.x < -20 && abs(translatedPoint.y) < 30) {
	//	[self _goBack];
	//}
}


#pragma mark - Notification handlers

-(void)_optionSelected:(NSNotification *)notification {
	SNOptionVO *vo = (SNOptionVO *)[notification object];
 
	if (vo.option_id == 2) {
		[SNAppDelegate notificationsToggle:YES];
 	}
}

-(void)_optionDeselected:(NSNotification *)notification {
	SNOptionVO *vo = (SNOptionVO *)[notification object];
	
	if (vo.option_id == 2) {
		[SNAppDelegate notificationsToggle:NO];
 	}
}

@end
