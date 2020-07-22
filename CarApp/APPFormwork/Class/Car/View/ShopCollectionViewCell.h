// 

#import <UIKit/UIKit.h>
@class ShopGoodsModel;

NS_ASSUME_NONNULL_BEGIN

@interface ShopCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *goodsName;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *cateLabel;




@property (nonatomic, strong) ShopGoodsModel *goodsModel;
@end

NS_ASSUME_NONNULL_END
