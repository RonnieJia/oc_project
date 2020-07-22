
#import "NSArray+Extension.h"
#import "NSString+Code.h"
#import <objc/runtime.h>

@implementation NSArray (Extension)
+ (instancetype)getProperties:(Class)cls {
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(NSClassFromString(@"BaseModel"), &count);
    NSMutableArray *pArray = [NSMutableArray array];
    for (int i = 0; i<count; i++) {
        objc_property_t property = properties[i];
        const char *pName = property_getName(property);
        NSString *name = [NSString stringWithCString:pName encoding:NSUTF8StringEncoding];
        
//        const char *pType = property_getAttributes(property);
//        NSString *type = [NSString stringWithCString:pType encoding:NSUTF8StringEncoding];
        /*Ti,N,V_b
         Td,N,V_c
         Tf,N,V_d
         Td,N,V_e
         Tq,N,V_f
         T*,N,V_g
         T@"NSString",N,V_h
         T@"NSArray",N,V_i
         T@"NSMutableArray",N,V_j
         T@"NSDictionary",N,V_k
         */
        @try {
            [pArray addObject:name];
        } @catch (NSException *exception) {
            
        }
        
    }
    return pArray;
}

+ (NSDictionary *)getPropertyDictionary:(Class)cls {
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    NSMutableDictionary *pDic = [NSMutableDictionary dictionary];
    for (int i = 0; i<count; i++) {
        objc_property_t property = properties[i];
        const char *pName = property_getName(property);
        NSString *name = [NSString stringWithCString:pName encoding:NSUTF8StringEncoding];
        
        const char *pType = property_getAttributes(property);
        NSString *type = [NSString stringWithCString:pType encoding:NSUTF8StringEncoding];
        /*Ti,N,V_b
         Td,N,V_c
         Tf,N,V_d
         Td,N,V_e
         Tq,N,V_f
         T*,N,V_g
         T@"NSString",N,V_h
         T@"NSArray",N,V_i
         T@"NSMutableArray",N,V_j
         T@"NSDictionary",N,V_k
         */
        if (name && type) {
           [pDic setObject:type forKey:name];
        }
        
    }
    return pDic;
}


- (NSArray *)arrayWithPinYinFirstLetterFormat
{
    if (![self count]) {
        return [NSMutableArray array];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSMutableArray array] forKey:@"#"];
    for (int i = 'A'; i <= 'Z'; i++) {
        [dict setObject:[NSMutableArray array]
                 forKey:[NSString stringWithUTF8String:(const char *)&i]];
    }
    
    for (NSString *words in self) {
        NSString *firstLetter = [words getFirstLetter];
        NSMutableArray *array = dict[firstLetter];
        [array addObject:words];
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    for (int i = 'A'; i <= 'Z'; i++) {
        NSString *firstLetter = [NSString stringWithUTF8String:(const char *)&i];
        NSMutableArray *array = dict[firstLetter];
        if ([array count]) {
            [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSString *word1 = obj1;
                NSString *word2 = obj2;
                return [word1 localizedCompare:word2];
            }];
            NSDictionary *resultDict = @{@"firstLetter": firstLetter,
                                         @"content": array};
            [resultArray addObject:resultDict];
        }
    }
    
    if ([dict[@"#"] count]) {
        NSMutableArray *array = dict[@"#"];
        [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *word1 = obj1;
            NSString *word2 = obj2;
            return [word1 localizedCompare:word2];
        }];
        NSDictionary *resultDict = @{@"firstLetter": @"#",
                                     @"content": array};
        [resultArray addObject:resultDict];
    }
    return resultArray;
}

@end
