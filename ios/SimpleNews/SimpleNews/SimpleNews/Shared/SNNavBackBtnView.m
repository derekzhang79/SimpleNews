//
//  SNNavBackBtnView.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.03.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNNavBackBtnView.h"

@implementation SNNavBackBtnView

@synthesize btn = _btn;

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_btn = [UIButton buttonWithType:UIButtonTypeCustom];
		_btn.frame = CGRectMake(-1.0, -1.0, frame.size.width, frame.size.height);
		[_btn setBackgroundImage:[UIImage imageNamed:@"backArrowButton_nonActive.png"] forState:UIControlStateNormal];
		[_btn setBackgroundImage:[UIImage imageNamed:@"backArrowButton_Active.png"] forState:UIControlStateHighlighted];		
		[self addSubview:_btn];
	}
	
	return (self);
}

@end
