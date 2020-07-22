// 商城订单

#import "RJBaseTableViewCell.h"
@class ShopOrderModel;

NS_ASSUME_NONNULL_BEGIN

@interface ShopOderCell : RJBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIView *typeView;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rBtnWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lBtnWidthConstraint;

@property (nonatomic, assign) ShopOrderState state;// 订单状态
@property (nonatomic, strong) ShopOrderModel *orderModel;

@property(nonatomic, copy)void(^shopOrderCellBlock)(NSInteger type, ShopOrderState state, ShopOrderModel *model);//0-申请退款 1-确认收货

@end

NS_ASSUME_NONNULL_END
