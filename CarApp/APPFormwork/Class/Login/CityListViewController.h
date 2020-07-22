

#import "BaseTableViewController.h"
@class CityListModel;

NS_ASSUME_NONNULL_BEGIN

@interface CityListViewController : BaseTableViewController
@property (nonatomic, assign, getter=isLogin) BOOL login;
@property(nonatomic, strong)CityListModel *cityModel;
@property(nonatomic, copy)void(^cityChanged)();
@end

NS_ASSUME_NONNULL_END
