#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <rootless.h>

@interface FollowButton
@property (nonatomic, assign, readwrite) UILabel *titleLabel;
@property (nonatomic, assign, readwrite) CGRect frame;
@property (nonatomic, assign, readwrite) NSArray *subviews;
@end

@interface QueueSearch : UITextField
@property (nonatomic, assign, readwrite) UIView *superview;
@end

@interface SearchUser
- (void) handleFollowButtonTap;
@end

@interface SearchUserCollection
//- (void) buttonTapped; somethings wrong w/ this
@end

int autoFollowMode = 0;

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
		NSTimeInterval timeLeft = weeksLeft * oneWeek;
		
		NSDate *finishWeek = [currentDate dateByAddingTimeInterval:timeLeft];
		NSDateFormatter *stringDate = [[NSDateFormatter alloc] init];
		[stringDate setDateFormat:@"MMM dd, yyyy"];
		
		if(![nextWeekLabel.text containsString:@"Badge"]) {
			nextWeekLabel.numberOfLines = 0;
			nextWeekLabel.lineBreakMode = NSLineBreakByWordWrapping;
			nextWeekLabel.text = [[nextWeekLabel.text stringByAppendingString:@"\n\nBadge will be rewarded on:\n"] stringByAppendingString:[stringDate stringFromDate:finishWeek]];
			[nextWeekLabel sizeToFit];
		}
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

%hook MultiLineText
- (bool) textView:(UITextView *)view shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacement {
	MSHookIvar<int>(self, "maximumNumberOfCharacters") = 290; // this simple 42 builds later, also why is 291 the hard limit? so weird
    return %orig;
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
	if([textField.text containsString:@"~bm"]){
		if (autoFollowMode < 2) {
			autoFollowMode++;
        } else {
			autoFollowMode = 0;
        }
        
		NSString *uglymess = @"~bm = ";
		uglymess = [uglymess stringByAppendingString:[NSString stringWithFormat:@"%d", autoFollowMode]];
		textField.text = uglymess;
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

%hook SearchUser
- (void) layoutSubviews {
	%orig;
	
	UIButton *followButton = MSHookIvar<UIButton*>(self, "followButton");
	if(autoFollowMode == 1) {
		if([followButton.titleLabel.text isEqualToString:@"Follow"]) {
			[self handleFollowButtonTap]; // prepare to get rate limited
		}
	} else if(autoFollowMode == 2) {
		if([followButton.titleLabel.text containsString:@"Following"]){
			[self handleFollowButtonTap];
		}
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
	NSString *qriticVersion = @"\nQritic 1.0 - Build 96"; // not automatic but whatever it works
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
FollowButton=objc_getClass("WatchQueue.FollowButton"),
MultiLineText=objc_getClass("WatchQueue.MultilineTextInputView"),
QueueSearch=objc_getClass("WatchQueue.QueueSearchField"),
ReviewText=objc_getClass("WatchQueue.ReviewTextView"),
SearchUser=objc_getClass("WatchQueue.SearchUserCell"),
SearchUserCollection=objc_getClass("WatchQueue.SearchUserCollectionCell"),
SettingsView=objc_getClass("WatchQueue.SettingsContentView"),
TitleReactionsContent=objc_getClass("WatchQueue.TitleReactionsContentView"))
}