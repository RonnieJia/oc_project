//

#import "ShopCartDataManager.h"
#import "CartModel.h"

@interface ShopCartDataManager ()
@property(nonatomic, strong)NSString *elements;
@property(nonatomic, strong)NSString *userId;
@end

@implementation ShopCartDataManager

static ShopCartDataManager *manger = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manger = [[ShopCartDataManager alloc] init];
    });
    return manger;
}

+ (void)destroyInstance {// 销毁单例
    manger = nil;
}

- (NSArray<CartModel *> *)fetchCartList:(NSArray *)arr {
    NSMutableArray *tmp = [NSMutableArray array];
    self.money = 0;
    for (int i = 0; i<arr.count; i++) {
        CartModel *model = [CartModel modelWithJSONDict:[arr objectAtIndex:i]];
        if (!model) {
            continue;
        }
        if (model.cart_id && [self.chooseCartArray containsObject:model.cart_id]) {
            model.choose = YES;
            self.money += ([model.price floatValue] * model.num);
        }
        [tmp addObject:model];
    }
    return tmp;
}

- (void)cart:(NSString *)cart_id remove:(BOOL)remove {
    if (IsStringEmptyOrNull(cart_id)) {
        return;
    }
    @synchronized (self.elements) {
        if (remove) {
            [self.chooseCartArray removeObject:cart_id];
        } else {
            if (![self.chooseCartArray containsObject:cart_id]) {
                [self.chooseCartArray addObject:cart_id];
            }
        }
    }
    [self saveCart];
}

- (void)saveCart {
    if (self.chooseCartArray.count==0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"cart_id_%@",[CurrentUserInfo sharedInstance].userId]];
    } else {
        NSString *str = [self.chooseCartArray componentsJoinedByString:@","];
        [[NSUserDefaults standardUserDefaults] setObject:str forKey:[NSString stringWithFormat:@"cart_id_%@",[CurrentUserInfo sharedInstance].userId]];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSMutableArray *)chooseCartArray {
    if (!_chooseCartArray) {
        _chooseCartArray = [NSMutableArray array];
    }
    return _chooseCartArray;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.elements = @"justFlag";
        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"cart_id_%@",[CurrentUserInfo sharedInstance].userId]];
        NSArray *arr = [str componentsSeparatedByString:@","];
        if (arr && arr.count>0) {
            [self.chooseCartArray addObjectsFromArray:arr];
        }
    }
    return self;
}
@end
