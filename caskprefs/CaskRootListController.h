#import "CaskAppSettingsController.h"
#import <Preferences/PSTableCell.h>
#include <spawn.h>
#import "caskprefs-Swift.h"

@interface PSListController (Method)
-(BOOL)containsSpecifier:(id)arg1;
@end

@interface CaskRootListController : PSListController{
    UITableView * _table;
}
@property (nonatomic, retain) UIBarButtonItem *respringButton;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIImageView *iconView;
@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UIImageView *headerImageView;
-(NSDictionary*)trimDataSource:(NSDictionary*)dataSource;
-(NSMutableArray*)appSpecifiers;
@end

@interface Cask : NSObject
+ (void)loadPrefs;
@end
