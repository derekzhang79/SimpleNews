//
//  SNTwitterCaller.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.24.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>


@interface SNTwitterCaller : NSObject

+(SNTwitterCaller *) sharedInstance;
-(void)userTimeline;
-(void)writeProfile;
-(void)sendImageTweet:(UIImage *)img message:(NSString *)msg;
-(void)sendTextTweet:(NSString *)msg;

@property (strong, nonatomic) ACAccountStore *accountStore; 
@property (strong, nonatomic) NSArray *accounts;
@property (strong, nonatomic) ACAccount *account;
@property (strong, nonatomic) id timeline;
@end
