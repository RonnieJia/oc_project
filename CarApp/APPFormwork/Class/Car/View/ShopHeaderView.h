// 

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShopHeaderView : UIView
@property(nonatomic, copy)void(^shopHeaderBannerBlock)(NSString * _Nullable goods_id);
- (void)display:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
