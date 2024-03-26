#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%hook ActionButton
- (void)setEnabled:(BOOL)enabled {
	%orig(YES); // i hope this doesn't break something else
}
%end 

%hook CommentText
-(bool) textView:(id)view shouldChangeTextInRange:(NSRange)range replacementText:(id)replacement {
	return YES;
}
%end

%hook MultiLineText
-(bool) textView:(id)view shouldChangeTextInRange:(NSRange)range replacementText:(id)replacement {
	return YES;
}
%end

%hook ReviewText
-(bool) textView:(id)view shouldChangeTextInRange:(NSRange)range replacementText:(id)replacement {
	return YES;
}
%end

%hook SettingsView
-(void)layoutSubviews {
	NSString *qriticVersion = @"\nQritic 1.0.5 - 1"; // not automatic but whatever it works
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

%hook SingleLineText
-(bool) textView:(id)view shouldChangeTextInRange:(NSRange)range replacementText:(id)replacement {
	return YES;
}
%end

%ctor {
%init(ActionButton=objc_getClass("WatchQueue.ActionButton"),
CommentText=objc_getClass("WatchQueue.CommentTextView"),
MultiLineText=objc_getClass("WatchQueue.MultilineTextInputView"),
ReviewText=objc_getClass("WatchQueue.ReviewTextView"),
SettingsView=objc_getClass("WatchQueue.SettingsContentView"),
SingleLineText=objc_getClass("WatchQueue.TextInput"));
}