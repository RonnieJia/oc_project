//

#import "BaseModel.h"
#import "SkuModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShopGoodsModel : BaseModel
@property (nonatomic, strong) NSString *category_id_1;
@property (nonatomic, strong) NSString *category_name;// 分类名称
@property (nonatomic, strong) NSString *goods_id;// 商品id
@property (nonatomic, strong) NSString *goods_name;// 商品名称
@property (nonatomic, strong) NSString *picture;// 图片
@property (nonatomic, strong) NSString *pictures;
@property (nonatomic, strong) NSString *price;// 原价
@property (nonatomic, strong) NSString *sale_price;// 销售价


@property (nonatomic, strong) NSString *parts_address;
@property (nonatomic, strong) NSString *parts_id;
@property (nonatomic, strong) NSString *parts_name;// 配件商
@property (nonatomic, strong) NSString *parts_phone;//配件商手机
@property (nonatomic, strong) NSString *photo;// 配件商头像
@property (nonatomic, strong) NSArray<SkuModel *> *sku;
@property (nonatomic, strong) NSString *desc;// 商品详情
@property (nonatomic, assign) BOOL is_collection;//是否收藏 0未收藏 1已收藏
@property (nonatomic, strong) NSString *shipping_fee;// 邮费 0包邮


+ (ShopGoodsModel *)goodsDetail:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
