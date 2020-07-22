// 购物车

#import <Foundation/Foundation.h>
@class CartModel;
NS_ASSUME_NONNULL_BEGIN

@interface ShopCartDataManager : NSObject
+ (instancetype)sharedInstance;
+ (void)destroyInstance;
- (NSArray<CartModel *> *)fetchCartList:(NSArray *)arr;
- (void)cart:(NSString *)cart_id remove:(BOOL)remove;
@property (nonatomic, strong) NSMutableArray *chooseCartArray;
@property (nonatomic, assign) CGFloat money;
@end

NS_ASSUME_NONNULL_END
