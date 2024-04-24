#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FeedReaction
- (void) didTapReactionButton:(id)sender;
@end

@interface FollowButton
@property (nonatomic, assign, readwrite) UILabel *titleLabel;
@property (nonatomic, assign, readwrite) CGRect frame;
@property (nonatomic, assign, readwrite) NSArray *subviews;
@end

@interface MainComment
- (void) addReactionButtonTap;
@end

@interface NoteText : UIView
@property (nonatomic, assign, readwrite) UIView *superview;
@end

@interface QueueSearch : UITextField
@property (nonatomic, assign, readwrite) UIView *superview;
@end

@interface SearchUser
- (void) handleFollowButtonTap;
@end

@interface SearchUserCollection
//todo: find a bypass for whatever is wrong w/ this - (void) buttonTapped;
@end

@interface SuggestedFriend
- (void) followButtonTapped:(id)sender;
@end

int autoFollowMode = 0;
bool smartFollowMode = NO; // not really "smart" just safe
bool iqBot = NO; // slow, but works.. watch a movie?


%hook BadgeCounter
- (void) layoutSubviews {
	id badgeCounterItem = MSHookIvar<id>(self, "pinnedBadgeView");
	UILabel *counterLabel = MSHookIvar<UILabel*>(badgeCounterItem, "counterLabel");
	
	if(![counterLabel.text containsString:@"/ 54"]) {
		counterLabel.text = [counterLabel.text stringByAppendingString:@" / 54"];
	}
	%orig;
}
%end

%hook BadgeStreak
- (void) layoutSubviews {
	UILabel *weekLabel = MSHookIvar<UILabel*>(self, "weekLabel");
	UILabel *nextWeekLabel = MSHookIvar<UILabel*>(self, "nextWeekStartsLabel");
	
	NSString *weekLabelTmp = weekLabel.text;
	weekLabelTmp = [weekLabelTmp stringByReplacingOccurrencesOfString:@"Week " withString:@""];
	
	NSArray *splitDate = [weekLabelTmp componentsSeparatedByString:@"/"];
	if(splitDate.count == 2) {
		NSDate *currentDate = [NSDate date];
		NSTimeInterval oneWeek = 604800;
		
		NSInteger currentWeeks = [splitDate[0] integerValue];
		NSInteger totalWeeks = [splitDate[1] integerValue];
		NSInteger weeksLeft = totalWeeks - currentWeeks;
		NSTimeInterval timeLeft = (weeksLeft * oneWeek) + (([[NSCalendar currentCalendar] component:NSCalendarUnitWeekday fromDate:[NSDate date]] == 2) ? oneWeek : 0);

		NSDate *finishWeek = [[NSCalendar currentCalendar] nextDateAfterDate:[currentDate dateByAddingTimeInterval:timeLeft] matchingUnit:NSCalendarUnitWeekday value:2 options:NSCalendarSearchBackwards | NSCalendarMatchNextTime];
		NSDateFormatter *stringDate = [[NSDateFormatter alloc] init];
		[stringDate setDateFormat:@"MMM dd, yyyy"];
		
		if(![nextWeekLabel.text containsString:@"Badge"]) {
			nextWeekLabel.numberOfLines = 0;
			nextWeekLabel.lineBreakMode = NSLineBreakByWordWrapping;
			nextWeekLabel.text = [[nextWeekLabel.text stringByAppendingString:@"\n\nBadge will be rewarded on \n"] stringByAppendingString:[stringDate stringFromDate:finishWeek]];
			[nextWeekLabel sizeToFit];
		}
	}
	
	if([nextWeekLabel.text containsString:@"Monday"]) {
		NSDate *nextMonday = [[NSCalendar currentCalendar] nextDateAfterDate:[NSDate date] matchingUnit:NSCalendarUnitWeekday value:2 options:NSCalendarMatchNextTime];
		NSDateFormatter *stringDate = [[NSDateFormatter alloc] init];
		[stringDate setDateFormat:@"\nMMM dd, yyyy"];
		
		nextWeekLabel.text = [nextWeekLabel.text stringByReplacingOccurrencesOfString:@"Monday" withString:[stringDate stringFromDate:nextMonday]];
	}
	
	%orig;
}
%end

%hook BannerAd
- (void) layoutSubviews {
	[self removeFromSuperview];
}
%end

