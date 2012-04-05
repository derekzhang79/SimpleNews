//
//  SNInfluencerListViewCell_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SNInfluencerListViewCell_iPhone.h"

#import "SNAppDelegate.h"


@implementation SNInfluencerListViewCell_iPhone

@synthesize influencerVO = _influencerVO;


+(NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


-(id)init {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] cellReuseIdentifier]])) {
		_avatarImgView = [[[EGOImageView alloc] initWithFrame:CGRectMake(12.0, 9.0, 40.0, 40.0)] autorelease];
		_avatarImgView.layer.cornerRadius = 8.0;
		_avatarImgView.clipsToBounds = YES;
		_avatarImgView.layer.borderColor = [[UIColor colorWithWhite:0.671 alpha:1.0] CGColor];
		_avatarImgView.layer.borderWidth = 1.0;
		[self addSubview:_avatarImgView];
		
		_twitterNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(67.0, 20.0, 256.0, 20.0)] autorelease];
		_twitterNameLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14];
		_twitterNameLabel.textColor = [UIColor colorWithWhite:0.325 alpha:1.0];
		_twitterNameLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_twitterNameLabel];
		
		UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 59.0, self.frame.size.width, 1.0)] autorelease];
		[lineView setBackgroundColor:[UIColor colorWithWhite:0.545 alpha:1.0]];
		[self addSubview:lineView];
	}
	
	return (self);
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - Accessors
- (void)setInfluencerVO:(SNInfluencerVO *)influencerVO {
	_influencerVO = influencerVO;
	
	_avatarImgView.imageURL = [NSURL URLWithString:_influencerVO.avatar_url];
	_twitterNameLabel.text = _influencerVO.influencer_name;
}

@end
