

#import <Foundation/Foundation.h>

typedef void(^LocationBlock)();
typedef void(^CityToLocation)(BOOL success, NSString *lat, NSString *lon);

@interface UserLocation : NSObject
@property(nonatomic, strong)NSString *userLatitude;
@property(nonatomic, strong)NSString *userLongitude;

+ (instancetype)sharedInstance;
// 能否定位
- (BOOL)canLocation;
// 获取所在城市名字
- (NSString *)userCity;
// 开始定位
- (void)findUserLoaction;
- (void)useUserLocationInfoWithBlock:(LocationBlock)block;

+ (void)changeCityToLocation:(NSString *)city withBlock:(CityToLocation)block;
@end
