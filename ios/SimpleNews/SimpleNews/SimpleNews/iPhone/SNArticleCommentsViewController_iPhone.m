//
//  SNArticleCommentsViewController_iPhone.m
//  SimpleNews
//
//  Created by Matthew Holcombe on 04.15.12.
//  Copyright (c) 2012 Sparkle Mountain, LLC. All rights reserved.
//

#import "SNArticleCommentsViewController_iPhone.h"
#import "SNArticleCommentView_iPhone.h"
#import "SNHeaderView_iPhone.h"
#import "SNCommentVO.h"
#import "SNAppDelegate.h"

#define kItemHeight 56.0

@implementation SNArticleCommentsViewController_iPhone

-(id)initWithArticleVO:(SNArticleVO *)vo listID:(int)listID {
	if ((self = [super init])) {
		_vo = vo;
		_list_id = listID;
		
		_commentViews = [NSMutableArray new];
	}
	
	return (self);
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)dealloc {
	[super dealloc];
}

#pragma mark - View lifecycle
-(void)loadView {
	[super loadView];
	
	SNHeaderView_iPhone *headerView = [[[SNHeaderView_iPhone alloc] initWithTitle:_vo.title] autorelease];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	backButton.frame = CGRectMake(4.0, 4.0, 44.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	UIButton *reportButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	reportButton.frame = CGRectMake(272.0, 4.0, 44.0, 44.0);
	[reportButton setBackgroundImage:[UIImage imageNamed:@"reportButton_nonActive.png"] forState:UIControlStateNormal];
	[reportButton setBackgroundImage:[UIImage imageNamed:@"reportButton_Active.png"] forState:UIControlStateHighlighted];
	[reportButton addTarget:self action:@selector(_goReport) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:reportButton];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 53.0, self.view.frame.size.width, self.view.frame.size.height - 103.0)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[_scrollView setBackgroundColor:[UIColor whiteColor]];
	_scrollView.opaque = YES;
	_scrollView.scrollsToTop = NO;
	_scrollView.pagingEnabled = NO;
	_scrollView.delegate = self;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = YES;
	_scrollView.alwaysBounceVertical = NO;
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
	[self.view addSubview:_scrollView];
	
	_inputBgImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 50.0, self.view.frame.size.width, 50.0)] autorelease];
	_inputBgImgView.image = [UIImage imageNamed:@"inputFieldBG.png"];
	_inputBgImgView.userInteractionEnabled = YES;
	[self.view addSubview:_inputBgImgView];
	
	_commentTxtField = [[[UITextField alloc] initWithFrame:CGRectMake(23.0, 17.0, 270.0, 16.0)] autorelease];
	[_commentTxtField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_commentTxtField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_commentTxtField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[_commentTxtField setBackgroundColor:[UIColor clearColor]];
	[_commentTxtField setReturnKeyType:UIReturnKeyDone];
	[_commentTxtField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_commentTxtField.font = [[SNAppDelegate snAllerFontBold] fontWithSize:12];
	_commentTxtField.keyboardType = UIKeyboardTypeDefault;
	_commentTxtField.text = @"";
	_commentTxtField.delegate = self;
	[_inputBgImgView addSubview:_commentTxtField];
	
	_commentsLabel = [[UILabel alloc] initWithFrame:_commentTxtField.frame];
	_commentsLabel.font = [[SNAppDelegate snAllerFontBold] fontWithSize:12];
	_commentsLabel.textColor = [UIColor blackColor];
	_commentsLabel.backgroundColor = [UIColor clearColor];
	_commentsLabel.text = @"Comment";
	[_inputBgImgView addSubview:_commentsLabel];
	
	UIImageView *overlayImgView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	overlayImgView.image = [UIImage imageNamed:@"overlay.png"];
	[self.view addSubview:overlayImgView];
	
	_commentOffset = 0;
	for (SNCommentVO *vo in _vo.comments) {
		//NSLog(@"OFFSET:%d", offset);
		
		CGSize txtSize = [vo.content sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14] constrainedToSize:CGSizeMake(230.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		SNArticleCommentView_iPhone *commentView = [[[SNArticleCommentView_iPhone alloc] initWithFrame:CGRectMake(0.0, _commentOffset, _scrollView.frame.size.width, kItemHeight + txtSize.height) commentVO:vo listID:_list_id] autorelease];
		[_commentViews addObject:commentView];
		[_scrollView addSubview:commentView];
		
		_commentOffset += (kItemHeight + txtSize.height);
	}
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

-(void)_goReport {
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *mfViewController = [[MFMailComposeViewController alloc] init];
		mfViewController.mailComposeDelegate = self;
		[mfViewController setToRecipients:[NSArray arrayWithObject:@"abuse@getassembly.com"]];
		[mfViewController setSubject:[NSString stringWithFormat:@"Report Abuse - %@", _vo.title]];
		[mfViewController setMessageBody:@"There's inappropriate comments in this article." isHTML:NO];
		
		[self presentViewController:mfViewController animated:YES completion:nil];
		[mfViewController release];
		
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status:" message:@"Your phone is not currently configured to send mail." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
		
		[alert show];
		[alert release];
	}
}

-(void)_onTxtDoneEditing:(id)sender {
	[sender resignFirstResponder];
	
	//_titleLabel.text = _titleInputTxtField.text;
	//_commentLabel.text = _commentInputTxtView.text;
	
	//_holderView.hidden = NO;
	//_txtInputView.hidden = YES;
}

#pragma mark - ScrollView Delegates
// any offset changes
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {	
}


// called on start of dragging (may require some time and or distance to move)
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}


// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{	
}


