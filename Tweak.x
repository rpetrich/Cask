#import <UIKit/UIKit.h>
#import <Cask-Swift.h>

int style;
BOOL animateAlways;
BOOL hasMovedToWindow = NO;
NSTimeInterval duration;

%hook UIScrollView

-(BOOL)isDragging {
	hasMovedToWindow = !%orig;
	return %orig;
}

-(void)_scrollViewWillBeginDragging{
	hasMovedToWindow = NO;
	return %orig;
}

%end 

%hook UITableView

- (UITableViewCell *)_createPreparedCellForGlobalRow:(NSInteger)globalRow withIndexPath:(NSIndexPath *)indexPath willDisplay:(BOOL)willDisplay
{
		if (hasMovedToWindow && !animateAlways)
			return %orig;

		UITableViewCell *result = %orig;
		Cask * cas = [[objc_getClass("Cask") alloc] init];
		return [cas animatedTable:result style:style duration:duration];
}

%end

 void initPrefs() {
        NSString *path = @"/User/Library/Preferences/com.ryannair05.caskprefs.plist";
        NSString *pathDefault = @"/Library/PreferenceBundles/caskprefs.bundle/defaults.plist";
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:path]) {
            [fileManager copyItemAtPath:pathDefault toPath:path error:nil];
        }
}

// Preferences.
void loadPrefs() {
     @autoreleasepool {

        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ryannair05.caskprefs.plist"];
        if (prefs) {
            style = [[prefs objectForKey:@"style"] integerValue];
            duration = [[prefs objectForKey:@"duration"] doubleValue];
            animateAlways = [[prefs objectForKey:@"animateAlways"] boolValue];
        }
    }
}

%ctor {
    @autoreleasepool {
	    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.ryannair05.caskprefs/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		initPrefs();
		loadPrefs();

		if(![@"SpringBoard" isEqualToString:[NSProcessInfo processInfo].processName])
      	  %init;
    }
}
