//

#import "BaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RefundReasonViewController : BaseTableViewController
/// type：0-申请退款  1-申请取消订单
@property (nonatomic, assign) NSInteger type;

/// 取消订单类型  0-维修订单 1-报修
@property (nonatomic, assign) NSInteger cancelType;

@property (nonatomic, strong) NSString *order_id;
@property (nonatomic, strong) id obj;



@property(nonatomic,copy)void(^refuseMoneySuccess)();
@end

NS_ASSUME_NONNULL_END
