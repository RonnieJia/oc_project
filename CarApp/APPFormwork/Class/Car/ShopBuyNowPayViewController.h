// 订单详情-立即购买

#import "BaseTableViewController.h"
@class ShopGoodsModel;
@class SkuModel;

NS_ASSUME_NONNULL_BEGIN

@interface ShopBuyNowPayViewController : BaseTableViewController
@property (nonatomic, strong) ShopGoodsModel *goodsModel;
@property (nonatomic, assign) NSInteger num;
@property (nonatomic, strong) SkuModel *sku;
@end

NS_ASSUME_NONNULL_END
