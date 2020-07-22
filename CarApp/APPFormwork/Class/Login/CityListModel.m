
#import "CityListModel.h"
#import "NSString+Code.h"

@implementation CityListModel
+ (instancetype)modelWithJSONDict:(NSDictionary *)dict {
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        CityListModel *model = [CityListModel new];
        model.sort = IntForKeyInUnserializedJSONDic(dict, @"");
        model.Letter = StringForKeyInUnserializedJSONDic(dict, @"Letter");
        model.city_name = StringForKeyInUnserializedJSONDic(dict, @"city_name");
        model.city_id = StringForKeyInUnserializedJSONDic(dict, @"city_id");
        model.province_id = StringForKeyInUnserializedJSONDic(dict, @"province_id");
        model.zipcode = StringForKeyInUnserializedJSONDic(dict, @"province_id");
        model.pinyin = [[model.city_name transformToChinese] stringByReplacingOccurrencesOfString:@" " withString:@""];
        return model;
    }
    return nil;
}
@end
