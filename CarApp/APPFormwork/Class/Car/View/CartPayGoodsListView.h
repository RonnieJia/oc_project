//

#import <UIKit/UIKit.h>
@class ShopGoodsModel, SkuModel;

NS_ASSUME_NONNULL_BEGIN

@interface CartPayGoodsListView : UIView
@property (nonatomic, strong) NSArray *dataArray;
@property(nonatomic, copy)void(^changeNumBlock)(NSInteger num);

@property (nonatomic, assign) BOOL buyNow;
- (void)buy:(ShopGoodsModel *)goods sku:(SkuModel *)sku num:(NSInteger)num;
@end

NS_ASSUME_NONNULL_END
