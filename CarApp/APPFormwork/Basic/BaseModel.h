

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    RJDataTypeString,
    RJDataTypeTq,//NSInteger、long long
    RJDataTypeTi,//int
    RJDataTypeTf,//float
    RJDataTypeTd,//double、CGFloat
    
} RJDataType;

@interface BaseModel : NSObject
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

+ (NSDictionary *)modelCustomPropertyMapper;
+ (instancetype)modelWithJSONDict:(NSDictionary *)dict;
+ (NSArray *)listWithJSONArray:(NSArray *)array;
@end




