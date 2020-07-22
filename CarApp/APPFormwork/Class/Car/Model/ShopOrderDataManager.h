

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShopOrderDataManager : NSObject
+ (NSArray *)orderInfoList:(NSDictionary *)dic orderState:(ShopOrderState)state;
+ (NSArray *)orderReturnInfoList:(NSDictionary *)dic orderState:(ShopOrderState)orderState;
@end

NS_ASSUME_NONNULL_END
