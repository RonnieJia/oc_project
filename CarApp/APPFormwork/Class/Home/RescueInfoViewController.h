// 救援信息

#import "BaseTableViewController.h"
#import "RescueModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RescueInfoViewController : BaseTableViewController
@property (nonatomic, strong) RescueModel *rescueModel;
@property (nonatomic, assign)BOOL detail;
@property(nonatomic, copy)void(^rescueOrderStateChange)(BOOL accept, RescueModel *model);
@end

NS_ASSUME_NONNULL_END
