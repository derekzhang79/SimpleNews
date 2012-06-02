//
//  SNProfileViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 05.04.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNProfileViewController_iPhone.h"

#import "SNHeaderView_iPhone.h"
#import "SNNavBackBtnView.h"
#import "SNProfileViewCell_iPhone.h"
#import "SNAppDelegate.h"
#import "SNTwitterAvatarView.h"
#import "SNWebPageViewController_iPhone.h"
#import "SNProfileArticlesViewController_iPhone.h"
#import "SNFindFriendsViewController_iPhone.h"

@implementation SNProfileViewController_iPhone
-(id)init {
	if ((self = [super init])) {
		_items = [NSMutableArray new];
	}
	
	return (self);
}


#pragma mark - View lifecycle

-(void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImgView.image = [UIImage imageNamed:@"background_plain.png"];
	[self.view addSubview:bgImgView];
	
	SNTwitterAvatarView *avatarImgView = [[SNTwitterAvatarView alloc] initWithPosition:CGPointMake(20.0, 68.0) imageURL:[SNAppDelegate twitterAvatar]];
	[[avatarImgView btn] addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:avatarImgView];
	
	UILabel *handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 72.0, 200.0, 16.0)];
	handleLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	handleLabel.textColor = [SNAppDelegate snLinkColor];
	handleLabel.backgroundColor = [UIColor clearColor];
	handleLabel.text = [NSString stringWithFormat:@"@%@", [SNAppDelegate twitterHandle]];
	[self.view addSubview:handleLabel];
	
	UIButton *handleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	handleButton.frame = handleLabel.frame;
	[handleButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:handleButton];
	
	UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
	profileButton.frame = CGRectMake(266.0, 59.0, 44.0, 44.0);
	[profileButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive.png"] forState:UIControlStateNormal];
	[profileButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active.png"] forState:UIControlStateHighlighted];
	[profileButton addTarget:self action:@selector(_goTwitterProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:profileButton];
	
	UIImageView *statsBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 108.0, 320.0, 84.0)];
	statsBgView.image = [UIImage imageNamed:@"profileBackgroundStats.png"];
	[self.view addSubview:statsBgView];
	
	_commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 23.0, 96.0, 18.0)];
	_commentsLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:18];
	_commentsLabel.textAlignment = UITextAlignmentCenter;
	_commentsLabel.textColor = [UIColor blackColor];
	_commentsLabel.backgroundColor = [UIColor clearColor];
	[statsBgView addSubview:_commentsLabel];
	
	UILabel *commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 43.0, 96.0, 18.0)];
	commentsLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	commentsLabel.textAlignment = UITextAlignmentCenter;
	commentsLabel.textColor = [SNAppDelegate snLinkColor];
	commentsLabel.backgroundColor = [UIColor clearColor];
	commentsLabel.text = @"Comments";
	[statsBgView addSubview:commentsLabel];
	
	_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(111.0, 23.0, 96.0, 18.0)];
	_likesLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:18];
	_likesLabel.textAlignment = UITextAlignmentCenter;
	_likesLabel.textColor = [UIColor blackColor];
	_likesLabel.backgroundColor = [UIColor clearColor];
	[statsBgView addSubview:_likesLabel];
	
	UILabel *likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(111.0, 43.0, 96.0, 18.0)];
	likesLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	likesLabel.textAlignment = UITextAlignmentCenter;
	likesLabel.textColor = [SNAppDelegate snLinkColor];
	likesLabel.backgroundColor = [UIColor clearColor];
	likesLabel.text = @"Likes";
	[statsBgView addSubview:likesLabel];
	
	_sharesLabel = [[UILabel alloc] initWithFrame:CGRectMake(211.0, 23.0, 96.0, 18.0)];
	_sharesLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:18];
	_sharesLabel.textAlignment = UITextAlignmentCenter;
	_sharesLabel.textColor = [UIColor blackColor];
	_sharesLabel.backgroundColor = [UIColor clearColor];
	[statsBgView addSubview:_sharesLabel];
	
	UILabel *sharesLabel = [[UILabel alloc] initWithFrame:CGRectMake(211.0, 43.0, 96.0, 18.0)];
	sharesLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	sharesLabel.textAlignment = UITextAlignmentCenter;
	sharesLabel.textColor = [SNAppDelegate snLinkColor];
	sharesLabel.backgroundColor = [UIColor clearColor];
	sharesLabel.text = @"Shares";
	[statsBgView addSubview:sharesLabel];
	
	UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	likeButton.frame = CGRectMake(12.0, 115.0, 96.0, 70.0);
	[likeButton addTarget:self action:@selector(_goLikedArticles) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:likeButton];
	 
	UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	commentButton.frame = CGRectMake(108.0, 115.0, 96.0, 70.0);
	[commentButton addTarget:self action:@selector(_goCommentedArticles) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:commentButton];
	 
	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.frame = CGRectMake(204.0, 115.0, 96.0, 70.0);
	[shareButton addTarget:self action:@selector(_goSharedArticles) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:shareButton];
	
	UIImageView *tableBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 186.0, 320.0, self.view.frame.size.height - 267.0)];
	UIImage *img = [UIImage imageNamed:@"profileBackground.png"];
	tableBgView.image = [img stretchableImageWithLeftCapWidth:0.0 topCapHeight:10.0];
	[self.view addSubview:tableBgView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(12.0, 186.0, self.view.frame.size.width - 24.0, self.view.frame.size.height - 267.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 70.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.alwaysBounceVertical = NO;
	_tableView.bounces = NO;
	[self.view addSubview:_tableView];
	
	SNHeaderView_iPhone *headerView = [[SNHeaderView_iPhone alloc] initWithTitle:@"Profile"];
	[self.view addSubview:headerView];
	
	SNNavBackBtnView *backBtnView = [[SNNavBackBtnView alloc] initWithFrame:CGRectMake(0.0, 0.0, 64.0, 44.0)];
	[[backBtnView btn] addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backBtnView];
	
	NSString *profilePath = [[NSBundle mainBundle] pathForResource:@"profile" ofType:@"plist"];
	NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:profilePath] options:NSPropertyListImmutable format:nil error:nil];
	
	for (NSDictionary *item in plist)
		[_items addObject:[SNProfileVO profileWithDictionary:item]];
	
	NSLog(@"USERID:[%@]", [[SNAppDelegate profileForUser] objectForKey:@"id"]);
	
	ASIFormDataRequest *statsRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Users.php"]]];
	[statsRequest setPostValue:[NSString stringWithFormat:@"%d", 5] forKey:@"action"];
	[statsRequest setPostValue:[[SNAppDelegate profileForUser] objectForKey:@"id"] forKey:@"userID"];
	[statsRequest setDelegate:self];
	[statsRequest startAsynchronous];
}

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
-(void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)_goTwitterProfile {
	SNWebPageViewController_iPhone *webPageViewController = [[SNWebPageViewController_iPhone alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/#!/%@", [SNAppDelegate twitterHandle]]] title:[NSString stringWithFormat:@"@%@", [SNAppDelegate twitterHandle]]];
	[self.navigationController pushViewController:webPageViewController animated:YES];
}

-(void)_goNotificationsToggle:(UISwitch *)switchView {
	[SNAppDelegate notificationsToggle:switchView.on];
}

-(void)_goLikedArticles {
	[self.navigationController pushViewController:[[SNProfileArticlesViewController_iPhone alloc] initAsArticlesLiked] animated:YES];
}

-(void)_goCommentedArticles {
	[self.navigationController pushViewController:[[SNProfileArticlesViewController_iPhone alloc] initAsArticlesCommented] animated:YES];
}

-(void)_goSharedArticles {
	[self.navigationController pushViewController:[[SNProfileArticlesViewController_iPhone alloc] initAsArticlesShared] animated:YES];
}


#pragma mark - TableView DataSource Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_items count]);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SNProfileViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNProfileViewCell_iPhone cellReuseIdentifier]];
	
	if (cell == nil)
		cell = [[SNProfileViewCell_iPhone alloc] init];
	
	cell.profileVO = (SNProfileVO *)[_items objectAtIndex:indexPath.row];
	
	if (indexPath.row == 2) {
		UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
			
		if ([SNAppDelegate notificationsEnabled])
			switchView.on = YES;
			
		[switchView addTarget:self action:@selector(_goNotificationsToggle:) forControlEvents:UIControlEventValueChanged];
		cell.accessoryView = switchView;
			
	} else {
		UIImageView *chevronView = [[UIImageView alloc] initWithFrame:CGRectMake(260.0, 23.0, 24.0, 24.0)];
		chevronView.image = [UIImage imageNamed:@"chevron.png"];
		[cell addSubview:chevronView];
	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return (cell);
}


#pragma mark - TableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (70.0);
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//	return (53.0);
//}


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 2)
		return (nil);
	
	return (indexPath);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"SELECTED");
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	switch (indexPath.row) {
		case 0: // find friends
			[self.navigationController pushViewController:[[SNFindFriendsViewController_iPhone alloc] initAsFinder] animated:YES];
			break;
			
		case 1: // my friends
			[self.navigationController pushViewController:[[SNFindFriendsViewController_iPhone alloc] initAsList] animated:YES];
			break;
			
		default:
			break;
	}
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request { 
	NSLog(@"SNFriendProfileViewController_iPhone [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSDictionary *parsedStats = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			_likesLabel.text = [NSString stringWithFormat:@"%d", [[parsedStats objectForKey:@"likes"] intValue]];
			_commentsLabel.text = [NSString stringWithFormat:@"%d", [[parsedStats objectForKey:@"comments"] intValue]];
			_sharesLabel.text = [NSString stringWithFormat:@"%d", [[parsedStats objectForKey:@"shares"] intValue]];
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
