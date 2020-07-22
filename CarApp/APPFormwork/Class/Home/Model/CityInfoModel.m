//
//  CityInfoModel.m
//  APPFormwork

#import "CityInfoModel.h"

@implementation CityInfoModel
+ (NSArray *)cityInfoList:(NSDictionary *)dic {
    NSMutableArray *arr = [NSMutableArray array];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        NSArray *letters = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
        for (int i = 0; i<letters.count; i++) {
            NSString *key = letters[i];
            NSArray *citys = ObjForKeyInUnserializedJSONDic(dic, key);
            if (citys && [citys isKindOfClass:[NSArray class]] && citys.count>0) {
                CityInfoModel *model = [CityInfoModel new];
                model.firstLetter = key;
                [model.citys addObjectsFromArray:citys];
                [arr addObject:model];
            }
        }
    }
    return arr;
}

- (NSMutableArray *)citys {
    if (!_citys) {
        _citys = [@[] mutableCopy];
    }
    return _citys;
}
@end
