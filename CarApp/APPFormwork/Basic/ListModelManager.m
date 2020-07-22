//
#import "ListModelManager.h"

@implementation ListModelManager
- (instancetype)init {
    self = [super init];
    if (self) {
        self.page = kPageStartIndex;
    }
    return self;
}
- (NSMutableArray *)listArray {
    if (!_listArray) {
        _listArray = [NSMutableArray array];
    }
    return _listArray;
}
@end
