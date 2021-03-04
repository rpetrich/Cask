#import "CaskAppSettingsController.h"

@implementation CaskAppSettingsController

-(id)specifiers {
    if (_specifiers == nil) {
		NSMutableArray *testingSpecs = [[self loadSpecifiersFromPlistName:@"AppSettings" target:self] mutableCopy];
        
        _specifiers = testingSpecs;
    }
    
	return _specifiers;
}
-(void)setSpecifier:(PSSpecifier*)specifier {
    [super setSpecifier:specifier];
    
    // Load up stuff from here!
    self.displayName = [specifier name];
    self.bundleIdentifier = [specifier propertyForKey:@"bundleIdentifier"];
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	NSMutableDictionary *appSettings = [settings objectForKey:self.bundleIdentifier];
	if (!appSettings) {
		appSettings = [NSMutableDictionary new];
	}
	return ([appSettings objectForKey:specifier.properties[@"key"]]) ?: [settings objectForKey:specifier.properties[@"key"]]?:specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	if (![settings objectForKey:self.bundleIdentifier]) {
		[settings setObject:[NSMutableDictionary new] forKey:self.bundleIdentifier];
	}
	[(NSMutableDictionary *)[settings valueForKey:self.bundleIdentifier] setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];


	CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]] setOnTintColor:[UIColor colorWithRed: 0.47 green: 0.36 blue: 0.71 alpha: 1.00]];
}
@end
