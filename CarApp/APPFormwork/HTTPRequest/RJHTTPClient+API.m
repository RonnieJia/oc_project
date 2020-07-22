
#import "RJHTTPClient+API.h"
#import "UserLocation.h"
#import <objc/runtime.h>

static NSInteger const kWXDType = 3;

@implementation RJHTTPClient (API)
- (NSURLSessionDataTask *)uploadImage:(UIImage *)image completion:(HTTPCompletion)completion {
    return [self postPath:@"index/upload" paramters:nil uploadPicture:image name:@"image" completion:completion];
}

- (NSURLSessionDataTask *)fetchStartPageCompletion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(@(kWXDType), @"type", paramters);
    return [self postPath:@"index/config_start" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)getVerifyCodeWithPhone:(NSString *)phone
                                            type:(MobileCodeType)type
                                      completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(phone, @"phone", paramters);
    AddObjectForKeyIntoDictionary(@(type), @"type", paramters);
    NSMutableString *number = [NSMutableString string];
    for (int i = 0; i<6; i++) {
        int x = arc4random()%10;
        [number appendFormat:@"%d",x];
    }
    AddObjectForKeyIntoDictionary(number, @"number", paramters);
    return [self postPath:@"index/sendcode_bymobile" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)userRegisWithMobile:(NSString *)phone
                                       verify:(NSString *)verify
                                       invite:(NSString *)invite
                                          pwd:(NSString *)pwd
                                   completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(phone, @"phone", paramters);
    AddObjectForKeyIntoDictionary(pwd, @"pwd", paramters);
    AddObjectForKeyIntoDictionary(verify, @"code", paramters);
//    AddObjectForKeyIntoDictionary(invite, @"inviter", paramters);
    AddObjectForKeyIntoDictionary(IsStringEmptyOrNull([UserLocation sharedInstance].userLatitude)?@"0":[UserLocation sharedInstance].userLatitude, @"lat", paramters);
    AddObjectForKeyIntoDictionary(IsStringEmptyOrNull([UserLocation sharedInstance].userLongitude)?@"0":[UserLocation sharedInstance].userLongitude, @"lng", paramters);
    
    return [self postPath:@"repair/reg" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)userLogin:(NSString *)phone pwd:(NSString *)pwd completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(phone, @"number", paramters);
    AddObjectForKeyIntoDictionary(pwd, @"pwd", paramters);
    return [self postPath:@"repair/sign" paramters:paramters completion:^(WebResponse *response) {
        
        if (response.code == WebResponseCodeSuccess) {
            [CurrentUserInfo userLogin:ObjForKeyInUnserializedJSONDic(response.responseObject, @"result")];
        }
        if (completion) {
            completion(response);
        }
    }];
}

- (NSURLSessionDataTask *)lossPwd:(NSString *)phone code:(NSString *)code pwd:(NSString *)pwd completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(phone, @"phone", paramters);
    AddObjectForKeyIntoDictionary(pwd, @"pwd", paramters);
    AddObjectForKeyIntoDictionary(code, @"code", paramters);
    return [self postPath:@"repair/recharge_pwd" paramters:paramters completion:completion];
}


- (NSURLSessionDataTask *)changePwd:(NSString *)phone code:(NSString *)code pwd:(NSString *)pwd completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(phone, @"phone", paramters);
    AddObjectForKeyIntoDictionary(pwd, @"o_pwd", paramters);
    AddObjectForKeyIntoDictionary(code, @"number", paramters);
    AddObjectForKeyIntoDictionary(@(kWXDType), @"type", paramters);
    return [self postPath:@"index/change_pwd" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)changeMobile:(NSString *)phone code:(NSString *)code completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(phone, @"phone", paramters);
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"uid", paramters);
    AddObjectForKeyIntoDictionary(code, @"number", paramters);
    AddObjectForKeyIntoDictionary(@(kWXDType), @"type", paramters);
    return [self postPath:@"index/change_phone" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchQuestionWithPage:(NSInteger)page completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(@(page), @"page", paramters);
    AddObjectForKeyIntoDictionary(@(kWXDType), @"type", paramters);
    return [self postPath:@"index/question_list" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchQuestionDetail:(NSString *)q_id completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(q_id, @"id", paramters);
    return [self postPath:@"index/question_lists" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchAboutCompletion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(@(kWXDType), @"type", paramters);
    return [self postPath:@"index/config_about" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)feedback:(NSString *)content mobile:(NSString *)mobile completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(@(4), @"f_type", paramters);
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"f_uid", paramters);
    AddObjectForKeyIntoDictionary(content, @"f_content", paramters);
    AddObjectForKeyIntoDictionary(mobile, @"f_phone", paramters);
    return [self postPath:@"index/feedback" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchUserAgreementYinsi:(BOOL)yinsi completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    if (yinsi) {
        AddObjectForKeyIntoDictionary(@(4), @"type", paramters);
    } else {
        AddObjectForKeyIntoDictionary(@(kWXDType), @"type", paramters);
    }
    return [self postPath:@"index/reg_agreement" paramters:paramters completion:completion];
}
@end
