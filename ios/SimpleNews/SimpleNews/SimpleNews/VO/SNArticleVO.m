//
//  SNArticleVO.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 03.13.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleVO.h"
#import "SNReactionVO.h"

@implementation SNArticleVO

@synthesize dictionary;
@synthesize article_id, type_id, title, article_url, short_url, twitterName, twitterInfo, twitterHandle, tweet_id, tweetMessage, content, bgImage_url, articleSource, video_url, avatarImage_url, isDark, added, reactions;

+(SNArticleVO *)articleWithDictionary:(NSDictionary *)dictionary {
	
	SNArticleVO *vo = [[SNArticleVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.article_id = [[dictionary objectForKey:@"article_id"] intValue];
	vo.type_id = [[dictionary objectForKey:@"type_id"] intValue];
	vo.title = [dictionary objectForKey:@"title"];
	vo.tweet_id = [dictionary objectForKey:@"tweet_id"];
	vo.article_url = [dictionary objectForKey:@"article_url"];
	vo.short_url = [dictionary objectForKey:@"short_url"];
	vo.twitterName = [dictionary objectForKey:@"twitter_name"];
	vo.twitterInfo = [dictionary objectForKey:@"twitter_info"];
	vo.twitterHandle = [dictionary objectForKey:@"twitter_handle"];
	vo.tweetMessage = [dictionary objectForKey:@"tweet_msg"]; 
	vo.content = [dictionary objectForKey:@"content"];
	vo.bgImage_url = [dictionary objectForKey:@"bg_url"];
	vo.articleSource = [dictionary objectForKey:@"source"];
	vo.video_url = [dictionary objectForKey:@"video_url"];
	vo.avatarImage_url = [dictionary objectForKey:@"avatar_url"];
	vo.isDark = (BOOL)([[dictionary objectForKey:@"is_dark"] isEqualToString:@"Y"]);
	vo.reactions = [NSMutableArray new];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	vo.added = [dateFormat dateFromString:[dictionary objectForKey:@"added"]];
	[dateFormat release];
	
	for (NSDictionary *reaction in [dictionary objectForKey:@"reactions"])
		[vo.reactions addObject:[SNReactionVO reactionWithDictionary:reaction]];
	
	return (vo);
}

-(void)dealloc {
	self.dictionary = nil;
	self.title = nil;
	self.tweet_id = nil;
	self.twitterName = nil;
	self.twitterHandle = nil;
	self.twitterInfo = nil;
	self.tweetMessage = nil;
	self.content = nil;
	self.bgImage_url = nil;
	self.articleSource = nil;
	self.avatarImage_url = nil;
	self.video_url = nil;
	self.added = nil;
	self.reactions = nil;
	
	[super dealloc];
}

@end
