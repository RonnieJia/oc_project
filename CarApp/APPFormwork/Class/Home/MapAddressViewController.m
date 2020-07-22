//
//  MapAddressViewController.m
//  APPFormwork
#import "MapAddressViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BMKLocationkit/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "RJBaseTableViewCell.h"

@interface MapAddressViewController ()<BMKMapViewDelegate,BMKLocationManagerDelegate,BMKSuggestionSearchDelegate,BMKGeoCodeSearchDelegate,UITextFieldDelegate>
@property(nonatomic, strong)BMKMapView *mapView;
@property(nonatomic, strong)BMKLocationManager *locationManager;
@property (nonatomic, strong) BMKUserLocation *userLocation; //当前位置对象
@property(nonatomic, strong) BMKSuggestionSearch *search;
@property(nonatomic, strong) BMKGeoCodeSearch *codeSearch;
@property(nonatomic, assign)BOOL geoCode;
@property(nonatomic, strong)UIView *flagView;
@property(nonatomic, weak)UITextField *textField;
@property(nonatomic, strong)NSString *userCity;
@end

@implementation MapAddressViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.mapView];
    [self.locationManager startUpdatingLocation];
    [self.view addSubview:self.flagView];
    self.flagView.hidden = YES;
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth-100, 30)];
    textField.backgroundColor = [UIColor whiteColor];
    textField.placeholder = @"请输入搜索位置";
    textField.layer.cornerRadius = 15;
    textField.clipsToBounds = YES;
    textField.delegate = self;
    textField.font = kFontWithSmallSize;
    textField.leftView = RJCreateSimpleView(CGRectMake(0, 0, 10, 30), KTextWhiteColor);
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.rightView = RJCreateSimpleView(CGRectMake(0, 0, 10, 30), KTextWhiteColor);
    textField.rightViewMode = UITextFieldViewModeAlways;
    self.navigationItem.titleView = textField;
    self.textField = textField;
    weakify(self);
    [self setNavBarBtnWithType:NavBarTypeRight title:@"确定" action:^{
        [weakSelf startSearch];
    }];
}

- (void)startSearch {
    if (self.textField.text.length==0) {
        return;
    }
    [self tapAction];
    BMKSuggestionSearchOption *option = [[BMKSuggestionSearchOption alloc] init];
    option.cityname = self.userCity?:@"济南";
    option.keyword = self.textField.text;
    [self.search suggestionSearch:option];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.flagView.hidden=NO;
    [self.view bringSubviewToFront:self.flagView];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.flagView.hidden=YES;
}
- (void)showListTableView {
    if (self.tableView && self.tableView.superview) {
        return;
    }
    self.mapView.height = KViewNavHeight-240;
    self.tableView.frame = CGRectMake(0, KViewNavHeight-240, KScreenWidth, 240);
    [self.view addSubview:self.tableView];
}

#pragma mark - BMKLocationManagerDelegate
/**
 @brief 当定位发生错误时，会调用代理的此方法
 @param manager 定位 BMKLocationManager 类
 @param error 返回的错误，参考 CLError
 */
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error {
    NSLog(@"定位失败");
}

/**
 @brief 该方法为BMKLocationManager提供设备朝向的回调方法
 @param manager 提供该定位结果的BMKLocationManager类的实例
 @param heading 设备的朝向结果
 */
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
    if (!heading) {
        return;
    }
    NSLog(@"用户方向更新");
    
    self.userLocation.heading = heading;
    [_mapView updateLocationData:self.userLocation];
}

/**
 @brief 连续定位回调函数
 @param manager 定位 BMKLocationManager 类
 @param location 定位结果，参考BMKLocation
 @param error 错误信息。
 */
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error {
    if (error) {
        NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
    }
    if (!location) {
        return;
    }
    
    self.userLocation.location = location.location;
    //实现该方法，否则定位图标不出现
    [self.mapView updateLocationData:self.userLocation];
    [self.mapView setCenterCoordinate:self.userLocation.location.coordinate animated:YES];
    [self reverseGeoCode];
}

