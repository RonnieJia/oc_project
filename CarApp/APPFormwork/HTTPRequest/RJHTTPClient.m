

#import "RJHTTPClient.h"
#import "UIImage+Size.h"


@implementation RJHTTPClient
+ (instancetype)sharedInstance {
    static RJHTTPClient *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    });
    return _sharedInstance;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        [self.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil]];
    }
    return self;
}
/*
NSError * error;
NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
NSString *dataStr = [[NSString alloc] initWithData:responseObject encoding:enc];

NSData * data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];//这样解决的乱码问题。

NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error ];
 */
- (NSURLSessionDataTask *)getPath:(NSString *)path paramters:(NSDictionary *)paramters completion:(HTTPCompletion)completion {
    self.requestSerializer.timeoutInterval = 30.0f;
    return [self GET:path parameters:paramters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        RJLog(@"\n **************************** \n PATH:[%@]\n PARAMTERS:%@\n RESULT:%@ \n END",path,paramters,responseObject);
        if (completion) {
            completion([WebResponse respnseWithResult:responseObject]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RJLog(@"\n **************************** \n PATH:[%@]\n PARAMTERS:%@\n ERROR:code-%zd \n %@ \n END",path,paramters,error.code, error.userInfo[@"NSDebugDescription"]);
        if (completion) {
            completion([WebResponse responseWithError:error]);
        }
    }];
}

- (NSURLSessionDataTask *)postPath:(NSString *)path paramters:(NSDictionary *)paramters completion:(HTTPCompletion)completion {
    self.requestSerializer.timeoutInterval = 30.0f;
    return [self POST:path parameters:paramters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        RJLog(@"\n **************************** \n PATH:[%@]\n PARAMTERS:%@\n RESULT:%@ \n END",path,paramters,responseObject);
        if (completion) {
            WebResponse *response = [WebResponse respnseWithResult:responseObject];
            completion(response);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RJLog(@"\n **************************** \n PATH:[%@]\n PARAMTERS:%@\n ERROR:code-%zd \n %@ \n END",path,paramters,error.code, error.userInfo);
        if (completion) {
            completion([WebResponse responseWithError:error]);
        }
    }];
}

- (NSURLSessionDataTask *)postPath:(NSString *)path paramters:(NSDictionary *)paramters uploadPicture:(UIImage *)picture name:(NSString *)name completion:(HTTPCompletion)completion {
    return [self postPath:path paramters:paramters uploadPictures:picture?@[picture]:nil name:name completion:completion];
}

- (NSURLSessionDataTask *)postPath:(NSString *)path paramters:(NSDictionary *)paramters uploadPictures:(NSArray *)pictures name:(NSString *)name completion:(HTTPCompletion)completion {
    self.requestSerializer.timeoutInterval = 30.0f;
    self.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/html",@"text/json", @"text/javascript", @"text/plain", nil];
    return [self POST:path parameters:paramters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (pictures) {
            NSInteger index = 0;
            for (UIImage *img in pictures) {
                if (!img || ![img isKindOfClass:[UIImage class]]) {
                    continue;
                }
                NSData *data = [img compressWithMaxLength:300*1024];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyyMMddHHmmss";
                NSString *fileName = [NSString stringWithFormat:@"%@_%zd.jpg",[formatter stringFromDate:[NSDate date]],index];
                if (data) {
                    [formData appendPartWithFileData:data name:name fileName:fileName mimeType:@"image/jpeg"];
                }
                index++;
            }
                    }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        RJLog(@"%@",responseObject);
        if (completion) {
            completion([WebResponse respnseWithResult:responseObject]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RJLog(@"%@",error);
        if (completion) {
            completion([WebResponse responseWithError:error]);
        }
    }];
}

- (NSURLSessionDataTask *)postPath:(NSString *)path paramters:(NSDictionary *)paramters uploadPictures:(NSArray<NSDictionary *> *)pictures completion:(HTTPCompletion)completion {
    self.requestSerializer.timeoutInterval = 30.0f;
    self.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/html",@"text/json", @"text/javascript", @"text/plain", nil];
    return [self POST:path parameters:paramters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (pictures && [pictures isKindOfClass:[NSArray class]] && pictures.count>0) {
            for (NSDictionary *imgDict in pictures) {
                UIImage *img = [imgDict objectForKey:kUploadImage];
                NSString *name = [imgDict objectForKey:kUploadImageName];
                if (!img || ![img isKindOfClass:[UIImage class]]) {
                    continue;
                }
                if (!name || ![name isKindOfClass:[NSString class]] || name.length==0) {
                    continue;
                }
                NSData *data = [img compressWithMaxLength:3*1024*1024];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyyMMddHHmmss";
                NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[formatter stringFromDate:[NSDate date]]];
                if (data) {
                    [formData appendPartWithFileData:data name:name fileName:fileName mimeType:@"image/jpeg"];
                }
                
            }
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        RJLog(@"%@",responseObject);
        if (completion) {
            completion([WebResponse respnseWithResult:responseObject]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RJLog(@"%@",error);
        if (completion) {
            completion([WebResponse responseWithError:error]);
        }
    }];
}

- (NSString *)convertToJsonData:(NSDictionary *)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

@end
