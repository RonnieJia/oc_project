#import "CurrentUserInfo.h"
#import "HTTPWebAPIUrl.h"
#import "JPUSHService.h"
#import "AddressModel.h"
#import "AppEntrance.h"

@interface CurrentUserInfo ()<JMessageDelegate>
@end

@implementation CurrentUserInfo
+ (CurrentUserInfo *)sharedInstance {
    static CurrentUserInfo *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CurrentUserInfo alloc] init];
    });
    return _sharedInstance;
}


+ (void)userLogin:(NSDictionary *)dict {
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        CurrentUserInfo *user = [CurrentUserInfo sharedInstance];
        user.userId = StringForKeyInUnserializedJSONDic(dict, @"r_id");
        [self setPush];
    }
}
+ (void)userInfo:(NSDictionary *)dict {
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        CurrentUserInfo *user = [CurrentUserInfo sharedInstance];
    } else if (dict && [dict isKindOfClass:[NSArray class]]) {
        NSArray *arr = (NSArray *)dict;
        [self userInfo:[arr firstObject]];
    }
}

+ (void)setPush {
    NSMutableArray *tagsList = [NSMutableArray array];
    NSString *alias = [NSString stringWithFormat:@"%@",[CurrentUserInfo sharedInstance].userId];
    
    if (alias){
        NSMutableSet * tags = [[NSMutableSet alloc] init];
        //        NSMutableArray *tagsList = [NSMutableArray arrayWithArray:@[@"1",@"2",@"3",@"4",@"5",@"6"]];
        NSInteger maxLength = 1000;
        if (tagsList.count >maxLength) {
            NSInteger tagListLength =tagsList.count;
            NSRange tempRange =NSMakeRange(maxLength, tagListLength - maxLength);
            [tagsList removeObjectsInRange:tempRange];
        }
        
        [tagsList addObject:alias];
        NSMutableArray *arrayTemp = [NSMutableArray array];
        for (NSString *temp in tagsList) {
            NSString *uftString = [temp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            int lengt = [self stringConvertToInt:uftString];
            if (lengt>=40) {
                [arrayTemp addObject:temp];
            }
        }
        [tagsList removeObjectsInArray:arrayTemp];
        [tags addObjectsFromArray:tagsList];
        [JPUSHService setTags:tags completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
            NSLog(@"---%@===%@===code==%@",tags,iTags,@(iResCode));
//            [[[UIAlertView alloc] initWithTitle:@"极光推送注册成功" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil] show];
        } seq:0];
        [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
            [JPUSHService setAlias:alias completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                NSLog(@"-----%@--%@ ==code==%@",alias,iAlias,@(iResCode));
            } seq:0];
        } seq:0];
    }else{
        
    }
}

+ (int)stringConvertToInt:(NSString*)strtemp
{
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++)
    {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return (strlength+1)/2;
}


- (BOOL)isLogin {
    return (self.userId.length > 0);
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}

+ (void)userLogout {
    CurrentUserInfo *user = [CurrentUserInfo sharedInstance];
    user.userId = nil;
    user.addressModel = nil;
    ClearUser();
    [self
     logoutJMessage];
}

+ (void)logoutJMessage {
    [JMessage removeAllDelegates];
    [JMSGUser logout:^(id resultObject, NSError *error) {
        if (!error) {
            RJLog(@"\n ********-JMessage logout success-********\n");
        }
    }];
    
}


//- (NSString *)userId {
//    return @"2";
//}
/*
- (void)userLoginChat {
    weakify(self);
    [kRJHTTPClient fetchUserToken:self.userId completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [[RCIMClient sharedRCIMClient] connectWithToken:weakSelf.token success:^(NSString *userId) {
                RJLog(@"登陆成功");
            } error:^(RCConnectErrorCode status) {
                RJLog(@"登陆失败");
            } tokenIncorrect:^{
                RJLog(@"token错误");
            }];
        }
    }];
}*/

+ (void)loginJMessage {
    [JMessage addDelegate:[CurrentUserInfo sharedInstance] withConversation:nil];
    [self loginWithUserID:[CurrentUserInfo sharedInstance].userId];
}

- (void)onReceiveUserLoginStatusChangeEvent:(JMSGUserLoginStatusChangeEvent *)event {
    if (event.eventType == kJMSGEventNotificationLoginKicked || event.eventType == kJMSGEventNotificationServerAlterPassword) {// 被踢
        [AppEntrance setLoginForRoot];
        [CurrentUserInfo userLogout];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您的账号在其它设备上登录" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    } else if (event.eventType == kJMSGEventNotificationUserLoginStatusUnexpected) {
        
    }
}

+ (void)loginWithUserID:(NSString *)uid {
    if (![CurrentUserInfo sharedInstance].isLogin || !uid || ![uid isEqualToString:[CurrentUserInfo sharedInstance].userId]) {
        return;
    }
    NSString *userName = [NSString stringWithFormat:@"repair%@",uid];
    [JMSGUser loginWithUsername:userName password:kJMPassword completionHandler:^(id resultObject, NSError *error) {
        if (!error) {
            RJLog(@"\n ********-JMessage login success(auto)-********\n");
        } else {
            [self loginJMessageFaild:uid];
        }
    }];
}
                          
+ (void)loginJMessageFaild:(NSString *)uid {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loginWithUserID:uid];
    });
}
@end
