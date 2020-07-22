// 商城订单

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShopOrderHeaderView : UIView
@property(nonatomic, copy)void(^shopOrderCallBack)(NSInteger index);
@property (nonatomic, assign) NSInteger selectIndex;

@end

NS_ASSUME_NONNULL_END
