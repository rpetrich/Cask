#import "generated-headers/Cask-Swift.h"

BOOL hasMovedToWindow = NO;

%hook UIScrollView

-(BOOL)isDragging {
   BOOL const orig = %orig;
	hasMovedToWindow = !orig;
	return orig;
}

-(void)_scrollViewWillBeginDragging {
	hasMovedToWindow = NO;
	return %orig;
}

%end 

%hook UITableView
- (UITableViewCell *)_createPreparedCellForGlobalRow:(NSInteger)globalRow withIndexPath:(NSIndexPath *)indexPath willDisplay:(BOOL)willDisplay
{
	UITableViewCell *result = %orig;
	return [Cask animatedTable:result hasMovedToWindow:hasMovedToWindow];
}

%end

void loadPrefs() {
    [Cask loadPrefs];
}

%ctor{
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.ryannair05.caskprefs/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    loadPrefs();

    if (![@"SpringBoard" isEqualToString:[NSProcessInfo processInfo].processName])
        %init;
}