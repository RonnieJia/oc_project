// 商品详情
#import <UIKit/UIKit.h>
@class ShopGoodsModel;

NS_ASSUME_NONNULL_BEGIN

@interface GoodsDetailBottomView : UIView
@property (nonatomic, strong) ShopGoodsModel *goodsModel;
@property(nonatomic, copy)void(^buyGoodsBlock)(NSInteger type);
@property(nonatomic, copy)void(^serviceChatBlock)();
@end

NS_ASSUME_NONNULL_END
