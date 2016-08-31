#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <notify.h>

typedef enum {
	AnimationStyleNone = 0,
	AnimationStyleFade = 1,
	AnimationStyleGrow = 2,
	AnimationStyleStretch = 3,
	AnimationStyleSlide = 4,
	AnimationStyleSlideAndBounce = 5,
} AnimationStyle;

static struct {
	BOOL animateAlways;
	AnimationStyle animationStyle;
	NSTimeInterval duration;
} settings;
static void PrepareSettings(void);

static const BOOL kJustMovedToWindowKey;

static AnimationStyle AnimationStyleForTableView(UITableView *tableView)
{
	PrepareSettings();
	if ((tableView.window && !objc_getAssociatedObject(tableView, &kJustMovedToWindowKey)) || settings.animateAlways) {
		return settings.animationStyle;
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
		PrepareSettings();
		NSTimeInterval duration = settings.duration;
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
			case AnimationStyleStretch:
				dispatch_async(dispatch_get_main_queue(), ^{
					CGAffineTransform original = result.transform;
					result.transform = CGAffineTransformMakeScale(0.01, 1.0);
					[UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionCurveEaseOut animations:^{
						result.transform = original;
					} completion:NULL];
				});
				break;
			case AnimationStyleSlide:
				dispatch_async(dispatch_get_main_queue(), ^{
					CGRect original = result.frame;
					CGRect newFrame = original;
					newFrame.origin.x += original.size.width;
					result.frame = newFrame;
					[UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionCurveEaseOut animations:^{
						result.frame = original;
					} completion:NULL];
				});
			case AnimationStyleSlideAndBounce:
				dispatch_async(dispatch_get_main_queue(), ^{
					CGRect original = result.frame;
					CGRect newFrame = original;
					CGRect newFrame2 = original;
					newFrame2.origin.x -= 25;
					newFrame.origin.x += original.size.width;
					result.frame = newFrame;
					[UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionCurveEaseOut animations:^{
						result.frame = newFrame2;
					} completion:^(BOOL _) {
						[UIView animateWithDuration:duration / 2 animations:^{
							result.frame = original;
						}];
					}];
				});
				break;
		}
		return result;
	} else {
		return %orig();
	}
}

%end

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

static int notifyToken;
static BOOL prepared;
static BOOL isSpringBoard;

static void PrepareSettings(void)
{
	if (!prepared) {
		// Smuggle settings around in the notify state. I'm too lazy to build a real IPC center for such a simple tweak
		if (notifyToken == 0) {
			notify_register_check("com.rpetrich.cask.config-changed", &notifyToken);
		}
		if (isSpringBoard) {
			CFPreferencesAppSynchronize(CFSTR("com.rpetrich.cask"));
			settings.animateAlways = GetBooleanSetting(@"AnimateAlways", NO);
			settings.animationStyle = (AnimationStyle)GetIntegerSetting(@"AnimationStyle", AnimationStyleFade);
			settings.duration = GetDoubleSetting(@"AnimationDuration", 0.5);
			notify_set_state(notifyToken, ((uint64_t)settings.animateAlways << 63) + ((uint64_t)settings.animationStyle << 32) + (uint64_t)(settings.duration * 1000));
		} else {
			uint64_t state = 0;
			notify_get_state(notifyToken, &state);
			settings.animateAlways = state >> 63;
			settings.animationStyle = (AnimationStyle)((state >> 32) & 0xFF);
			settings.duration = (NSTimeInterval)(state & 0xFFFFFFFFl) / 1000.0;
		}
	}
}

static void PreferencesCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	prepared = NO;
	if (isSpringBoard) {
		PrepareSettings();
	}
}

%ctor
{
	%init();
	if ((isSpringBoard = (objc_getClass("SpringBoard") != nil))) {
		PrepareSettings();
	}
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesCallback, CFSTR("com.rpetrich.cask.config-changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