// called on finger up as we are moving
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
}

// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
}

// called when scroll view grinds to a halt
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	_commentsLabel.hidden = YES;
	
	if (![SNAppDelegate twitterHandle])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^(void){
		//_scrollView.contentOffset = CGPointMake(0.0, _scrollView.contentSize.height - 250.0);
		_inputBgImgView.frame = CGRectMake(_inputBgImgView.frame.origin.x, _inputBgImgView.frame.origin.y - 215.0, _inputBgImgView.frame.size.width, _inputBgImgView.frame.size.height);
	} completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	if ([textField.text length] > 0) {
		_commentSubmitRequest = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, @"Articles.php"]]] retain];
		[_commentSubmitRequest setPostValue:[NSString stringWithFormat:@"%d", 9] forKey:@"action"];
		[_commentSubmitRequest setPostValue:[SNAppDelegate twitterHandle] forKey:@"handle"];
		[_commentSubmitRequest setPostValue:[NSString stringWithFormat:@"%d", _vo.article_id] forKey:@"articleID"];
		[_commentSubmitRequest setPostValue:[NSString stringWithFormat:@"%d", _list_id] forKey:@"listID"];
		[_commentSubmitRequest setPostValue:textField.text forKey:@"content"];
		
		[_commentSubmitRequest setTimeOutSeconds:30];
		[_commentSubmitRequest setDelegate:self];
		[_commentSubmitRequest startAsynchronous];
		
		NSLog(@"USER:%d, ARTICLE:%d, LIST:%d, CONTENT:%@", 1, _vo.article_id, _list_id, textField.text);
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		NSString *added = [dateFormatter stringFromDate:[NSDate date]];
		[dateFormatter release];
		
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
									 @"0", @"comment_id",
									 [SNAppDelegate twitterAvatar], @"thumb_url", 
									 [SNAppDelegate twitterHandle], @"handle", 
									 [[SNAppDelegate profileForUser] objectForKey:@"name"], @"name", 
									 [NSString stringWithFormat:@"https://twitter.com/#!/%@", [SNAppDelegate twitterHandle]], @"user_url", 
									 @"", @"comment_url", 
									 added, @"added",  
									 textField.text, @"content", nil];
		SNCommentVO *vo = [SNCommentVO commentWithDictionary:dict];
		[_vo.comments addObject:vo];
		
		CGSize commentSize = [textField.text sizeWithFont:[[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:14] constrainedToSize:CGSizeMake(256.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		SNArticleCommentView_iPhone *commentView = [[[SNArticleCommentView_iPhone alloc] initWithFrame:CGRectMake(0.0, _commentOffset, _scrollView.frame.size.width, kItemHeight + commentSize.height) commentVO:vo listID:_list_id] autorelease];
		[_commentViews addObject:commentView];
		[_scrollView addSubview:commentView];
		
		_commentOffset += (kItemHeight + commentSize.height);
		
		textField.text = @"";
		
		CGSize size = _scrollView.contentSize;
		size.height += (kItemHeight + commentSize.height);
		
		_scrollView.contentSize = size;
	}
	
	_commentsLabel.hidden = NO;
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^(void){
		_inputBgImgView.frame = CGRectMake(_inputBgImgView.frame.origin.x, _inputBgImgView.frame.origin.y + 215.0, _inputBgImgView.frame.size.width, _inputBgImgView.frame.size.height);
	} completion:nil];
}


#pragma mark - MailComposeViewController Delegates
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status:" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
	
	switch (result) {
		case MFMailComposeResultCancelled:
			alert.message = @"Message Canceled";
			break;
			
		case MFMailComposeResultSaved:
			alert.message = @"Message Saved";
			[alert show];
			break;
			
		case MFMailComposeResultSent:
			alert.message = @"Message Sent";
			break;
			
		case MFMailComposeResultFailed:
			alert.message = @"Message Failed";
			[alert show];
			break;
			
		default:
			alert.message = @"Message Not Sent";
			[alert show];
			break;
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
	
	
	[alert release];
}


@end
