
#import "RJHTTPClient.h"
@class OrderPayModel;
typedef NS_ENUM(NSUInteger, ShopType) {
    ShopTypeCart = 0,// 购物车
    ShopTypeOrder = 1,// 订单
    ShopTypeChange = 2,// 立即兑换
};

typedef NS_ENUM(NSUInteger, OrderState) {
    OrderStateAll = 0,// 全部订单
    OrderStatePay = 1,//已支付
    OrderStateSend = 2,// 已配送
    OrderStateComple = 3,// 已完成
    OrderStateReturn = 4,// 退款
};

typedef NS_ENUM(NSUInteger, GoodsSortType) {
    GoodsSortTypeNormal = 0,// 综合排序
    GoodsSortTypeNormalPriceUp = 1,// 价格升
    GoodsSortTypeNormalPriceDown = 2,// 价格降序
    GoodsSortTypeNormalSaleDown = 3,// 销量降序
    GoodsSortTypeNormalSaleUp = 4,// 销量升
};

typedef NS_ENUM(NSUInteger, MobileCodeType) {
    MobileCodeTypeRegis = 1,
    MobileCodeTypeResetPwd = 2,
    MobileCodeTypeChangeMobile = 3,
    MobileCodeTypeLossPWD = 4,
};

typedef NS_ENUM(NSUInteger, HTTPPageType) {
    HTTPPageTypeAgreement=1,
    HTTPPageTypeAbout = 2,
    HTTPPageTypeHelp = 3,
};

typedef NS_ENUM(NSUInteger, BannerType) {
    BannerTypeHomeBanner = 1,
    BannerTypeStart = 4,
    BannerTypyHomeCenter = 7,
    BannerTypyJingXuan = 8,
    BannerTypyPicTui = 9,
};

NS_ASSUME_NONNULL_BEGIN

@interface RJHTTPClient (API)

/**
 上传图片
 @param image 图片
 */
- (NSURLSessionDataTask *)uploadImage:(UIImage *)image completion:(HTTPCompletion)completion;

/**
 启动页
 */
- (NSURLSessionDataTask *)fetchStartPageCompletion:(HTTPCompletion)completion;

/**
 获取手机验证码
 @param phone 手机号
 */
- (NSURLSessionDataTask *)getVerifyCodeWithPhone:(NSString *)phone
                                            type:(MobileCodeType)type
                                      completion:(HTTPCompletion)completion;


/**
 用户注册
 
 @param phone 手机号
 @param verify 验证码
 @param invite 邀请码
 @param pwd 密码
 */
- (NSURLSessionDataTask *)userRegisWithMobile:(NSString *)phone
                                       verify:(NSString *)verify
                                       invite:(NSString *)invite
                                          pwd:(NSString *)pwd
                                   completion:(HTTPCompletion)completion;


/**
 登录
 @param phone 手机号
 @param pwd 密码
 */
- (NSURLSessionDataTask *)userLogin:(NSString *)phone
                                   pwd:(NSString *)pwd
                             completion:(HTTPCompletion)completion;

/// 忘记密码
/// @param phone 手机号
/// @param code 验证码
/// @param pwd 密码
- (NSURLSessionDataTask *)lossPwd:(NSString *)phone code:(NSString *)code pwd:(NSString *)pwd completion:(HTTPCompletion)completion;

/**
 修改密码
 @param phone 手机号
 @param code 验证码
 @param pwd 密码
 */
- (NSURLSessionDataTask *)changePwd:(NSString *)phone code:(NSString *)code pwd:(NSString *)pwd completion:(HTTPCompletion)completion;

/**
 修改手机号
 @param phone 手机
 @param code 验证码
 */
- (NSURLSessionDataTask *)changeMobile:(NSString *)phone code:(NSString *)code completion:(HTTPCompletion)completion;

/**
 常见问题
 @param page 页码
 */
- (NSURLSessionDataTask *)fetchQuestionWithPage:(NSInteger)page completion:(HTTPCompletion)completion;

/**
 常见问题详情
 @param q_id id
 */
- (NSURLSessionDataTask *)fetchQuestionDetail:(NSString *)q_id completion:(HTTPCompletion)completion;

/**
 关于我们
 */
- (NSURLSessionDataTask *)fetchAboutCompletion:(HTTPCompletion)completion;

/**
 意见反馈
 @param content 内容
 @param mobile 联系方式
 */
- (NSURLSessionDataTask *)feedback:(NSString *)content mobile:(NSString *)mobile completion:(HTTPCompletion)completion;

/// 获取用户协议
- (NSURLSessionDataTask *)fetchUserAgreementYinsi:(BOOL)yinsi completion:(HTTPCompletion)completion;
@end

NS_ASSUME_NONNULL_END
