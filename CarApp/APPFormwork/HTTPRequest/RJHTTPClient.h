//
//  RJHTTPClient.h

#import <AFNetworking/AFHTTPSessionManager.h>
#import "HTTPWebAPIUrl.h"
#import "WebResponse.h"

#define kRJHTTPClient  [RJHTTPClient sharedInstance]

typedef void(^HTTPCompletion)(WebResponse *response);

@interface RJHTTPClient : AFHTTPSessionManager
+ (instancetype)sharedInstance;
- (NSURLSessionDataTask *)getPath:(NSString *)path paramters:(NSDictionary *)paramters completion:(HTTPCompletion)completion;
- (NSURLSessionDataTask *)postPath:(NSString *)path paramters:(NSDictionary *)paramters completion:(HTTPCompletion)completion;
- (NSURLSessionDataTask *)postPath:(NSString *)path paramters:(NSDictionary *)paramters uploadPicture:(UIImage *)picture name:(NSString *)name completion:(HTTPCompletion)completion;
- (NSURLSessionDataTask *)postPath:(NSString *)path paramters:(NSDictionary *)paramters uploadPictures:(NSArray *)pictures name:(NSString *)name completion:(HTTPCompletion)completion;

- (NSURLSessionDataTask *)postPath:(NSString *)path paramters:(NSDictionary *)paramters uploadPictures:(NSArray<NSDictionary *> *)pictures completion:(HTTPCompletion)completion;
- (NSString *)convertToJsonData:(NSDictionary *)dict;
@end
