// 商品搜索的热门
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoodsSearchHotView : UIView
@property(nonatomic, copy)void(^GoodsSearchHot)(NSString *hot);
@end

NS_ASSUME_NONNULL_END
