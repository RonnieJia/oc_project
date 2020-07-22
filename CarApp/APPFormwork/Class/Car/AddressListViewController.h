// 地址管理

#import "BaseTableViewController.h"
@class AddressModel;
NS_ASSUME_NONNULL_BEGIN

@interface AddressListViewController : BaseTableViewController
@property (nonatomic, assign) BOOL chooseAddress;
@property (nonatomic, copy) void(^addressBlock) (AddressModel *address);

@end

NS_ASSUME_NONNULL_END
