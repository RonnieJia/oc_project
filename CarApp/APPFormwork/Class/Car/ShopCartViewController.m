//
#import "ShopCartViewController.h"
#import "ShopCartHeaderView.h"
#import "ShopCartCell.h"
#import "ShopPayViewController.h"
#import "CartModel.h"
#import "ShopCartDataManager.h"

@interface ShopCartViewController ()
@property(nonatomic, strong)ShopCartHeaderView *shopCartHeader;
@property(nonatomic, strong)UIView *bottomView;
@property(nonatomic, weak)UILabel *moneyLabel;
@property(nonatomic, strong)NSLock *lock;
@end

@implementation ShopCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"购物车";
    _lock = [[NSLock alloc] init];
    [self setBackButton];
    [self createMainView];
    [self fetchCart];
    weakify(self);
    [self setNavBarBtnWithType:NavBarTypeRight title:@"删除" action:^{
        if (weakSelf.dataArray.count>0) {
            NSArray *choose = [weakSelf.dataArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"choose==1"]];
            if (!choose || choose.count==0) {
                ShowAutoHideMBProgressHUD(weakSelf.view, @"请选择要删除的商品");
                return;
            }
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定删除已选中商品？" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf deleteCartGoods];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [weakSelf presentViewController:alert animated:YES completion:nil];
        } else {
            ShowAutoHideMBProgressHUD(weakSelf.view, @"亲，您的购物车还未添加商品");
        }
    }];
}

- (void)deleteCartGoods {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    NSArray *choose = [self.dataArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"choose==1"]];
    NSArray *cartIDsArr = [choose mutableArrayValueForKeyPath:@"cart_id"];
    NSString *cart_id = [cartIDsArr componentsJoinedByString:@","];
    [kRJHTTPClient deleteCartGoods:cart_id completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [weakSelf.dataArray removeObjectsInArray:choose];
            [weakSelf.tableView reloadData];
            if (weakSelf.shopCartHeader.allChoose) {
                weakSelf.shopCartHeader.allChoose = NO;
            }
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [weakSelf fetchCart];
//            });
        }
        FailedMBProgressHUD(weakSelf.view, response.message);
        
    }];
}

- (void)fetchCart {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient fetchCartCompletion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [weakSelf.dataArray removeAllObjects];
            [weakSelf.dataArray addObjectsFromArray:[[ShopCartDataManager sharedInstance] fetchCartList:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"list")]];
            weakSelf.moneyLabel.text = [NSString stringWithFormat:@"￥%.2f",[ShopCartDataManager sharedInstance].money];
            if (weakSelf.dataArray.count>0) {
                NSArray *chooseArr = [weakSelf.dataArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"choose == 0"]];
                weakSelf.shopCartHeader.allChoose = (chooseArr.count==0);
            }
            [weakSelf.tableView reloadData];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)chooseAllCartGoods:(BOOL)choose {
    NSArray *arr = [NSArray arrayWithArray:self.dataArray];
    for (CartModel *cart in arr) {// 数组中元素还是相同的
        cart.choose = choose;
    }
    if (choose) {
        [self calculateMoney];
    } else {
        self.moneyLabel.text = @"￥0";
    }
    [self.tableView reloadData];
}

- (void)calculateMoney{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.lock lock];
        CGFloat money = 0;
        NSArray *chooseArr = [[NSArray arrayWithArray:self.dataArray] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"choose == 1"]];
        for (int i = 0; i<chooseArr.count; i++) {
            CartModel *m = chooseArr[i];
            money += ([m.price floatValue] * m.num);
        }
        weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.moneyLabel.text = [NSString stringWithFormat:@"￥%.2f",money];
        });
        [self.lock unlock];
    });
}

#pragma mark - tableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShopCartCell *cell = [ShopCartCell cellWithTableView:tableView];
    cell.cartModel = self.dataArray[indexPath.row];
    weakify(self);
    cell.cartNumChangeBlock = ^(BOOL choose) {
        strongify(weakSelf);
        [strongSelf calculateMoney];
    };
    cell.cartItemChooseBlock = ^(BOOL choose) {
        strongify(weakSelf);
        if (choose) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"choose == 0"];
            NSArray *arr = [strongSelf.dataArray filteredArrayUsingPredicate:predicate];
            if (arr && arr.count>0) {
                    strongSelf.shopCartHeader.allChoose = NO;
            } else {
                    strongSelf.shopCartHeader.allChoose = YES;
            }
        } else {
            if (strongSelf.shopCartHeader.allChoose) {// 取消选中某个商品，如果在全选状态的话取消全选
                strongSelf.shopCartHeader.allChoose = NO;
            }
        }
        [strongSelf calculateMoney];
    };
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.shopCartHeader;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 15), [UIColor clearColor]);
    UIView *corinerView = RJCreateSimpleView(CGRectMake(12, 0, KScreenWidth-24, 15), KTextWhiteColor);
    [footer addSubview:corinerView];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:corinerView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(6, 6)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    //设置大小
    maskLayer.frame = corinerView.bounds;
    //设置图形样子
    maskLayer.path = maskPath.CGPath;
    corinerView.layer.mask = maskLayer;
    return footer;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)createMainView {
    self.tableView.height = KViewNavHeight-52-kIPhoneXBH;
    self.tableView.separatorColor = kViewControllerBgColor;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 12, 0, 12);
    self.tableView.rowHeight = 105;
    self.tableView.sectionFooterHeight=15;
    self.tableView.sectionHeaderHeight=self.shopCartHeader.height;
    self.tableView.backgroundColor = kViewControllerBgColor;
    [self.view addSubview:self.tableView];
    self.bottomView.top = self.tableView.bottom;
    [self.view addSubview:self.bottomView];
}

- (ShopCartHeaderView *)shopCartHeader {
    if (!_shopCartHeader) {
        _shopCartHeader = [[ShopCartHeaderView alloc] init];
        weakify(self);
        _shopCartHeader.shopCartAllChooseBlcok = ^(BOOL allChoose) {
            strongify(weakSelf);
            [strongSelf chooseAllCartGoods:allChoose];
        };
    }
    return _shopCartHeader;
}
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, kIPhoneXBH+52), KTextWhiteColor);
        [_bottomView addSubview:RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 1), KSepLineColor)];
        
        UIButton *payBtn = RJCreateButton(CGRectMake(KScreenWidth-120, 5, 110, 42), kFontWithSmallSize, KTextWhiteColor, KThemeColor, nil, nil, @"去结算");
        [_bottomView addSubview:payBtn];
        payBtn.layer.cornerRadius = 10;
        payBtn.clipsToBounds = YES;
        [payBtn addTarget:self action:@selector(pushToPay) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *moneyL = RJCreateLable(CGRectMake(10, payBtn.top, payBtn.left-25, payBtn.height), kFontWithDefaultSize, kTextRedColor, NSTextAlignmentRight, @"￥45.0");
        self.moneyLabel = moneyL;
        [_bottomView addSubview:moneyL];
    }
    return _bottomView;
}
- (void)pushToPay {
    if (self.dataArray.count==0) {
        ShowAutoHideMBProgressHUD(self.view, @"亲，您的购物车还没有添加商品");
        return;
    }
    NSArray *choose = [self.dataArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"choose==1"]];
    if (!choose || choose.count==0) {
        ShowAutoHideMBProgressHUD(self.view, @"请选择商品");
        return;
    }
    ShopPayViewController *pay = [ShopPayViewController new];
    pay.cartBuyArray = choose;
    [self.navigationController pushViewController:pay animated:YES];
}
@end
