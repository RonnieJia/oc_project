
#import <Foundation/Foundation.h>

@interface RJNetworkManager : NSObject
+ (instancetype)sharedInstace;
@property (nonatomic, assign, getter=isConnectNetwork) BOOL connectNetWork;

@property(nonatomic, copy)void(^downloadNetChanged)(BOOL canDownload);
@end
