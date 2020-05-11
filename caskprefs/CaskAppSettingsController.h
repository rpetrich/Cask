#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface CaskAppSettingsController : PSListController
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *bundleIdentifier;
@end
