
#import "AppDelegate.h"
#import "AppEntrance.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import <UMShare/UMShare.h>
#import "UserLocation.h"
//#import "IQKeyboardManager.h"
#import "LaunchViewController.h"
#import "JPUSHService.h"
#import "RJHTTPClient+Car.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BMKLocationkit/BMKLocationComponent.h>
#import "CYLTabBarController.h"



#import "RescueNotesViewController.h"
#import "FixNotesViewController.h"
#import "RepairNotesViewController.h"
#import "ReservationNotesViewController.h"
#import "RJNavigationController.h"


// 如果需要使用idfa功能所需要引入的头文件（可选）
//#import <AdSupport/AdSupport.h>

static NSString *appKey = @"ee44aed50be9499929c91450";//354afa2e334ed77a376dca82
static NSString *channel = @"APP Store";

@interface AppDelegate ()<WXApiDelegate, JPUSHRegisterDelegate>
@property (nonatomic, assign) BOOL notiPush;

@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    //去除 TabBar 自带的顶部阴影
//    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    [self configUmengShareInfo];
    [self regisJPUSH:launchOptions];
//    [self configAliSDK];
    [self startBaiDuMap];
    [[UserLocation sharedInstance] findUserLoaction];
    [RJNetworkManager sharedInstace];// 检测网络变化
    [self initialJMessage:launchOptions];
    [AppEntrance setRootViewController];
    self.notiPush = YES;
    [self.window makeKeyAndVisible];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.notiPush = NO;
    });
    return YES;
}

- (void)startBaiDuMap {
    BMKMapManager *mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [mapManager start:kBaiDuMapAK generalDelegate:nil];
    if (!ret) {
        RJLog(@"\n*******baidu map start failed*********\n");
    }
    //设置为GCJ02坐标
    [BMKMapManager setCoordinateTypeUsedInBaiduMapSDK: BMK_COORDTYPE_COMMON];
}

- (void)initialJMessage:(NSDictionary *)launchOptions {
    if (RJDebug) {
        [JMessage setDebugMode];
    }
    
    [JMessage setupJMessage:launchOptions appKey:JMSSAGE_APPKEY channel:channel apsForProduction:YES category:nil messageRoaming:YES];
    
    /// Required - 注册 APNs 通知
        //可以添加自定义categories
    [JMessage registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)regisJPUSH:(NSDictionary *)launchOptions {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    [JPUSHService setupWithOption:launchOptions appKey:JMSSAGE_APPKEY
                          channel:channel
                 apsForProduction:YES
            advertisingIdentifier:nil];
    
    // Optional
    // 获取IDFA
    // 如需使用IDFA功能请添加此代码并在初始化方法的advertisingIdentifier参数中填写对应值
//    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    
}

- (void)configUmengShareInfo
{
    //打开日志
    [[UMSocialManager defaultManager] openLog:NO];
    //设置友盟appkey
//    [[UMSocialManager defaultManager] setUmSocialAppkey:@"58328db1a40fa317d10016a1"];
    
    // 获取友盟social版本号
    RJLog(@"UMeng social version: %@", [UMSocialGlobal umSocialSDKVersion]);
    
    //各平台的详细配置
    //设置微信的appId和appKey
    BOOL wechat = [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:kWeiXinAppKey appSecret:kWeiXinAppSecret redirectURL:@"http://mobile.umeng.com/social"];
    
    //设置分享到QQ互联的appId和appKey
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:kQQAppID  appSecret:kQQAppKey redirectURL:@"http://mobile.umeng.com/social"];
    
    //设置支持没有客户端情况下使用SSO授权
    //支付宝的appId和appKey
//    [[UMSocialManager defaultManager] setPlaform: UMSocialPlatformType_AlipaySession appKey:@"2015111700822536" appSecret:nil redirectURL:@"http://mobile.umeng.com/social"];
    
    //设置新浪的appId和appKey
//    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"3921700954"  appSecret:@"04b48b094faeb16683c32669824ebdad" redirectURL:@"http://sns.whalecloud.com/sina2/callback"];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.notiPush = YES;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [JMessage resetBadge];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [JMessage resetBadge];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.notiPush = NO;
    });
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JMessage registerDeviceToken:deviceToken];
    [JPUSHService registerDeviceToken:deviceToken];
}
/*
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
*/
#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    
    completionHandler(UNNotificationPresentationOptionAlert);
    // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)pushGetTopViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}
- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}



// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {

        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        if ([[CurrentUserInfo sharedInstance] isLogin]) {
            UIViewController *vc = [self pushGetTopViewController];
            if (vc && vc.navigationController) {
            }
        }
        
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (![CurrentUserInfo sharedInstance].showMsg) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"msgShowBadge" object:@(YES)];
    }
    if (self.notiPush) {
        self.notiPush = NO;
        if ([CurrentUserInfo sharedInstance].isLogin) {
            NSDictionary *custom = ObjForKeyInUnserializedJSONDic(userInfo, @"custom");
            if (custom && [custom.allKeys containsObject:@"state"]) {
                NSInteger state = IntForKeyInUnserializedJSONDic(custom, @"state");
                [self notoPushWithType:state];
            }
        }
    }
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}
- (void)notoPushWithType:(NSInteger)type {
    [JMessage resetBadge];
    switch (type) {
        case 1:
        {
            ReservationNotesViewController *repair = [[ReservationNotesViewController alloc] init];
            repair.needBack = YES;
            [self.window.rootViewController presentViewController:[[RJNavigationController alloc] initWithRootViewController:repair] animated:YES completion:nil];
        }
            break;
        case 4:
        case 6:
        case 8:
        case 10:
        {
            FixNotesViewController *fix = [[FixNotesViewController alloc] init];
            fix.needBack=YES;
            NSInteger state = 1;
            if (type==6) {
                state = 4;
            } else if (type == 8) {
                state = 2;
            } else if (type == 10) {
                state=3;
            }
            fix.state =state;
            [self.window.rootViewController presentViewController:[[RJNavigationController alloc] initWithRootViewController:fix] animated:YES completion:nil];
        }
            break;
        case 11:
        case 16:
        case 18:
        {
            RepairNotesViewController *repair = [[RepairNotesViewController alloc] init];
            repair.needAddBack = YES;
            NSInteger state = 1;
            if (type==16) {
                state = 2;
            } else if (type == 18) {
                state = 4;
            }
            repair.state = state;
            [self.window.rootViewController presentViewController:[[RJNavigationController alloc] initWithRootViewController:repair] animated:YES completion:nil];
        }
            break;
        case 20:
        case 25:
        {
            RescueNotesViewController *rescue = [[RescueNotesViewController alloc] init];
            rescue.needBack = YES;
            if (type==25) {
                rescue.state = 2;
            }
            [self.window.rootViewController presentViewController:[[RJNavigationController alloc] initWithRootViewController:rescue] animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
//    NSLog(@"%@",@"aaa");
//    [[RJWZTool sharedInstance] receiveClockNotiForeground];
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        if ([url.host isEqualToString:@"safepay"]) {
            //跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                RJLog(@"result = %@",resultDic);
                [[NSNotificationCenter defaultCenter] postNotificationName:kALiPayResultNoti object:resultDic];
            }];
        } else if ([url.absoluteString hasPrefix:@"wx"]) {
            return [WXApi handleOpenURL:url delegate:self];
        }
    }
    return result;
}

/**
 微信支付
 */
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[PayResp class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kWeixinPayRespNotificarion object:resp];
    } else if ([resp isKindOfClass:[SendAuthResp class]]) {
        
    } else {
        if (resp.errCode == WXSuccess) {
            
        }
    }
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    NSString *wxPay = [NSString stringWithFormat:@"%@://pay",kWeiXinAppKey];
    if ([url.absoluteString hasPrefix:wxPay]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        if ([url.host isEqualToString:@"safepay"]) {
            //跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                RJLog(@"result = %@",resultDic);
                [[NSNotificationCenter defaultCenter] postNotificationName:kALiPayResultNoti object:resultDic];
            }];
        } else if ([url.absoluteString hasPrefix:@"wx"]) {
            return [WXApi handleOpenURL:url delegate:self];
        }
    }
    return result;
}

@end
