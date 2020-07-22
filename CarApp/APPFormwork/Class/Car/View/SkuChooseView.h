
#import <UIKit/UIKit.h>
@class ShopGoodsModel;
@class SkuModel;

NS_ASSUME_NONNULL_BEGIN

typedef void(^GoodsDetailSkuBlock)(NSString *sku);

@interface SkuChooseView : UIView<UITextFieldDelegate>

+ (instancetype)sharedInstance;
- (void)showGoods:(ShopGoodsModel *)model buy:(BOOL)buy;


@property(nonatomic, copy)GoodsDetailSkuBlock block;
@property(nonatomic, copy)void(^addCartCompletion)(ShopGoodsModel *model, NSInteger num);
@property(nonatomic, copy)void(^buyNowCompletion)(ShopGoodsModel *model, NSInteger num, SkuModel *sku);
@property (nonatomic, assign) BOOL buyNow;
@property (nonatomic, assign) BOOL chooseType;

@end

NS_ASSUME_NONNULL_END
