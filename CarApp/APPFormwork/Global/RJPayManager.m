
#import "RJPayManager.h"

@implementation RJPayManager
+ (instancetype)sharedInstance {
    static RJPayManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[RJPayManager alloc] init];
    });
    return _manager;
}
@end
