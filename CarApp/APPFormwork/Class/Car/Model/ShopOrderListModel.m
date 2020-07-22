

#import "ShopOrderListModel.h"

@implementation ShopOrderListModel
- (instancetype)init {
    self = [super init];
    if (self) {
        self.page = kPageStartIndex;
    }
    return self;
}

- (NSMutableArray *)shopOrderArray {
    if (!_shopOrderArray) {
        _shopOrderArray = [NSMutableArray array];
    }
    return _shopOrderArray;
}
@end

@implementation ShopOrderModel

@end
