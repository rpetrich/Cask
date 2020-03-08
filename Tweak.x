NSInteger style;
BOOL animateAlways;
NSTimeInterval duration;
BOOL hasMovedToWindow = NO;

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
		__block UITableViewCell *result = %orig;
		
		if (hasMovedToWindow && !animateAlways)
			return result;

		switch (style) {
			case 0:
				break;
			case 1:
				dispatch_async(dispatch_get_main_queue(), ^{
					CGFloat original = result.alpha;
					result.alpha = 0.0;
					[UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionCurveEaseOut animations:^{
						result.alpha = original;
					} completion:NULL];
				});
				break;
			case 2:
					dispatch_async(dispatch_get_main_queue(), ^{
					CGAffineTransform original = result.transform;
           			result.transform = CGAffineTransformMakeScale(0.01, 1.0);
					[UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:10.0  options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionCurveEaseOut animations:^{
						result.transform = original;
					} completion:NULL];
				});
				break;
			case 3:
					dispatch_async(dispatch_get_main_queue(), ^{
					CGAffineTransform original = result.transform;
					result.transform = CGAffineTransformMakeScale(0.3, 0.5);
					[UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:0.0 initialSpringVelocity:10.0  options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionCurveEaseOut animations:^{
						result.transform = original;
					} completion:NULL]; 
				});
				break;				
			case 4:
				dispatch_async(dispatch_get_main_queue(), ^{
					CGAffineTransform original = result.transform;
					result.transform = CGAffineTransformMakeScale(0.01, 1.0);
					[UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionCurveEaseOut animations:^{
						result.transform = original;
					} completion:NULL];
				});
				break;
			case 5:
				dispatch_async(dispatch_get_main_queue(), ^{
					CGRect original = result.frame;
					CGRect newFrame = original;
					newFrame.origin.x += original.size.width;
					result.frame = newFrame;
					[UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionCurveEaseOut animations:^{
						result.frame = original;
					} completion:NULL];
				});
				break;
		}
		return result;
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

		if(!IN_SPRINGBOARD)
      	  %init;
    }
}
