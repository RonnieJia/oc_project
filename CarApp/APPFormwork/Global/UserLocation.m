
#import "UserLocation.h"
#import <CoreLocation/CoreLocation.h>
#import <BMKLocationkit/BMKLocationComponent.h>

@interface UserLocation ()<BMKLocationManagerDelegate,BMKLocationAuthDelegate>
{
    __block NSString *userCity;
}

@property(nonatomic, assign)__block NSInteger autoLocationNum;
@property (nonatomic, copy)LocationBlock block;
@property (nonatomic, assign) __block BOOL locationOver;// 完成定位
@property (nonatomic, strong) BMKLocationManager *locationManager;
@end

@implementation UserLocation
+ (instancetype)sharedInstance {
    static UserLocation *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[UserLocation alloc] init];
    });
    return _shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[BMKLocationAuth sharedInstance] checkPermisionWithKey:kBaiDuMapAK authDelegate:self];
        _locationManager = [[BMKLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.coordinateType = BMKLocationCoordinateTypeGCJ02;
        //设置距离过滤参数
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        //设置预期精度参数
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        //设置应用位置类型
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        //设置是否自动停止位置更新
        _locationManager.pausesLocationUpdatesAutomatically = NO;
//        _locationManager.allowsBackgroundLocationUpdates = YES;
        //设置位置获取超时时间
        _locationManager.locationTimeout = 5;
        //设置获取地址信息超时时间
        _locationManager.reGeocodeTimeout = 5;
        
    }
    return self;
}

// 开启定位服务
- (void)findUserLoaction
{
    weakify(self);
    [self.locationManager requestLocationWithReGeocode:YES withNetworkState:YES completionBlock:^(BMKLocation * _Nullable location, BMKLocationNetworkState state, NSError * _Nullable error) {
        if (error) {
            weakSelf.autoLocationNum++;
            if (weakSelf.autoLocationNum<=5) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf findUserLoaction];
                });
            }
        } else {
            weakSelf.userLatitude = [NSString stringWithFormat:@"%f",location.location.coordinate.latitude];
            weakSelf.userLongitude = [NSString stringWithFormat:@"%f",location.location.coordinate.longitude];
            weakSelf.locationOver=YES;
            if (self.block) {
                self.block();
                self.block = nil;
            }
        }
    }];
}

- (void)useUserLocationInfoWithBlock:(LocationBlock)block {
    self.block = [block copy];
    if (self.locationOver) {
        if (self.block) {
            self.block();
            self.block = nil;
        }
    } else {
        [self findUserLoaction];
    }
}


- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    // 1.获取用户位置的对象
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D coordinate = location.coordinate;
    self.userLatitude = [NSString stringWithFormat:@"%f",coordinate.latitude];
    self.userLongitude = [NSString stringWithFormat:@"%f",coordinate.longitude];
    [self changeToCity];
    // 2.停止定位
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    self.locationOver = YES;
    if (self.block) {
        self.block();
        self.block = nil;// 防止多次返回
    }
    if (error.code == kCLErrorDenied) {
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
    }
}


- (NSString *)userCity {
    return userCity;
}

- (void)changeToCity {
    CLLocation * newLocation = [[CLLocation alloc]initWithLatitude:[self.userLatitude doubleValue] longitude:[self.userLongitude doubleValue]];
    
    CLGeocoder *clGeoCoder = [[CLGeocoder alloc] init];
    weakify(self);
    [clGeoCoder reverseGeocodeLocation:newLocation completionHandler: ^(NSArray *placemarks,NSError *error) {
            weakSelf.locationOver = YES;
        if (placemarks.count > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            userCity = placemark.locality;
            if (weakSelf.block) {
                weakSelf.block();
                weakSelf.block = nil;
            }
        }
    }];
}

- (BOOL)canLocation {
    if ([CLLocationManager locationServicesEnabled]  //确定用户的位置服务启用
        &&([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedAlways))
    {
        return YES;
    }
    return NO;
}


+ (void)changeCityToLocation:(NSString *)city withBlock:(CityToLocation)block {
    
    NSString *oreillyAddress = city;
    CLGeocoder *myGeocoder = [[CLGeocoder alloc] init];
    [myGeocoder geocodeAddressString:oreillyAddress completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0 && error == nil) {
            NSLog(@"Found %lu placemark(s).", (unsigned long)[placemarks count]);
            CLPlacemark *firstPlacemark = [placemarks objectAtIndex:0];
            NSString *latStr = [NSString stringWithFormat:@"%f",firstPlacemark.location.coordinate.latitude];
            NSString *lonStr = [NSString stringWithFormat:@"%f",firstPlacemark.location.coordinate.longitude];
            if (block) {
                block(YES, latStr, lonStr);
            }
        }
        else if ([placemarks count] == 0 && error == nil) {
            if (block) {
                block(NO, @"", @"");
            }
        } else if (error != nil) {
            if (block) {
                block(NO, @"", @"");
            }
        }  
    }];
}

@end
