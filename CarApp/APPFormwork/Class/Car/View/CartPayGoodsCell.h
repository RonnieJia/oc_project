//

#import "RJBaseTableViewCell.h"
@class ShopChangeCountView;
@class CartModel, ShopGoodsModel, SkuModel;

NS_ASSUME_NONNULL_BEGIN

@interface CartPayGoodsCell : RJBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet ShopChangeCountView *numView;

/// 立即购买
@property (nonatomic, assign) BOOL buyNow;
- (void)displsyBuy:(ShopGoodsModel *)goods sku:(SkuModel *)sku num:(NSInteger)num;

/// 购物车
@property (nonatomic, strong) CartModel *model;


@property(nonatomic, copy)void(^payChangeNumBlock)(NSInteger num);
@end

NS_ASSUME_NONNULL_END