%hook CommentText
- (void) layoutSubviews {
	UILabel *countLabel = MSHookIvar<UILabel*>(self, "characterCountLabel");
	countLabel.text = [countLabel.text stringByReplacingOccurrencesOfString:@"/150" withString:@"/300"];
	
	MSHookIvar<int>(self, "characterLimit") = 300;
}
- (bool) textView:(UITextView *)view shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacement {
	UILabel *countLabel = MSHookIvar<UILabel*>(self, "characterCountLabel");
	countLabel.text = [countLabel.text stringByReplacingOccurrencesOfString:@"/150" withString:@"/300"];

	int characterLimit = MSHookIvar<int>(self, "characterLimit");
	characterLimit = 300;

	if (view.text.length >= 300 && [replacement isEqualToString:@""]) {
        view.text = [view.text substringToIndex:view.text.length - 1];
    }

	return (characterLimit == 300 && view.text.length < characterLimit);
}
%end

%hook EditProfileContent
- (void) layoutSubviews {
	UILabel *countLabel = MSHookIvar<UILabel*>(self, "$__lazy_storage_$_bioCharacterCountLabel");
	countLabel.text = [countLabel.text stringByReplacingOccurrencesOfString:@"/150" withString:@"/290"];
	%orig;
}
%end

%hook FeedReaction
- (void) layoutSubviews {
	%orig;
	if(iqBot) {
		FeedReaction *feedReaction = (FeedReaction *)self;
		UIStackView *stackView = MSHookIvar<UIStackView*>(self, "stackView");
		UIButton *reactionButton = [stackView.subviews objectAtIndex:2];
		//id reaction = MSHookIvar<id>(reactionButton, "reaction");
		
		//iqBotPresses = 0;
		[feedReaction didTapReactionButton:reactionButton];
	}
}
%end

%hook FollowButton
- (void) layoutSubviews {
	%orig;
	FollowButton *followButton = (FollowButton *)self;
	// check for width 107 to avoid coloring notification buttons
	if([followButton.titleLabel.text containsString:@"Following"] && CGRectGetWidth(followButton.frame) == 107) {
		UIImageView *buttonImageView = [followButton.subviews firstObject];
		UIImage *image = buttonImageView.image;
		
		// couldnt get Bundles to work with rootless idk what i'm doing wrong but this works to make it red anyways..
		UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
		CGContextSetBlendMode(context, kCGBlendModeNormal);
		CGContextClipToMask(context, rect, image.CGImage);
		[[UIColor colorWithRed:1.0 green:0.056 blue:0.168 alpha:1.0] setFill];
		CGContextFillRect(context, rect);
		
		UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		buttonImageView.image = tintedImage;
	}
}
%end

%hook MainComment
- (void) layoutSubviews {
	%orig;
		
	if(iqBot) {
		MainComment *mainComment = (MainComment *)self;
		//iqBotPresses++;
		[mainComment addReactionButtonTap];
	}
}
%end

%hook MultiLineText
- (bool) textView:(UITextView *)view shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacement {
	MSHookIvar<int>(self, "maximumNumberOfCharacters") = 290; // this simple 42 builds later, also why is 291 the hard limit? so weird
    return %orig;
}
%end

%hook NoteReplyView
- (void) layoutSubviews {
	UILabel *countLabel = MSHookIvar<UILabel*>(self, "counterLabel");
	countLabel.text = [countLabel.text stringByReplacingOccurrencesOfString:@"/150" withString:@"/300"];
	%orig;
}
%end

%hook NoteText
- (void) textViewDidChange:(UITextView*)textView {
	%orig;
	MSHookIvar<int>(self, "characterLimit") = 300;
	UILabel *placeholder = MSHookIvar<UILabel*>(self, "placeholderLabel");
	
	// slight bug with Reply showing /150 on an empty textfield but idc it works
	NoteText *noteText = (NoteText *)self;
	if([placeholder.text containsString:@"Reply"]) {
		UILabel *countLabel = MSHookIvar<UILabel*>(noteText.superview, "counterLabel");
		countLabel.text = [countLabel.text stringByReplacingOccurrencesOfString:@"/150" withString:@"/300"];
	} else if(![placeholder.text containsString:@"Reply"] && [placeholder.text containsString:@"Add a note"]) {
		UIView *noteTextView = noteText.superview;
		UILabel *countLabel = MSHookIvar<UILabel*>(noteTextView.superview, "counterLabel");
		countLabel.text = [countLabel.text stringByReplacingOccurrencesOfString:@"/150" withString:@"/300"];
	}
}
- (bool) textView:(UITextView *)view shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacement {
	int characterLimit = MSHookIvar<int>(self, "characterLimit");
	characterLimit = 300;

	if (view.text.length >= 300 && [replacement isEqualToString:@""]) {
        view.text = [view.text substringToIndex:view.text.length - 1];
    }

	return (characterLimit == 300 && view.text.length < characterLimit);
}
%end

