

#import "RJUUID.h"
#import "KeyChainStore.h"

@implementation RJUUID
+ (NSString *)getUUID {
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSString *strUUID = (NSString *)[KeyChainStore load:bundleId];
    if (IsStringEmptyOrNull(strUUID)) {
        CFUUIDRef uuidref = CFUUIDCreate(kCFAllocatorDefault);
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidref));
        [KeyChainStore save:bundleId data:strUUID];
    }
    return strUUID;
}
@end