/**
 反向地理编码检索结果回调
 
 @param searcher 检索对象
 @param result 反向地理编码检索结果
 @param error 错误码，@see BMKCloudErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        if (!self.geoCode) {
            self.geoCode = YES;
            self.userCity = result.addressDetail.city;
            if (result.poiList && result.poiList.count>0) {
                [self showListTableView];
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:result.poiList];
                [self.tableView reloadData];
            }
            
        }
    }
    else {
            NSLog(@"检索失败");
    }
}

/**
 *返回suggestion搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetSuggestionResult:(BMKSuggestionSearch*)searcher result:( BMKSuggestionSearchResult*)result errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        if (result.suggestionList && result.suggestionList.count>0) {
            [self showListTableView];
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:result.suggestionList];
            [self.tableView reloadData];
        }
    }
    else {
            NSLog(@"检索失败");
    }
}


- (void)reverseGeoCode {
    BMKReverseGeoCodeSearchOption *reverseOption = [[BMKReverseGeoCodeSearchOption alloc] init];
    reverseOption.location = self.userLocation.location.coordinate;
    reverseOption.isLatestAdmin = YES;
    reverseOption.pageNum = 0;
    reverseOption.pageSize=10;
    BOOL flag = [self.codeSearch reverseGeoCode:reverseOption];
    if (flag) {
        
    } else {
        
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RJBaseTableViewCell *cell = [RJBaseTableViewCell cellWithTableView:tableView];
    cell.textLabel.font = kFontWithSmallSize;
    cell.textLabel.textColor = KTextDarkColor;
    BMKPoiInfo *info = self.dataArray[indexPath.row];
    if ([info isKindOfClass:[BMKPoiInfo class]]) {
        cell.textLabel.text = info.address;
    } else {
        BMKSuggestionInfo *sINfo = (BMKSuggestionInfo *)info;
        cell.textLabel.text = sINfo.key;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BMKPoiInfo *info = self.dataArray[indexPath.row];
    NSString *str;
    if ([info isKindOfClass:[BMKPoiInfo class]]) {
        str = info.address;
        if (self.chooseMapAddress) {
            self.chooseMapAddress(str,info.pt.latitude,info.pt.longitude);
        }
    } else {
        BMKSuggestionInfo *sINfo = (BMKSuggestionInfo *)info;
        str = sINfo.key;
        if (self.chooseMapAddress) {
            self.chooseMapAddress(str,sINfo.location.latitude,sINfo.location.longitude);
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BMKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KViewNavHeight)];
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;
        _mapView.zoomLevel = 17;
    }
    return _mapView;
}

-(BMKLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[BMKLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.coordinateType = BMKLocationCoordinateTypeGCJ02;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        _locationManager.allowsBackgroundLocationUpdates = NO;
        _locationManager.locationTimeout = 10;
    }
    return _locationManager;
}

- (BMKUserLocation *)userLocation {
    if (!_userLocation) {
        _userLocation = [[BMKUserLocation alloc] init];
    }
    return _userLocation;
}
- (BMKSuggestionSearch *)search {
    if (!_search) {
        _search = [[BMKSuggestionSearch alloc] init];
        _search.delegate = self;
    }
    return _search;
}

-(BMKGeoCodeSearch *)codeSearch {
    if (!_codeSearch ) {
        _codeSearch = [[BMKGeoCodeSearch alloc] init];
        _codeSearch.delegate=self;
    }
    return _codeSearch;
}

- (UIView *)flagView {
    if (!_flagView) {
        _flagView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KViewNavHeight)];
        _flagView.backgroundColor = [KTextBlackColor colorWithAlphaComponent:0.3];
        [_flagView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
    }
    return _flagView;
}

- (void)tapAction {
    [self.textField resignFirstResponder];
}
@end
