// 商品详情

#import <UIKit/UIKit.h>
@class ShopGoodsModel;

NS_ASSUME_NONNULL_BEGIN

@interface GoodsDetailInfoView : UIView
- (instancetype)initWithGoods:(ShopGoodsModel *)goods;
@property (nonatomic, strong) ShopGoodsModel *goodsModel;
@property(nonatomic, copy)void(^goodsBtnBlock)(NSInteger index);
@property(nonatomic, weak)UILabel *typeLabel;
@property(nonatomic, weak)UILabel *addressLabel;
@end

NS_ASSUME_NONNULL_END