%hook QueueSearch
- (void) textFieldDidBeginEditing:(UITextField *)textField {
	if([textField.text containsString:@"~"]){
		return;
	} else {
		return %orig;
	}
}
- (void) searchFieldTextChanged:(UITextField *)textField {
	if([textField.text containsString:@"~"]){
		UIButton *clearButton = MSHookIvar<UIButton*>(self, "clearButton");
		[clearButton setHidden:YES];
		
		return;
	} else {
		return %orig;
	}
}
- (bool) textFieldShouldReturn:(UITextField *)textField {
	if([textField.text containsString:@"~"]){
		NSString *tmpText = textField.text;
		NSRange endOfCommand = [tmpText rangeOfString:@" "];
		tmpText = (endOfCommand.location != NSNotFound) ? [tmpText substringToIndex:endOfCommand.location] : tmpText;
		
		if([[tmpText stringByReplacingOccurrencesOfString:@"~" withString:@""] isEqualToString:@"auto"]) {
			if([textField.text containsString:@" -s"] && ![textField.text containsString:@" = "]) {
				smartFollowMode = !smartFollowMode;
			}
			
			autoFollowMode = (autoFollowMode < 2) ? autoFollowMode + 1 : 0;

			NSString *uglymess = (smartFollowMode) ? @"~auto -s = " : @"~auto = ";
			uglymess = [uglymess stringByAppendingString:[NSString stringWithFormat:@"%d", autoFollowMode]];
			if(autoFollowMode == 1) {
				uglymess = (smartFollowMode) ? [uglymess stringByAppendingString:@" (auto follow active) [S]"] : [uglymess stringByAppendingString:@" (auto follow active)"];
			} else if (autoFollowMode == 2) {
				uglymess = (smartFollowMode) ? [uglymess stringByAppendingString:@" (auto unfollow active) [S]"] : [uglymess stringByAppendingString:@" (auto unfollow active)"];	
			} else {
				uglymess = [uglymess stringByAppendingString:@" (off)"];
			}
			textField.text = uglymess;
		} else if ([[tmpText stringByReplacingOccurrencesOfString:@"~" withString:@""] isEqualToString:@"iqbot"]) {
			iqBot = !iqBot; // ill add proper later
		} else if ([[tmpText stringByReplacingOccurrencesOfString:@"~" withString:@""] isEqualToString:@"kill"]) {
			exit(0);
		}
		return NO;
	} else {
		return %orig;
	}
}
%end

%hook ReviewText
- (bool) textView:(UITextView *)view shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacement {
	MSHookIvar<int>(self, "characterLimit") = 600;
    return %orig;
}
%end

