
#import "RepairModel.h"

@implementation RepairModel
- (void)loadDetail:(NSDictionary *)dic {
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        for (NSString *key in dic.allKeys) {
            [self setValue:StringForKeyInUnserializedJSONDic(dic, key) forKey:key];
        }
    }
}
@end
