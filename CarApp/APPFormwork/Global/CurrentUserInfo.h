#import <Foundation/Foundation.h>
@class AddressModel;

@interface CurrentUserInfo : NSObject
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, strong) AddressModel *addressModel;
@property (nonatomic, strong) NSString *balance;

@property (nonatomic, strong) NSString *userIcon;
@property (nonatomic, strong) NSString *alipay_name;
@property (nonatomic, strong) NSString *alipay_number;

@property (nonatomic, assign) BOOL showMsg;


+ (CurrentUserInfo *)sharedInstance;
+ (void)userLogin:(NSDictionary *)dict;
+ (void)userLogout;
+ (void)userInfo:(NSDictionary *)dict;

+ (void)loginJMessage;
@end
