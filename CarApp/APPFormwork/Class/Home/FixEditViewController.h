// 维修订单报价

#import "BaseTableViewController.h"
@class FixModel, RepairModel;
NS_ASSUME_NONNULL_BEGIN

@interface FixEditViewController : BaseTableViewController
@property (nonatomic, strong) FixModel *fixModel;
@property (nonatomic, assign) BOOL repair;// 报修订单
@property (nonatomic, strong) RepairModel *repairModel;

@end

NS_ASSUME_NONNULL_END
