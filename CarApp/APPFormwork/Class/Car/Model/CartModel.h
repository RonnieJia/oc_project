//
#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CartModel : BaseModel
@property (nonatomic, strong) NSString *cart_id;
@property (nonatomic, strong) NSString *goods_id;
@property (nonatomic, strong) NSString *goods_name;
@property (nonatomic, strong) NSString *goods_picture;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *sku_name;
@property (nonatomic, assign) NSInteger num;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, strong) NSString *sale_price;
@property (nonatomic, strong) NSString *shipping_fee;
@property (nonatomic, strong) NSString *sku_id;
@property (nonatomic, assign) NSInteger stock;


@property (nonatomic, assign) BOOL choose;

@end

NS_ASSUME_NONNULL_END
