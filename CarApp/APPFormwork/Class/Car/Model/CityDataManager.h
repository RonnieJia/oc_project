//
//  CityDataManager.h

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CityDataManager : NSObject
+(instancetype)sharedInstance;
@property (nonatomic, assign) BOOL loadProvince;
@property (nonatomic, strong) NSMutableArray *provincesArray;
@end


@interface ProvinceModel : BaseModel
@property (nonatomic, strong) NSString *provinceid;
@property (nonatomic, strong) NSString *province;
- (void)loadCityListCompletion:(HTTPCompletion)completion;
@property (nonatomic, assign) BOOL loadCity;
@property (nonatomic, strong) NSMutableArray *citysArray;

@end

@interface CityModel : BaseModel
@property (nonatomic, strong) NSString *cityid;
@property (nonatomic, strong) NSString *city;
@end

NS_ASSUME_NONNULL_END
