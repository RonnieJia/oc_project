//

#import "CartModel.h"
#import "ShopCartDataManager.h"

@implementation CartModel
- (void)setChoose:(BOOL)choose {
    _choose = choose;
    [[ShopCartDataManager sharedInstance] cart:self.cart_id remove:!choose];
}
@end
