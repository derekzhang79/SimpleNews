//
//  SNTwitterUserVO.h
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.01.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNTwitterUserVO : NSObject

+(SNTwitterUserVO *)twitterUserWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int userID;
@property (nonatomic, retain) NSString *twitterID;
@property (nonatomic, retain) NSString *handle;
@property (nonatomic, retain) NSString *avatarURL;
@property (nonatomic, retain) NSString *name;

@end
