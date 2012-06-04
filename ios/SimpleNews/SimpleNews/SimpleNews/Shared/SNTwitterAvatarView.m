//
//  SNTwitterAvatarView.m
//  SimpleNews
//
//  Created by Sparkle Mountain iMac on 5/30/12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNTwitterAvatarView.h"
#import "MBLResourceLoader.h"

@interface SNTwitterAvatarView () <MBLResourceObserverProtocol>
@property(nonatomic, strong) MBLAsyncResource *imageResource;
@end

@implementation SNTwitterAvatarView

@synthesize imageResource = _imageResource;
@synthesize btn = _btn;


- (id)initWithPosition:(CGPoint)pos imageURL:(NSString *)url {
    if ((self = [super initWithFrame:CGRectMake(pos.x, pos.y, 26.0, 26.0)])) {
		_imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 26.0, 26.0)];
		[self addSubview:_imgView];
		
		_btn = [UIButton buttonWithType:UIButtonTypeCustom];
		_btn.frame = CGRectMake(0.0, 0.0, 26.0, 26.0);
		[_btn setBackgroundImage:[UIImage imageNamed:@"avatarCorners.png"] forState:UIControlStateNormal];
		[_btn setBackgroundImage:[UIImage imageNamed:@"avatarCorners.png"] forState:UIControlStateHighlighted];		
		[self addSubview:_btn];
		
		self.imageResource = [[MBLResourceLoader sharedInstance] downloadURL:url forceFetch:NO expiration:[NSDate dateWithTimeIntervalSinceNow:60.0 * 60.0 * 24.0]]; // 1 day expiration
    }
	
    return (self);
}


- (void)setImageResource:(MBLAsyncResource *)imageResource {
	if (_imageResource != nil) {
		[_imageResource unsubscribe:self];
		_imageResource = nil;
	}
	
	_imageResource = imageResource;
	
	if (_imageResource != nil)
		[_imageResource subscribe:self];
}


#pragma mark - AsyncResource Observers
- (void)resource:(MBLAsyncResource *)resource isAvailableWithData:(NSData *)data {
	//NSLog(@"MBLAsyncResource.data [%@]", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	_imgView.image = [UIImage imageWithData:data];
}

- (void)resource:(MBLAsyncResource *)resource didFailWithError:(NSError *)error {
	_imageResource = nil;
}






@end