// 商品列表

#import "RJBaseTableViewCell.h"
@class ShopGoodsModel;

NS_ASSUME_NONNULL_BEGIN

@interface GoodsListTableCell : RJBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cateNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *salePriceLabel;

@property (nonatomic, strong) ShopGoodsModel *goodsModel;
@end

NS_ASSUME_NONNULL_END
