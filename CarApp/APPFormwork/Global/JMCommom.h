//
//  JMCommom.h
//  APPFormwork
//
//  Created by jia on 2019/10/15.
//  Copyright © 2019 RJ. All rights reserved.
//

#ifndef JMCommom_h
#define JMCommom_h

/*========================================User============================================*/
// 需要填写为您自己的 Appkey
#define JMSSAGE_APPKEY @"23c8408e476cb93130517af2"//@"eaddfde77c68d1036f06fdbe"// @"8b60bea42548564527a66b98"
#define JM_CHANNEL @""
#define kJMPassword @"123456"

/// 车主端
#define kCarOwnerWord  @"owner%@"
#define kCarOwnerAppKey  @"d6c237940f4936ae1254dda0"
/// 维修端
#define kRepairWord  @"repair%@"
#define kRepairAppKey  @"23c8408e476cb93130517af2"
/// 配件商
#define kPartsWord  @"parts%@"
#define kPartsAppKey  @"b5f8e67e4cde6cf186a08d45"
/// 挂车厂
#define kTrailerWord  @"trailer%@"
#define kTrailerAppKey  @"d6c237940f4936ae1254dda0"
/// 平台用户
#define kPlatformWord  @"admin"
#define kPlatformAppKey  @"d6c237940f4936ae1254dda0"

#define kuserName @"userName"

#define kPassword @"password"
#define kLogin_NotifiCation @"loginNotification"
#define kFirstLogin @"firstLogin"
#define kHaveLogin @"haveLogin"

#define kimgKey @"imgKey"
#define kmessageKey @"messageKey"
#define kupdateUserInfo @"updateUserInfo"

#define kDBMigrateStartNotification @"DBMigrateStartNotification"
#define kDBMigrateFinishNotification @"DBMigrateFinishNotification"

#define kFriendInvitationNotification @"friendInvitationNotification"

#define kJoinGroupApplicationListDetaultKey @"kJoinGroupApplicationListDetaultKey"
#define kJoinGroupApplicationNotification @"kJoinGroupApplicationNotification"

/*========================================屏幕适配============================================*/

#define kIOSVersions [[[UIDevice currentDevice] systemVersion] floatValue] //获得iOS版本
#define kUIWindow    [[[UIApplication sharedApplication] delegate] window] //获得window
#define kUnderStatusBarStartY (kIOSVersions>=7.0 ? 20 : 0)                 //7.0以上stautsbar不占位置，内容视图的起始位置要往下20

#define kScreenSize           [[UIScreen mainScreen] bounds].size                 //(e.g. 320,480)
#define kScreenWidth          [[UIScreen mainScreen] bounds].size.width           //(e.g. 320)
#define kScreenHeight  (kIOSVersions>=7.0 ? [[UIScreen mainScreen] bounds].size.height + 64 : [[UIScreen mainScreen] bounds].size.height)
#define kIOS7OffHeight (kIOSVersions>=7.0 ? 64 : 0)

#define kApplicationSize      [UIScreen mainScreen].bounds.size       //(e.g. 320,460)
#define kApplicationWidth     [UIScreen mainScreen].bounds.size.width //(e.g. 320)
#define kApplicationHeight    [UIScreen mainScreen].bounds.size.height//不包含状态bar的高度(e.g. 460)

#define kStatusBarHeight         20
#define kNavigationBarHeight     44
#define kNavigationheightForIOS7 64
#define kContentHeight           (kApplicationHeight - kNavigationBarHeight)
#define kTabBarHeight            49
#define kTableRowTitleSize       14
#define maxPopLength             170

#define RGBColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define RGBColorAlpha(r,g,b,alp) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(alp)]

#define UIColorFromRGB(rgbValue) [UIColor  colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0  green:((float)((rgbValue & 0xFF00) >> 8))/255.0  blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBA(rgbValue) [UIColor  colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0  green:((float)((rgbValue & 0xFF00) >> 8))/255.0  blue:((float)(rgbValue & 0xFF))/255.0 alpha:0.7]

#define kNavigationBarColor    UIColorFromRGB(0x3f80de)
#define headDefaltWidth             46
#define headDefaltHeight            46
#define upLoadImgWidth            720

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

// UI 相关
#define JMSG_UIIMAGE(_FILE_)          ([UIImage imageNamed:(_FILE_)])
#define JMSG_CLEARCOLOR               ([UIColor clearColor])
#define JMSG_FONTSIZE(_SIZE_)         ([UIFont systemFontOfSize:_SIZE_])

// View的right、left、bottom、top、width、height
#define JMSG_ViewRight(View)              (View.frame.origin.x + View.frame.size.width)
#define JMSG_ViewLeft(View)               (View.frame.origin.x)
#define JMSG_ViewBottom(View)             (View.frame.origin.y + View.frame.size.height)
#define JMSG_ViewTop(View)                (View.frame.origin.y)
#define JMSG_ViewWidth(View)              (View.frame.size.width)
#define JMSG_ViewHeight(View)             (View.frame.size.height)


// 版本大于iOS7
#define     IOS7_OR_HIGHER         ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
#define     IOS8_OR_HIGHER         ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
#define     IOS8_3_OR_HIGHER       ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.3f)
#define     IOS9_0_OR_HIGHER       ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0f)

//GCD
#define JMSGMAINTHREAD(block) dispatch_async(dispatch_get_main_queue(), block)








#endif /* JMCommom_h */
