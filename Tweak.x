#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef enum {
	AnimationStyleNone = 0,
	AnimationStyleFade = 1,
	AnimationStyleGrow = 2,
} AnimationStyle;

static BOOL GetBooleanSetting(NSString *key, BOOL defaultValue)
{
	Boolean exists;
	Boolean result = CFPreferencesGetAppBooleanValue((CFStringRef)key, CFSTR("com.rpetrich.cask"), &exists);
	return exists ? result : defaultValue;
}

static CFIndex GetIntegerSetting(NSString *key, CFIndex defaultValue)
{
	Boolean exists;
	CFIndex result = CFPreferencesGetAppIntegerValue((CFStringRef)key, CFSTR("com.rpetrich.cask"), &exists);
	return exists ? result : defaultValue;
}

static double GetDoubleSetting(NSString *key, double defaultValue)
{
	id value = (id)CFPreferencesCopyAppValue((CFStringRef)key, CFSTR("com.rpetrich.cask"));
	double result = [value respondsToSelector:@selector(doubleValue)] ? [value doubleValue] : defaultValue;
	[value release];
	return result;
}

static const BOOL kJustMovedToWindowKey;

static AnimationStyle AnimationStyleForTableView(UITableView *tableView)
{
	if ((tableView.window && !objc_getAssociatedObject(tableView, &kJustMovedToWindowKey)) || GetBooleanSetting(@"AnimateAlways", NO)) {
		return (AnimationStyle)GetIntegerSetting(@"AnimationStyle", AnimationStyleFade);
	} else {
		return AnimationStyleNone;
	}
}

%hook UITableView

- (void)didMoveToWindow
{
	objc_setAssociatedObject(self, &kJustMovedToWindowKey, (id)kCFBooleanTrue, OBJC_ASSOCIATION_ASSIGN);
	dispatch_async(dispatch_get_main_queue(), ^{
		objc_setAssociatedObject(self, &kJustMovedToWindowKey, nil, OBJC_ASSOCIATION_ASSIGN);
	});
	%orig();
}

- (UITableViewCell *)_createPreparedCellForGlobalRow:(NSInteger)globalRow withIndexPath:(NSIndexPath *)indexPath willDisplay:(BOOL)willDisplay
{
	AnimationStyle style;
	if (willDisplay && (style = AnimationStyleForTableView(self))) {
		NSTimeInterval duration = GetDoubleSetting(@"AnimationDuration", 0.5);
		UITableViewCell *result = %orig();
		switch (style) {
			case AnimationStyleNone:
				break;
			case AnimationStyleFade:
				dispatch_async(dispatch_get_main_queue(), ^{
					CGFloat original = result.alpha;
					result.alpha = 0.0;
					[UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionCurveEaseOut animations:^{
						result.alpha = original;
					} completion:NULL];
				});
				break;
			case AnimationStyleGrow:
				dispatch_async(dispatch_get_main_queue(), ^{
					CGAffineTransform original = result.transform;
					result.transform = CGAffineTransformMakeScale(0.01, 0.01);
					[UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionCurveEaseOut animations:^{
						result.transform = original;
					} completion:NULL];
				});
				break;
		}
		return result;
	} else {
		return %orig();
	}
}

%end

static void PreferencesCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	CFPreferencesAppSynchronize(CFSTR("com.rpetrich.cask"));
}


%ctor
{
	%init();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesCallback, CFSTR("com.rpetrich.cask.config-changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
