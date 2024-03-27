#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <rootless.h>

@interface FollowButton
@property (nonatomic, assign, readwrite) UILabel *titleLabel;
@property (nonatomic, assign, readwrite) CGRect frame;
@property (nonatomic, assign, readwrite) NSArray *subviews;
@end

%hook CommentText
- (void) layoutSubviews {
	UILabel *countLabel = MSHookIvar<UILabel*>(self, "characterCountLabel");
	countLabel.text = [countLabel.text stringByReplacingOccurrencesOfString:@"/150" withString:@"/300"];
	MSHookIvar<int>(self, "characterLimit") = 300;
	%orig;
}
- (bool) textView:(UITextView *)view shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacement {
	UILabel *countLabel = MSHookIvar<UILabel*>(self, "characterCountLabel");
	countLabel.text = [countLabel.text stringByReplacingOccurrencesOfString:@"/150" withString:@"/300"];
	MSHookIvar<int>(self, "characterLimit") = 300;
	return %orig;
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

%hook ReviewText
- (bool) textView:(UITextView *)view shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacement {
	MSHookIvar<int>(self, "characterLimit") = 600;
    return %orig;
}
%end

%hook SettingsView
- (void) layoutSubviews {
	NSString *qriticVersion = @"\nQritic 1.0.5 - 47"; // not automatic but whatever it works
	UILabel *versionInfo = MSHookIvar<UILabel*>(self, "versionInfoLabel");
	if(![versionInfo.text containsString:qriticVersion]) {
		NSString *versionText = versionInfo.text;
		NSString *qriticInfo = [versionText stringByAppendingString:qriticVersion];
		versionInfo.numberOfLines = 0;
		versionInfo.lineBreakMode = NSLineBreakByWordWrapping;
		versionInfo.text = qriticInfo;
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
CommentText=objc_getClass("WatchQueue.CommentTextView"),
EditProfileContent=objc_getClass("WatchQueue.EditProfileContentView"),
FollowButton=objc_getClass("WatchQueue.FollowButton"),
MultiLineText=objc_getClass("WatchQueue.MultilineTextInputView"),
ReviewText=objc_getClass("WatchQueue.ReviewTextView"),
SettingsView=objc_getClass("WatchQueue.SettingsContentView"),
TitleReactionsContent=objc_getClass("WatchQueue.TitleReactionsContentView"))
}