// todo: find a way to avoid being rate limited when following/unfollowing people fast
%hook SearchUser
- (void) layoutSubviews {
	%orig;
	
	UIButton *followButton = MSHookIvar<UIButton*>(self, "followButton");
	UIView *userNameView = smartFollowMode ? MSHookIvar<UIView*>(self, "userNameView") : nil;
	UIView *userImageView = smartFollowMode ? MSHookIvar<UIView*>(self, "userImageView") : nil;
	UIImageView *badgeImage = (smartFollowMode && userNameView) ? MSHookIvar<UIImageView*>(userNameView, "badgeImageView") : nil;
	UILabel *userName = (smartFollowMode && userNameView) ? MSHookIvar<UILabel*>(self, "subtitleLabel") : nil;
	// sorry for this mouthful below
	bool isJunkAccount = (userName && [userName.text hasPrefix:@"@user"] && [[userName.text substringFromIndex:5] rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound) ? YES : NO;
		
	if(autoFollowMode == 1 && [followButton.titleLabel.text isEqualToString:@"Follow"]) {
		if(smartFollowMode && userNameView && userImageView) {
			bool isVerified = MSHookIvar<bool>(userImageView, "isVerified");
			if(badgeImage && !isVerified && badgeImage.image && !isJunkAccount) {
				[self handleFollowButtonTap];
			}
		} else {
			[self handleFollowButtonTap];
		}
		return;
	} else if(autoFollowMode == 2 && [followButton.titleLabel.text containsString:@"Following"]) {
		if(smartFollowMode && userNameView && userImageView) {
			bool isVerified = MSHookIvar<bool>(userImageView, "isVerified");
			if(badgeImage && (isVerified || !badgeImage.image || isJunkAccount)) {
				[self handleFollowButtonTap];
			}
		} else {
			[self handleFollowButtonTap];
		}
		return;
	}
}
%end

%hook SearchUserCollection
- (void) layoutSubviews {
	%orig;
	
	UIButton *followButton = MSHookIvar<UIButton*>(self, "followButton");
	if([followButton.titleLabel.text containsString:@"Following"]){
		UIImageView *buttonImageView = [followButton.subviews firstObject];
		UIImage *image = buttonImageView.image;
		
		UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
		CGContextSetBlendMode(context, kCGBlendModeNormal);
		CGContextClipToMask(context, rect, image.CGImage);
		[[UIColor colorWithRed:1.0 green:0.056 blue:0.168 alpha:1.0] setFill];
		CGContextFillRect(context, rect);
		
		UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		buttonImageView.image = tintedImage;
	}
}
%end

%hook SettingsView
- (void) layoutSubviews {
	NSString *qriticVersion = @"\nQritic 1.1 - Build 55"; // not automatic but whatever it works
	UILabel *versionInfo = MSHookIvar<UILabel*>(self, "versionInfoLabel");
	
	if(![versionInfo.text containsString:qriticVersion]) {
		versionInfo.numberOfLines = 0;
		versionInfo.lineBreakMode = NSLineBreakByWordWrapping;
		versionInfo.text = [versionInfo.text stringByAppendingString:qriticVersion];
		[versionInfo sizeToFit];
	}
	
	%orig;
}
%end

%hook ShareTitleContent
- (void) layoutSubviews {
	UILabel *countLabel = MSHookIvar<UILabel*>(self, "counterLabel");
	countLabel.text = [countLabel.text stringByReplacingOccurrencesOfString:@"/150" withString:@"/300"];
	%orig;
}
%end

%hook SuggestedFriend
- (void) layoutSubviews {
	%orig;
	
	UIButton *followButton = MSHookIvar<UIButton*>(self, "followButton");
	UIView *userNameView = smartFollowMode ? MSHookIvar<UIView*>(self, "userNameView") : nil;
	UIView *userImageView = smartFollowMode ? MSHookIvar<UIView*>(self, "userImageView") : nil;
	UIImageView *badgeImage = (smartFollowMode && userNameView) ? MSHookIvar<UIImageView*>(userNameView, "badgeImageView") : nil;

	if(autoFollowMode == 1 && [followButton.titleLabel.text isEqualToString:@"Follow"]) {
		if(smartFollowMode && userNameView && userImageView) {
			bool isVerified = MSHookIvar<bool>(userImageView, "isVerified");
			if(badgeImage && !isVerified && badgeImage.image) {
				[self followButtonTapped:followButton];
			}
		} else {
			[self followButtonTapped:followButton];
		}
		return;
	} else if(autoFollowMode == 2 && [followButton.titleLabel.text containsString:@"Following"]) {
		if(smartFollowMode && userNameView && userImageView) {
			bool isVerified = MSHookIvar<bool>(userImageView, "isVerified");
			if(badgeImage && (isVerified || !badgeImage.image)) {
				[self followButtonTapped:followButton];
			}
		} else {
			[self followButtonTapped:followButton];
		}
		return;
	}
}
%end

%hook TitleReactionsContent
- (void) layoutSubviews {
	UILabel *countLabel = MSHookIvar<UILabel*>(self, "$__lazy_storage_$_characterCountLabel");
	countLabel.text = [countLabel.text stringByReplacingOccurrencesOfString:@"/280" withString:@"/600"];
	%orig;
}
%end

%ctor {
%init(
BadgeCounter=objc_getClass("WatchQueue.BadgeCounterView"),
BadgeStreak=objc_getClass("WatchQueue.BadgeStreakView"),
BannerAd=objc_getClass("WatchQueue.BannerAdCell"),
CommentText=objc_getClass("WatchQueue.CommentTextView"),
EditProfileContent=objc_getClass("WatchQueue.EditProfileContentView"),
FeedReaction=objc_getClass("WatchQueue.FeedReactionSelectionView"),
FollowButton=objc_getClass("WatchQueue.FollowButton"),
MainComment=objc_getClass("WatchQueue.MainCommentView"),
MultiLineText=objc_getClass("WatchQueue.MultilineTextInputView"),
NoteReplyView=objc_getClass("WatchQueue.NotificationReplyTextView"),
NoteText=objc_getClass("WatchQueue.NoteTextView"),
QueueSearch=objc_getClass("WatchQueue.QueueSearchField"),
ReviewText=objc_getClass("WatchQueue.ReviewTextView"),
SearchUser=objc_getClass("WatchQueue.SearchUserCell"),
SearchUserCollection=objc_getClass("WatchQueue.SearchUserCollectionCell"),
SettingsView=objc_getClass("WatchQueue.SettingsContentView"),
ShareTitleContent=objc_getClass("WatchQueue.ShareTitleContentView"),
SuggestedFriend=objc_getClass("WatchQueue.SuggestedFriendView"),
TitleReactionsContent=objc_getClass("WatchQueue.TitleReactionsContentView"))
}