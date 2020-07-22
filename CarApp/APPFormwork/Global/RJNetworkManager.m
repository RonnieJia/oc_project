
#import "RJNetworkManager.h"
#import <AFNetworking/AFNetworking.h>

@interface RJNetworkManager()
@property(nonatomic, strong)AFNetworkReachabilityManager *manager;
@end

@implementation RJNetworkManager
+ (instancetype)sharedInstace{
    static RJNetworkManager *m = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        m = [[RJNetworkManager alloc] init];
    });
    return m;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.manager = [AFNetworkReachabilityManager manager];
        weakify(self);
        [self.manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            strongify(weakSelf);
            BOOL download = NO;
            switch (status) {
                case AFNetworkReachabilityStatusNotReachable: {
                    strongSelf.connectNetWork = NO;
                    download = NO;
                    break;
                }
                case AFNetworkReachabilityStatusReachableViaWiFi:{
                    download = YES;
                    strongSelf.connectNetWork= YES;
                }
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:{
                    strongSelf.connectNetWork= YES;
                    download = NO;
                }
                    break;
                    
                default:
                    strongSelf.connectNetWork= YES;
                    break;
            }
            if (strongSelf.downloadNetChanged) {
                strongSelf.downloadNetChanged(download);
            }
        }];
        [self.manager startMonitoring];
    }
    return self;
}
@end
