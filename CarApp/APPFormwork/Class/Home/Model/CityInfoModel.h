//
//  CityInfoModel.h
//  APPFormwork
#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CityInfoModel : BaseModel
@property (nonatomic, strong) NSString *firstLetter;
@property (nonatomic, strong) NSMutableArray *citys;
+ (NSArray *)cityInfoList:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
