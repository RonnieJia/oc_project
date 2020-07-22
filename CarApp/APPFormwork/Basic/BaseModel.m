
#import "BaseModel.h"
#import "NSArray+Extension.h"

@implementation BaseModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{}
// json的key转换为属性名字
+ (NSDictionary *)modelCustomPropertyMapper {
    return nil;
}
//model中包含其他model的数组,class
+ (NSDictionary *)modelSubModelList{
    //@{a:Data}
    return nil;
}
+ (instancetype)modelWithJSONDict:(NSDictionary *)dict {
    NSDictionary *changeDic = [self modelCustomPropertyMapper];
    NSDictionary *propertyDic = [NSArray getPropertyDictionary:self.class];
    NSDictionary *modelSubDic = [self modelSubModelList];
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        BaseModel *model = [self new];
        for (NSString *key in dict.allKeys) {
            NSString *name = key;
            if (changeDic && [changeDic isKindOfClass:[NSDictionary class]] && [changeDic.allKeys containsObject:key]) {
                name = changeDic[key];
            }
            if (propertyDic && [propertyDic isKindOfClass:[NSDictionary class]] && [propertyDic.allKeys containsObject:name]) {
                NSString *type = propertyDic[name];
                if ([type hasPrefix:@"T@"]) {
                    if ([type containsString:@"String"]) {
                        [model setValue:StringForKeyInUnserializedJSONDic(dict, key) forKey:name];
                    } else if ([type containsString:@"Array"]) {
                        if (modelSubDic && [modelSubDic isKindOfClass:[NSDictionary class]] && [modelSubDic.allKeys containsObject:name]) {
                            [model setValue:[NSClassFromString(StringForKeyInUnserializedJSONDic(modelSubDic, name)) listWithJSONArray:ObjForKeyInUnserializedJSONDic(dict, key)] forKey:name];
                        } else {
                            [model setValue:dict[key] forKey:name];
                        }
                    } else {
                        if (modelSubDic && [modelSubDic isKindOfClass:[NSDictionary class]] && [modelSubDic.allKeys containsObject:name]) {
                            [model setValue:[NSClassFromString(StringForKeyInUnserializedJSONDic(modelSubDic, name)) modelWithJSONDict:ObjForKeyInUnserializedJSONDic(dict, key)] forKey:name];
                        } else {
                            [model setValue:dict[key] forKey:name];
                        }
                    }
                } else {
                    [model setValue:dict[key] forKey:name];
                }
            } else {
                continue;
            }
        }
        return model;
    }
    return nil;
}
+ (NSArray *)listWithJSONArray:(NSArray *)array {
    NSMutableArray *temp = [NSMutableArray array];
    if (array && [array isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in array) {
            BaseModel *model = [self modelWithJSONDict:dict];
            if (model) {
                [temp addObject:model];
            }
        }
    }
    return temp;
}
@end
