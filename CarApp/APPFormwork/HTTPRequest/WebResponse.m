

#import "WebResponse.h"
#import "HTTPWebAPIUrl.h"

@implementation WebResponse

+ (instancetype)webResponseWithCode:(WebResponseCode)code message:(NSString *)msg {
    WebResponse *response = [[WebResponse alloc] init];
    response.code = code;
    response.message = msg;
    return response;
}
+ (instancetype)netCannotConnect {
    return [self webResponseWithCode:WebResponseCodeNetError message:@"当前网络不可用"];
}

+ (instancetype)webResponseWithJSONData:(id)data {
    WebResponse *response = [[WebResponse alloc] init];
    if (data) {
        response.responseObject = data;
    }
    return response;
}

+ (instancetype)responseWithError:(NSError *)error {
    WebResponse *response = [[WebResponse alloc] init];
    if (error.code == 3840) {
        response.message = @"请求失败，稍后再试";
    } else if (error.code == -1009) {
        response.message = @"当前网络不可用";
    } else if (error.code == -1001) {
        response.message = @"请求超时，稍后再试";
    } else {
        response.message = @"请求失败，稍后再试";
    }
    response.code = WebResponseCodeFailed;
    return response;
}

- (void)JSONDataError {
    self.code = WebResponseCodeFailed;
    self.message = @"数据返回有误";
}

+ (instancetype)respnseWithResult:(NSDictionary *)dict {
    if ([dict isKindOfClass:[NSData class]]) {
        dict = [NSJSONSerialization JSONObjectWithData:dict options:NSJSONReadingMutableContainers error:NULL];
    }
    WebResponse *resoponse = [[WebResponse alloc] init];
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        NSArray *array = dict.allKeys;
        resoponse.message = StringForKeyInUnserializedJSONDic(dict, @"msg");
        resoponse.responseObject = dict;
        if ([array containsObject:@"code"]) {
            if (IntForKeyInUnserializedJSONDic(dict, @"code") == 101) {// || IntForKeyInUnserializedJSONDic(dict, @"code") == 101
                resoponse.code = WebResponseCodeSuccess;
            } else {
                resoponse.code = IntForKeyInUnserializedJSONDic(dict, @"code");
            }
        } else {
            if ([array containsObject:@"status"]) {
                if (IntForKeyInUnserializedJSONDic(dict, @"status")==101) {
                    resoponse.code = WebResponseCodeSuccess;
                } else {
                    resoponse.code = WebResponseCodeFailed;
                }
            } else {
                resoponse.code = WebResponseCodeSuccess;
            }
        }
    } else {
        [resoponse JSONDataError];
    }
    return resoponse;
}

@end
