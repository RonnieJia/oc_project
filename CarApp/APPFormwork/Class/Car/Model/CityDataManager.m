//
#import "CityDataManager.h"

@implementation CityDataManager
+(instancetype)sharedInstance {
    static CityDataManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[CityDataManager alloc] init];
    });
    return _manager;
}

-(NSMutableArray *)provincesArray {
    if (!_provincesArray) {
        _provincesArray = [@[] mutableCopy];
    }
    return _provincesArray;
}
@end

@implementation ProvinceModel

- (void)loadCityListCompletion:(HTTPCompletion)completion {
    weakify(self);
    [kRJHTTPClient fetchCityList:self.provinceid completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            NSArray *citys = [CityModel listWithJSONArray:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"list")];
            [weakSelf.citysArray removeAllObjects];
            [weakSelf.citysArray addObjectsFromArray:citys];
            weakSelf.loadCity = YES;
        }
        if (completion) {
            completion(response);
        }
    }];
}
- (NSMutableArray *)citysArray {
    if (!_citysArray) {
        _citysArray = [@[] mutableCopy];
    }
    return _citysArray;
}

@end


@implementation CityModel
@end



