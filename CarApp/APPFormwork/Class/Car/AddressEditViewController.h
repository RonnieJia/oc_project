//

#import "BaseTableViewController.h"
@class AddressModel;

NS_ASSUME_NONNULL_BEGIN

@interface AddressEditViewController : BaseTableViewController
@property (nonatomic, strong) AddressModel *model;
@property(nonatomic, copy)void(^reloadAddressBlock)();
@end

NS_ASSUME_NONNULL_END
