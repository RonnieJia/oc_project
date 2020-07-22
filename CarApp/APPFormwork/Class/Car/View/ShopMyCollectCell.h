// 我的收藏

#import "RJBaseTableViewCell.h"
@class ShopGoodsModel;

NS_ASSUME_NONNULL_BEGIN

@interface ShopMyCollectCell : RJBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *namelabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (nonatomic, strong) ShopGoodsModel *goodsModel;
@end

NS_ASSUME_NONNULL_END
