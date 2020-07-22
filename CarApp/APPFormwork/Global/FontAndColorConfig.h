
#ifndef FontAndColorConfig_h
#define FontAndColorConfig_h


#define kPageStartIndex         1
#define kPageSize               10



/************** font ******************/
#define kFont(size)                             [UIFont systemFontOfSize:size]
#define kBoldFont(size)                         [UIFont boldSystemFontOfSize:size]
#define kFontWithBigbigestSize                  [UIFont systemFontOfSize:32]
#define kFontWithBigestSize                     [UIFont systemFontOfSize:24]
#define kFontWithBigSize                        [UIFont systemFontOfSize:18]
#define kFontWithDefaultSize                    [UIFont systemFontOfSize:16]
#define kFontWithSmallSize                      [UIFont systemFontOfSize:14]
#define kFontWithSmallestSize                   [UIFont systemFontOfSize:12]




/************** color ******************/
#define kRGBColor(r,g,b)    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define kPlaceholderColor                       [UIColor colorWithHex:@"#999999"]
#define KSepLineColor                           [UIColor colorWithHex:@"#F0F0F0"]
#define kTextBlueColor                          [UIColor colorWithHex:@"#00a3de"]
#define kTextRedColor                           [UIColor colorWithHex:@"#FF5269"]
#define KTextGrayColor                          kRGBColor(153,153,153)
#define KTextDarkColor                          kRGBColor(81,81,81)
#define KTextBlackColor                         [UIColor blackColor]
#define KTextWhiteColor                         [UIColor whiteColor]

#define kNavBarShowBGImg                       YES
#define kNavBarBackgroundImg                   (KScreenHeight > 800)?@"picketback_hx":@"picketback_hx"
#define kBackImgName                            @"back001"
#define KThemeColor                             [UIColor colorWithHex:@"#0873CD"]
#define kTabBarBgColor                          [UIColor colorWithHex:@"#FFFFFF"]
#define kNavTitleColor                          KTextWhiteColor
#define kNavBarBgColo                           [UIColor colorWithHex:@"#3089D5"]
#define kViewControllerBgColor                  [UIColor colorWithHex:@"#F2F2F2"]
#define kRedBGColor                             [UIColor colorWithHex:@"#f2aba9"]
#define KSureBtnBgColor                         KThemeColor
#define KGrayBackViewColor                      [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.00f]
// 发布的borderColor
#define KIssueGrayBorder                        [UIColor colorWithRed:0.73f green:0.73f blue:0.73f alpha:1.00f]

#define KBackGroundColor                         [UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f]

#define kTabBarNormalTitleColor                 kRGBColor(138,138,138)
#define kTabBarNormalDarkTitleColor             [UIColor whiteColor]
#define kTabBarSelectTitleColor                 [UIColor colorWithHex:@"#3089D5"]
#define kTabBarSelectDarkTitleColor             [UIColor whiteColor]
/************** size ******************/

#define KScreenWidth          MIN([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)
#define KScreenHeight         MAX([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)
#define KAUTOSIZE(num)        (num * KScreenWidth / 375.0f)
#define StatusBarHeight     [[UIApplication sharedApplication]statusBarFrame].size.height
#define KNavBarHeight         (44.0f + StatusBarHeight)
#define kIPhoneXBH            (KScreenHeight > 800 ? 34 : 0)
#define KViewNavHeight        (KScreenHeight-44-StatusBarHeight)
#define KViewTabNavHeight     KViewNavHeight-49-kIPhoneXBH
#define KViewRect             CGRectMake(0, 0, KScreenWidth, KViewTabNavHeight)
/************** other ******************/
#define KKeyWindow            [UIApplication sharedApplication].keyWindow


#define kAppFirstRun        @"RJAppNotFirstRun_zhg"
#define kChangeIconNoti     @"change_userIcon_success"
#define kUSERLOGOUT         @"user_logout"
#define kWeixinPayRespNotificarion  @"wx_payresult"
#define kUserLocationNotificarion  @"user_Location"
#define kADImgUrl           @"rjvideo_adImgUrl"
#define kPushToADDetail           @"rjad_detail"


#define kFixReportSuccess @"rj_fixOrder_reportSuc"
#define kFixCompleted @"rj_fixOrder_completed"
#define kFixOrderCancel  @"rj_fixOrder_cancel"
#define kRescueOffer @"rj_rescueOrder_offer"// 救援订单报价成功
#define kRepairOffer @"rj_repairOrder_offer"
#define kRepairCancel @"rj_repairOrder_cancel"
#define kRepairRefund @"rj_repair_refund"// 不认可
#define kRepairCompleted @"rj_repairOrder_completed"




#pragma mark - navigationBarItem的type
typedef enum : NSUInteger {
    NavBarTypeLeft,
    NavBarTypeRight,
} NavBarType;

typedef enum : NSUInteger {
    PayTypeAli = 1,
    PayTypeWechat = 2,
    PayTypeYue = 3,
} PayType;


/// 商城订单状态
typedef NS_ENUM(NSInteger, ShopOrderState) {
    ShopOrderStateWait       = 1,    // 未付款
    ShopOrderStatePayed      = 2,    // 付款
    ShopOrderStateDispatchin = 3,    // 配送
    ShopOrderStateFinished   = 4,    // 已完成
    ShopOrderStateReturn     = 5,    // 退款
} NS_ENUM_AVAILABLE_IOS(6_0);

typedef NS_ENUM(NSInteger, RescueState) {
    RescueStateWait         = 0,    // 待接单
    RescueStateAccept       = 1,    // 已接单
    RescueStateFinish       = 2,    // 已完成
    RescueStateRefuse       = 3,    // 已拒绝
} NS_ENUM_AVAILABLE_IOS(6_0);
typedef NS_ENUM(NSInteger, ReservationState) {
    ReservationStateWait         = 0,    // 待接单
    ReservationStateAccept       = 1,    // 已接单
    ReservationStateRefuse       = 2,    // 已拒绝
} NS_ENUM_AVAILABLE_IOS(6_0);

typedef NS_ENUM(NSInteger, RepairState) {
    RepairStateWait         = 1,    // 待接单
    RepairStateAccept       = 2,    // 维修中
    RepairStateComplete     = 3,    // 已完成
    RepairStateCancel       = 4,    // 已取消
    RepairStateRefuse       = 5,    // 已拒绝
} NS_ENUM_AVAILABLE_IOS(6_0);

typedef NS_ENUM(NSInteger, FixState) {
    FixStateWait         = 1,    // 待维修
    FixStateAccept       = 2,    // 维修中
    FixStateComplete     = 3,    // 已完成
    FixStateCancel       = 4,    // 已取消
} NS_ENUM_AVAILABLE_IOS(6_0);
#endif /* FontAnfColorConfig_h */
