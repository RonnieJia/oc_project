//

#import "CartPayModel.h"
#import "CartModel.h"

@implementation CartPayModel
- (void)setCartGoodsArr:(NSArray *)cartGoodsArr {
    _cartGoodsArr = cartGoodsArr;
    if (cartGoodsArr && cartGoodsArr.count>0) {
        CGFloat moneyTotal = 0;
        CGFloat yun = 0;
        for (CartModel *m in cartGoodsArr) {
            moneyTotal += ([m.sale_price floatValue] * m.num);
            yun += ([m.shipping_fee floatValue]);
        }
        self.money = moneyTotal;
        self.shinMoney = yun;
    }
}
@end
