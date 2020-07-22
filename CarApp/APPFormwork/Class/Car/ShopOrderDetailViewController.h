// 商城订单详情
#import "BaseTableViewController.h"
#import "ShopOrderAddressView.h"
#import "ShopOrderDataManager.h"
@class ShopOrderModel;

NS_ASSUME_NONNULL_BEGIN

@interface ShopOrderDetailViewController : BaseTableViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet ShopOrderAddressView *addressView;
@property (weak, nonatomic) IBOutlet UIView *goodsList;
@property (weak, nonatomic) IBOutlet UIImageView *goodsIcon;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameL;
@property (weak, nonatomic) IBOutlet UILabel *goodsSkuL;
@property (weak, nonatomic) IBOutlet UILabel *goodsPriceL;
@property (weak, nonatomic) IBOutlet UILabel *goodsNumL;
@property (weak, nonatomic) IBOutlet UIView *moneyInfoView;
@property (weak, nonatomic) IBOutlet UILabel *goodsMoneyLabel;// 商品总价
@property (weak, nonatomic) IBOutlet UILabel *sendMoneyLabel;// 运费
@property (weak, nonatomic) IBOutlet UILabel *payMoneyLabel;// 合计
@property (weak, nonatomic) IBOutlet UIView *orderInfoVIew;
@property (weak, nonatomic) IBOutlet UIView *orderInfoContentView;
@property (weak, nonatomic) IBOutlet UIView *remarkView;
@property (weak, nonatomic) IBOutlet UIView *otherInfoView;// 快递、退货
@property (weak, nonatomic) IBOutlet UIView *otherContentView;
@property (weak, nonatomic) IBOutlet UIButton *returnBtn;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;
@property (weak, nonatomic) IBOutlet UILabel *remarkLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goodsListHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orderContentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remarkHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherContentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *returnTrailing;
@property (weak, nonatomic) IBOutlet UILabel *otherTitleL;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property (weak, nonatomic) IBOutlet UIView *returnView;
@property (weak, nonatomic) IBOutlet UIView *returnContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *returnContentHeight;


@property (nonatomic, strong) ShopOrderModel *orderModel;


@property(nonatomic, copy)void(^orderPaySuccess)();
@property(nonatomic, copy)void(^orderReceiveComplete)();
@property(nonatomic, copy)void(^orderRefuseComplete)();
@end

NS_ASSUME_NONNULL_END
