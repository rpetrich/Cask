#include "CaskRootListController.h"

#if __cplusplus
extern "C" {
#endif

    CFSetRef SBSCopyDisplayIdentifiers();
    NSString * SBSCopyLocalizedApplicationNameForDisplayIdentifier(NSString *identifier);

#if __cplusplus
}
#endif

static OrderedDictionary *dataSourceUser;

@implementation CaskRootListController

- (instancetype)init {
    self = [super init];

    if (self) {
        self.navigationItem.titleView = [UIView new];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.text = @"Cask 2";
        [self.navigationItem.titleView addSubview:self.titleLabel];
    
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/caskprefs.bundle/icon@2x.png"];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        self.iconView.alpha = 0.0;
        [self.navigationItem.titleView addSubview:self.iconView];
    
        [NSLayoutConstraint activateConstraints:@[
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
            [self.iconView.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
        ]];
    }

    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat const offsetY = scrollView.contentOffset.y;

    if (offsetY > 100) {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 1.0;
            self.titleLabel.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 0.0;
            self.titleLabel.alpha = 1.0;
        }];
    }
}

- (NSArray *)specifiers {
	if (_specifiers == nil) {
		NSMutableArray *testingSpecs = [[self loadSpecifiersFromPlistName:@"Root" target:self] mutableCopy];
                
        [testingSpecs addObjectsFromArray:[self appSpecifiers]];
        
        _specifiers = testingSpecs;

        self.savedSpecifiers = [[NSMutableDictionary alloc] init];
        
        for (PSSpecifier *specifier in [self specifiers]) {
			if ([specifier propertyForKey:@"id"]) {
				[self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
		    }
		}
    }
    
	return _specifiers;
}

-(NSMutableArray*)appSpecifiers {
    NSMutableArray *specifiers = [NSMutableArray array];

    NSArray *displayIdentifiers = [(__bridge NSSet *)SBSCopyDisplayIdentifiers() allObjects];

    NSMutableDictionary *apps = [NSMutableDictionary new];
    for (NSString *appIdentifier in displayIdentifiers) {
        NSString *appName = SBSCopyLocalizedApplicationNameForDisplayIdentifier(appIdentifier);
        if (appName) {
            [apps setObject:appName forKey:appIdentifier];
        }
    }

    dataSourceUser = (OrderedDictionary*)[apps copy];
    dataSourceUser = (OrderedDictionary*)[self trimDataSource:dataSourceUser];
    dataSourceUser = [self sortedDictionary:dataSourceUser];
    
    PSSpecifier* groupSpecifier = [PSSpecifier groupSpecifierWithName:@"Per-app Customization:"];
    [specifiers addObject:groupSpecifier];
    
    for (NSString *bundleIdentifier in dataSourceUser.allKeys) {
        NSString *displayName = dataSourceUser[bundleIdentifier];
        
        PSSpecifier *spe = [PSSpecifier preferenceSpecifierNamed:displayName target:self set:nil get:@selector(getIsWidgetSetForSpecifier:) detail:[CaskAppSettingsController class] cell:PSLinkListCell edit:nil];
        [spe setProperty:@"IBKWidgetSettingsController" forKey:@"detail"];
        [spe setProperty:[NSNumber numberWithBool:YES] forKey:@"isController"];
        [spe setProperty:[NSNumber numberWithBool:YES] forKey:@"enabled"];
        [spe setProperty:bundleIdentifier forKey:@"bundleIdentifier"];
        [spe setProperty:bundleIdentifier forKey:@"appIDForLazyIcon"];
        [spe setProperty:@YES forKey:@"useLazyIcons"];
        
        [specifiers addObject:spe];
    }
    
    return specifiers;
}

-(NSDictionary*)trimDataSource:(NSDictionary*)dataSource {
    NSMutableDictionary *mutable = [dataSource mutableCopy];
    
    NSArray *bannedIdentifiers = [[NSArray alloc] initWithObjects:
                                  @"com.apple.sidecar",
                                  @"com.apple.compass",
                                  @"com.apple.AppStore",
                                  @"com.apple.measure",
                                  @"com.apple.calculator",
                                  @"com.apple.tv",
                                  nil];

    for (NSString *key in bannedIdentifiers) {
        [mutable removeObjectForKey:key];
    }
    return mutable;
}

-(OrderedDictionary*)sortedDictionary:(OrderedDictionary*)dict {
    NSArray *sortedValues;
    OrderedDictionary *mutable = [OrderedDictionary dictionary];
    
    sortedValues = [[dict allValues] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for (NSString *value in sortedValues) {
        // Get key for value.
        NSString *key = [[dict allKeysForObject:value] objectAtIndex:0];
        
        [mutable setObject:value forKey:key];
    }
    
    return mutable;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
  NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
  NSMutableDictionary *settings = [NSMutableDictionary dictionary];
  [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];

  return ([settings objectForKey:specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
  NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
  NSMutableDictionary *settings = [NSMutableDictionary dictionary];
  [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];

  [settings setObject:value forKey:specifier.properties[@"key"]];
  [settings writeToFile:path atomically:YES];
  CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
  if (notificationName) {
   CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
  }
}
@end

@interface CaskTwitterCell () {
    NSString *_user;
}
@end

@implementation CaskTwitterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

    if (self) {

        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 38, 38)];

        self.detailTextLabel.numberOfLines = 1;
        self.detailTextLabel.textColor = [UIColor grayColor];

        self.textLabel.textColor = [UIColor blackColor];
        
        if (@available(iOS 13, *)) {
            self.tintColor = [UIColor labelColor];
        }
        else {
            self.tintColor = [UIColor blackColor];
        }

        CGFloat size = 29.f;

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, [UIScreen mainScreen].scale);
        specifier.properties[@"iconImage"] = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        _avatarView = [[UIView alloc] initWithFrame:self.imageView.bounds];
        _avatarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _avatarView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1];
        _avatarView.userInteractionEnabled = NO;
        _avatarView.clipsToBounds = YES;
        _avatarView.layer.cornerRadius = size / 2;
        _avatarView.layer.borderWidth = 2;
        
        if (@available(iOS 13, *)) {
            _avatarView.layer.borderColor = [[UIColor tertiaryLabelColor] CGColor];
        }
        else {
            _avatarView.layer.borderColor = [[UIColor colorWithWhite:1 alpha:0.3] CGColor];
        }
        
        [self.imageView addSubview:_avatarView];

        _avatarImageView = [[UIImageView alloc] initWithFrame:_avatarView.bounds];
        _avatarImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _avatarImageView.alpha = 0;
        _avatarImageView.layer.minificationFilter = kCAFilterTrilinear;
        [_avatarView addSubview:_avatarImageView];

        _user = [specifier.properties[@"accountName"] copy];
        NSAssert(_user, @"User name not provided");

        specifier.properties[@"url"] = [self.class _urlForUsername:_user];

        self.detailTextLabel.text = _user;

        if (!_user) {
            return self;
        }

        /*self.avatarImage = [UIImage imageNamed:[NSString stringWithFormat:@"/Library/PreferenceBundles/caskprefs.bundle/%@.png", _user]];
         */

        // This has a delay as image needs to be downloaded
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            
            NSString *size = [UIScreen mainScreen].scale > 2 ? @"original" : @"bigger";
            NSError __block *err = NULL;
            NSData __block *data;
            BOOL __block reqProcessed = false;
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://mobile.twitter.com/%@/profile_image?size=%@", _user, size]]];
            
            [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData  *_data, NSURLResponse *_response, NSError *_error) {
                err = _error;
                data = _data;
                reqProcessed = true;
            }] resume];

            while (!reqProcessed) {
                [NSThread sleepForTimeInterval:0];
            }

            if (err)
                return;
                
            dispatch_async(dispatch_get_main_queue(), ^{
                    self.avatarImage = [UIImage imageWithData: data];
            });
        });
    }
    return self;
}

#pragma mark - Avatar

- (void)setAvatarImage:(UIImage *)avatarImage
{
    _avatarImageView.image = avatarImage;

    if (_avatarImageView.alpha == 0)
    {
        [UIView animateWithDuration:0.15
            animations:^{
                _avatarImageView.alpha = 1;
            }
        ];
    }
}


+ (NSString *)_urlForUsername:(NSString *)user {

    /* if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"aphelion://"]]) {
        return [NSString stringWithFormat: @"aphelion://profile/%@", user]; //Easter egg by hbkirb
    } else
    */ if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) {
        return [NSString stringWithFormat: @"tweetbot:///user_profile/%@", user];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) {
        return [NSString stringWithFormat: @"twitterrific:///profile?screen_name=%@", user];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings://"]]) {
        return [NSString stringWithFormat: @"tweetings:///user?screen_name=%@", user];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
        return [NSString stringWithFormat: @"twitter://user?screen_name=%@", user];
    } else {
        return [NSString stringWithFormat: @"https://mobile.twitter.com/%@", user];
    }
}

- (void)setSelected:(BOOL)arg1 animated:(BOOL)arg2
{
    if (arg1) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.class _urlForUsername:_user]] options:@{} completionHandler:nil];
}
@end
