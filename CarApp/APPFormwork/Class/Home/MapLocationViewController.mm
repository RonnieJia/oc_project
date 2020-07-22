//

#import "MapLocationViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import "UserLocation.h"

//复用annotationView的指定唯一标识
static NSString *annotationViewIdentifier = @"com.Baidu.BMKDrivingRouteSearch";

@interface MapLocationViewController ()<BMKMapViewDelegate, BMKRouteSearchDelegate>
@property (nonatomic, strong) BMKMapView *mapView;
@property(nonatomic, strong)BMKRouteSearch *routeSearch;
@end

@implementation MapLocationViewController
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
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    [_mapView setZoomLevel:17];//将当前地图显示缩放等级设置为17级
    
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
    double lat = [self.lat doubleValue];
    double lon = [self.lon doubleValue];
    if (lat==0||lon==0) {
        lat = 36.67;
        lon = 116.98;
    }
    _mapView.centerCoordinate = CLLocationCoordinate2DMake(lat, lon);
    annotation.coordinate = CLLocationCoordinate2DMake(lat, lon);
    //设置标注的标题
    annotation.title = self.oName;
    //副标题
    annotation.subtitle = self.address;
    [_mapView addAnnotation:annotation];
    
    UIButton *back = RJCreateImageButton(CGRectMake(0, StatusBarHeight, 60, 44), [UIImage imageNamed:@"back002_xl"], nil);
    [self.view addSubview:back];
    [back addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *luxianView = RJCreateSimpleView(CGRectMake(0, KScreenHeight-kIPhoneXBH-60, KScreenWidth, 60+kIPhoneXBH), KTextWhiteColor);
    [self.view addSubview:luxianView];

    UIButton *lineBtn = RJCreateTextButton(CGRectMake(KScreenWidth-60, 15, 50, 30), kFontWithSmallSize, KTextWhiteColor, createImageWithColor(KThemeColor), @"路线");
    [luxianView addSubview:lineBtn];
    [lineBtn addTarget:self action:@selector(startLine) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *nameL = RJCreateDefaultLable(CGRectMake(10, 10, lineBtn.left-20, 20), kFontWithDefaultSize, KTextBlackColor, self.oName);
    [luxianView addSubview:nameL];
    
    UILabel *addressL = RJCreateDefaultLable(CGRectMake(10, nameL.bottom, nameL.width, 20), kFontWithSmallSize, KTextGrayColor, self.address);
    [luxianView addSubview:addressL];
    
}

- (void)startLine {
    UserLocation *loca = [UserLocation sharedInstance];
    if (loca.canLocation) {
        if (loca.userLatitude && loca.userLongitude) {
            [self startSearchLine];
        } else {
            ShowAutoHideMBProgressHUD(self.view,@"正在定位您当前的位置");
            [loca useUserLocationInfoWithBlock:^{
                [self startSearchLine];
            }];
        }
        
    } else {
        ShowAutoHideMBProgressHUD(self.view, @"请允许瞪羚康达访问您的位置信息");
    }
}

- (void)startSearchLine {
    UserLocation *loca = [UserLocation sharedInstance];
    BMKPlanNode* start = [[BMKPlanNode alloc] init];
    start.pt = CLLocationCoordinate2DMake([loca.userLatitude doubleValue], [loca.userLongitude doubleValue]);
    BMKPlanNode* end = [[BMKPlanNode alloc] init];
    end.pt = CLLocationCoordinate2DMake([self.lat doubleValue], [self.lon doubleValue]);
    BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
    drivingRouteSearchOption.from = start;
    drivingRouteSearchOption.to = end;
    BOOL flag = [self.routeSearch drivingSearch:drivingRouteSearchOption];
    if (flag) {
        NSLog(@"驾车规划检索发送成功");
    } else{
        NSLog(@"驾车规划检索发送失败");
    }
}

#pragma mark - BMKMapViewDelegate
/**
 根据anntation生成对应的annotationView
 
 @param mapView 地图View
 @param annotation 指定的标注
 @return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        /**
         根据指定标识查找一个可被复用的标注，用此方法来代替新创建一个标注，返回可被复用的标注
         */
        BMKPinAnnotationView *annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewIdentifier];
        NSBundle *bundle = [NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mapapi.bundle"]];
        if (annotation.title && [annotation.title isEqualToString:@"start_rou"]) {
            NSString *file = [[bundle resourcePath] stringByAppendingPathComponent:@"images/icon_nav_start"];
            //annotationView显示的图片，默认是大头针
            annotationView.image = [UIImage imageWithContentsOfFile:file];
        } else if (annotation.title && [annotation.title isEqualToString:@"end_rou"]) {
            NSString *file = [[bundle resourcePath] stringByAppendingPathComponent:@"images/icon_nav_end"];
            //annotationView显示的图片，默认是大头针
            annotationView.image = [UIImage imageWithContentsOfFile:file];
        } else {
            NSString *file = [[bundle resourcePath] stringByAppendingPathComponent:@"images/pin_red"];
            //annotationView显示的图片，默认是大头针
            annotationView.image = [UIImage imageWithContentsOfFile:file];
        }
        return annotationView;
//
//        BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewIdentifier];
//        if (!annotationView) {
//            /**
//             初始化并返回一个annotationView
//
//             @param annotation 关联的annotation对象
//             @param reuseIdentifier 如果要重用view，传入一个字符串，否则设为nil，建议重用view
//             @return 初始化成功则返回annotationView，否则返回nil
//             */
//            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewIdentifier];
//            NSBundle *bundle = [NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mapapi.bundle"]];
//            NSString *file = [[bundle resourcePath] stringByAppendingPathComponent:@"images/icon_nav_bus"];
//            //annotationView显示的图片，默认是大头针
//            annotationView.image = [UIImage imageWithContentsOfFile:file];
//        }
//        return annotationView;
    }
    return nil;
}
#pragma mark - BMKRouteSearchDelegate
/**
 返回驾车路线检索结果

 @param searcher 检索对象
 @param result 检索结果，类型为BMKDrivingRouteResult
 @param error 错误码 @see BMKSearchErrorCode
 */
