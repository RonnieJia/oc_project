// 救援记录订单详情
#import "BaseTableViewController.h"
@class NotesOrderUserView;
@class RescueModel;

NS_ASSUME_NONNULL_BEGIN

@interface RescueOrderViewController : BaseTableViewController
@property (weak, nonatomic) IBOutlet NotesOrderUserView *orderUserInfo;
@property (weak, nonatomic) IBOutlet UIView *moneyView;// 费用明细
@property (weak, nonatomic) IBOutlet UILabel *partMoneyLabel;// 配件费
@property (weak, nonatomic) IBOutlet UILabel *timeMoneyLabel;// 工时费
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;// 合计费用
@property (weak, nonatomic) IBOutlet UIView *rescueView;// 救援信息
@property (weak, nonatomic) IBOutlet UIView *orderView;// 订单明细
@property (weak, nonatomic) IBOutlet UILabel *orderNum;// 订单编号
@property (weak, nonatomic) IBOutlet UILabel *orderStateLabel;// 订单状态
@property (weak, nonatomic) IBOutlet UILabel *orderStartTimeLabel;// 下单时间
@property (weak, nonatomic) IBOutlet UILabel *acceptTimeLabel;// 接单时间
@property (weak, nonatomic) IBOutlet UILabel *moneyTimeLabel;// 报价时间
@property (weak, nonatomic) IBOutlet UILabel *sureTimeLabel;// 确认时间
@property (weak, nonatomic) IBOutlet UILabel *payTimeLabel;// 支付时间
@property (weak, nonatomic) IBOutlet UILabel *payTypeLabel;// 支付方式


@property (nonatomic, assign) RescueState rescueState;
@property (nonatomic, strong) RescueModel *rescueModel;

@property(nonatomic, copy)void(^rescueRepairComplete)();
@property(nonatomic, copy)void(^rescueRepairRefuse)(RescueModel *model, BOOL complete);

@end

NS_ASSUME_NONNULL_END
