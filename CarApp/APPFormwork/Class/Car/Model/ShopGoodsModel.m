

#import "ShopGoodsModel.h"

@implementation ShopGoodsModel
+ (ShopGoodsModel *)goodsDetail:(NSDictionary *)dic {
    ShopGoodsModel *model = [ShopGoodsModel new];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        model.goods_id = StringForKeyInUnserializedJSONDic(dic, @"goods_id");
        model.desc = StringForKeyInUnserializedJSONDic(dic, @"description");
        model.goods_name = StringForKeyInUnserializedJSONDic(dic, @"goods_name");
        model.parts_address = StringForKeyInUnserializedJSONDic(dic, @"parts_address");
        model.parts_id = StringForKeyInUnserializedJSONDic(dic, @"parts_id");
        model.parts_name = StringForKeyInUnserializedJSONDic(dic, @"parts_name");
        model.parts_phone = StringForKeyInUnserializedJSONDic(dic, @"parts_phone");
        model.photo = StringForKeyInUnserializedJSONDic(dic, @"photo");
        model.price = StringForKeyInUnserializedJSONDic(dic, @"price");
        model.sale_price = StringForKeyInUnserializedJSONDic(dic, @"sale_price");
        model.sku = [SkuModel listWithJSONArray:ObjForKeyInUnserializedJSONDic(dic, @"sku")];
        model.is_collection = BoolForKeyInUnserializedJSONDic(dic, @"is_collection");
        model.shipping_fee = StringForKeyInUnserializedJSONDic(dic, @"shipping_fee");
        NSArray *pic = ObjForKeyInUnserializedJSONDic(dic, @"picture");
        NSMutableArray *imgs = [NSMutableArray array];
        for (NSDictionary *imgDic in pic) {
            NSString *imgStr = StringForKeyInUnserializedJSONDic(imgDic, @"address");
            if (!IsStringEmptyOrNull(imgStr)) {
                [imgs addObject:imgStr];
            }
        }
        NSString *imgStr = [imgs componentsJoinedByString:@","];
        model.picture = imgStr;
    }
    return model;
}
@end
