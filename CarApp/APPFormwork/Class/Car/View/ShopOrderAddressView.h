// 商城订单地址
#import <UIKit/UIKit.h>
@class AddressModel;

NS_ASSUME_NONNULL_BEGIN

@interface ShopOrderAddressView : UIView
@property(nonatomic, copy)void(^addressListBlock)();
@property (nonatomic, strong) AddressModel *addressModel;
@end

NS_ASSUME_NONNULL_END
