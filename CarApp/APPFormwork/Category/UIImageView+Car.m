
#import "UIImageView+Car.h"
#import <objc/runtime.h>


@implementation UIImageView (Car)
static char kAssociatedObject;
- (void)setGoods_id:(NSString *)goods_id {
    objc_setAssociatedObject(self, &kAssociatedObject, goods_id, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (id)goods_id {
    return objc_getAssociatedObject(self, &kAssociatedObject);
}
@end
