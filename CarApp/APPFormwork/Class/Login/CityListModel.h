
#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CityListModel : BaseModel
@property (nonatomic, assign) NSInteger sort;
@property (nonatomic, strong) NSString *Letter;
@property (nonatomic, strong) NSString *city_id;
@property (nonatomic, strong) NSString *city_name;
@property (nonatomic, strong) NSString *province_id;
@property (nonatomic, strong) NSString *zipcode;

@property (nonatomic, strong) NSString *pinyin;

@end

NS_ASSUME_NONNULL_END