- (void)onGetDrivingRouteResult:(BMKRouteSearch *)searcher result:(BMKDrivingRouteResult *)result errorCode:(BMKSearchErrorCode)error {
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        //+polylineWithPoints: count:坐标点的个数
        __block NSUInteger pointCount = 0;
        //获取所有驾车路线中第一条路线
        BMKDrivingRouteLine *routeline = (BMKDrivingRouteLine *)result.routes[0];
        NSInteger stepsCount = routeline.steps.count;
        //遍历驾车路线中的所有路段
        [routeline.steps enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //获取驾车路线中的每条路段
            BMKDrivingStep *step = routeline.steps[idx];
            
            //初始化标注类BMKPointAnnotation的实例
            BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
            //设置标注的经纬度坐标为子路段的入口经纬度
            annotation.coordinate = step.entrace.location;
            //设置标注的标题为子路段的说明
            annotation.title = step.entraceInstruction;
            if (idx==0) {
                annotation.title = @"start_rou";
                [_mapView addAnnotation:annotation];
            } else if (idx == stepsCount-1) {
                annotation.title = @"end_rou";
                [_mapView addAnnotation:annotation];
            }
            /**

             当前地图添加标注，需要实现BMKMapViewDelegate的-mapView:viewForAnnotation:方法
             来生成标注对应的View
             @param annotation 要添加的标注
             */
            //统计路段所经过的地理坐标集合内点的个数
            pointCount += step.pointsCount;
        }];
        
        //+polylineWithPoints: count:指定的直角坐标点数组
        BMKMapPoint *points = new BMKMapPoint[pointCount];
        __block NSUInteger j = 0;
        //遍历驾车路线中的所有路段
        [routeline.steps enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //获取驾车路线中的每条路段
            BMKDrivingStep *step = routeline.steps[idx];
            //遍历每条路段所经过的地理坐标集合点
            for (NSUInteger i = 0; i < step.pointsCount; i ++) {
                //将每条路段所经过的地理坐标点赋值给points
                points[j].x = step.points[i].x;
                points[j].y = step.points[i].y;
                j ++;
            }
        }];
        //根据指定直角坐标点生成一段折线
        BMKPolyline *polyline = [BMKPolyline polylineWithPoints:points count:pointCount];
        /**
         向地图View添加Overlay，需要实现BMKMapViewDelegate的-mapView:viewForOverlay:方法
         来生成标注对应的View
         
         @param overlay 要添加的overlay
         */
        [_mapView addOverlay:polyline];
        //根据polyline设置地图范围
        [self mapViewFitPolyline:polyline withMapView:self.mapView];
    } else {
        ShowAutoHideMBProgressHUD(self.view, @"未发现合适路线");
    }
}

//根据polyline设置地图范围
- (void)mapViewFitPolyline:(BMKPolyline *)polyline withMapView:(BMKMapView *)mapView {
    double leftTop_x, leftTop_y, rightBottom_x, rightBottom_y;
    if (polyline.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyline.points[0];
    leftTop_x = pt.x;
    leftTop_y = pt.y;
    //左上方的点lefttop坐标（leftTop_x，leftTop_y）
    rightBottom_x = pt.x;
    rightBottom_y = pt.y;
    //右底部的点rightbottom坐标（rightBottom_x，rightBottom_y）
    for (int i = 1; i < polyline.pointCount; i++) {
        BMKMapPoint point = polyline.points[i];
        if (point.x < leftTop_x) {
            leftTop_x = point.x;
        }
        if (point.x > rightBottom_x) {
            rightBottom_x = point.x;
        }
        if (point.y < leftTop_y) {
            leftTop_y = point.y;
        }
        if (point.y > rightBottom_y) {
            rightBottom_y = point.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(leftTop_x , leftTop_y);
    rect.size = BMKMapSizeMake(rightBottom_x - leftTop_x, rightBottom_y - leftTop_y);
    UIEdgeInsets padding = UIEdgeInsetsMake(20, 10, 20, 10);
    [mapView fitVisibleMapRect:rect edgePadding:padding withAnimated:YES];
}

/**
 根据overlay生成对应的BMKOverlayView
 
 @param mapView 地图View
 @param overlay 指定的overlay
 @return 生成的覆盖物View
 */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay {
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        //初始化一个overlay并返回相应的BMKPolylineView的实例
        BMKPolylineView *polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        //设置polylineView的填充色
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        //设置polylineView的画笔（边框）颜色
        polylineView.strokeColor = [KThemeColor colorWithAlphaComponent:0.7];
        //设置polygonView的线宽度
        polylineView.lineWidth = 5;
        return polylineView;
    }
    return nil;
}

- (BMKRouteSearch *)routeSearch {
    if (!_routeSearch) {
        _routeSearch = [[BMKRouteSearch alloc] init];
        _routeSearch.delegate = self;
    }
    return _routeSearch;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
