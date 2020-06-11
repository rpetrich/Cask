#import "generated-headers/Cask-Swift.h"
#import <CoreGraphics/CGGeometry.h>

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
-(id)initWithFrame:(CGRect)arg1 {
    hasMovedToWindow = YES;
    return %orig;
}
%end 

%hook UITableView
-(void)reloadData {
    hasMovedToWindow = YES;
    %orig;
}
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

    if (![@"SpringBoard" isEqualToString:[NSProcessInfo processInfo].processName]) {
        loadPrefs();
        %init;
    }
}
