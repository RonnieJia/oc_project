//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SkuModel : BaseModel
@property (nonatomic, strong) NSString *sale_price;
@property (nonatomic, strong) NSString *sku_id;
@property (nonatomic, strong) NSString *sku_name;
@property (nonatomic, assign) NSInteger stock;
@end

NS_ASSUME_NONNULL_END
