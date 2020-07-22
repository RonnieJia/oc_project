//
#import "ShopPayViewController.h"
#import "ShopOrderAddressView.h"
#import "CartModel.h"
#import "AddressListViewController.h"
#import "AddressModel.h"
#import "CartPayGoodsListView.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"

@interface ShopPayViewController ()<UITextViewDelegate>
@property(nonatomic, weak)UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet ShopOrderAddressView *addressView;
@property (weak, nonatomic) IBOutlet UIView *goodsListView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goodsContentHeight;
@property (weak, nonatomic) IBOutlet CartPayGoodsListView *goodsContentView;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *sendLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UITextView *remarkTextView;
@property (weak, nonatomic) IBOutlet UIButton *wexinPayBtn;

@end

@implementation ShopPayViewController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"订单详情";
    [self setBackButton];
    self.view.backgroundColor = KTextWhiteColor;
    self.selectBtn = self.wexinPayBtn;
    self.scrollView.hidden=YES;
    [self fetchOrderInfo];
    weakify(self);
    self.addressView.addressListBlock = ^{
        strongify(weakSelf);
        [strongSelf chooseAddress];
    };
    self.goodsContentView.changeNumBlock = ^(NSInteger num) {
        strongify(weakSelf);
        [strongSelf calculateMoney];
    };
    [self.scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(regisTF)]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxPayResult:) name:kWeixinPayRespNotificarion object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aliPaySuccess:) name:kALiPayResultNoti object:nil];
}

- (void)chooseAddress {
    AddressListViewController *addressList=[[AddressListViewController alloc] init];
    addressList.chooseAddress=YES;
    weakify(self);
    addressList.addressBlock = ^(AddressModel * _Nonnull address) {
        if (address && address.aid) {
            weakSelf.addressView.addressModel = address;
        }
    };
    [self.navigationController pushViewController:addressList animated:YES];
}

- (void)regisTF {
    [self.view endEditing:YES];
}

- (void)fetchOrderInfo {
    WaittingMBProgressHUD(self.view, @"");
    if (self.cartBuyArray && self.cartBuyArray.count>0) {
        NSArray *cartIDsArr = [self.cartBuyArray mutableArrayValueForKeyPath:@"cart_id"];
        NSString *cart_id = [cartIDsArr componentsJoinedByString:@","];
        weakify(self);
        [kRJHTTPClient fetchPayOrderInfo:cart_id completion:^(WebResponse *response) {
            if (response.code == WebResponseCodeSuccess) {
                [weakSelf.dataArray removeAllObjects];
                AddressModel *address=[AddressModel modelWithJSONDict:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"address_info")];
                if (address && address.aid) {
                    weakSelf.addressView.addressModel = address;
                }
                [weakSelf.dataArray addObjectsFromArray:[CartModel listWithJSONArray:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"list")]];
                [weakSelf displayOrderInfo];
                FinishMBProgressHUD(weakSelf.view);
            } else {
                FailedMBProgressHUD(weakSelf.view, response.message);
            }
        }];
    } else {
        FailedMBProgressHUD(self.view, @"请选择购买的商品~");
    }
}

- (void)displayOrderInfo {
    if (self.dataArray.count>0) {
        self.scrollView.hidden = NO;
        self.goodsContentHeight.constant = self.dataArray.count*80+10;
        self.goodsContentView.dataArray = self.dataArray;
        [self calculateMoney];
    }
    
}
- (void)calculateMoney {
    CGFloat money=0,shiping=0;
    for (CartModel *m in self.dataArray) {
        money += ([m.sale_price floatValue] * m.num);
        shiping += [m.shipping_fee floatValue];
    }
    self.moneyLabel.text = [NSString stringWithFormat:@"￥%.2f",money];
    self.sendLabel.text = [NSString stringWithFormat:@"￥%.2f",shiping];
    self.totalLabel.text = [NSString stringWithFormat:@"合计：￥%.2f",(money+shiping)];
}

- (IBAction)payTypeButtonClick:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    self.selectBtn.selected=NO;
    sender.selected=YES;
    self.selectBtn = sender;
}
- (IBAction)payButtonClick:(id)sender {
    [self.view endEditing:YES];
    if (!self.addressView.addressModel) {
        ShowAutoHideMBProgressHUD(self.view, @"请选择收货地址");
        return;
    }
    WaittingMBProgressHUD(self.view, @"");
    NSArray *cartIDsArr = [self.cartBuyArray mutableArrayValueForKeyPath:@"cart_id"];
    NSString *cart_id = [cartIDsArr componentsJoinedByString:@","];
    weakify(self);
    [kRJHTTPClient payCartOrder:cart_id paytype:self.selectBtn.tag address:self.addressView.addressModel.aid message:self.remarkTextView.text completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            NSDictionary *result = ObjForKeyInUnserializedJSONDic(response.responseObject, @"result");
            if (weakSelf.selectBtn.tag==1) {
                [weakSelf payWithAli:StringForKeyInUnserializedJSONDic(result, @"alipay_pay")];
            } else {
                [weakSelf weChatPayOrder:ObjForKeyInUnserializedJSONDic(result, @"weixin_pay")];
            }
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)weChatPayOrder:(NSDictionary *)dict {
/**
     微信支付
     @param dict 订单信息
     */
    if (IsStringEmptyOrNull(StringForKeyInUnserializedJSONDic(dict, @"prepayid"))) {
        ShowAutoHideMBProgressHUD(KKeyWindow, @"订单有误，稍后再试");
        return;
    }
    PayReq *rect = [[PayReq alloc] init];
    NSString *time = StringForKeyInUnserializedJSONDic(dict, @"timestamp");
    rect.openID = StringForKeyInUnserializedJSONDic(dict, @"appid");
    rect.partnerId = StringForKeyInUnserializedJSONDic(dict, @"partnerid");
    rect.prepayId = StringForKeyInUnserializedJSONDic(dict, @"prepayid");
    rect.package = StringForKeyInUnserializedJSONDic(dict, @"package");
    rect.nonceStr = StringForKeyInUnserializedJSONDic(dict, @"noncestr");
    rect.timeStamp = time.intValue;
    rect.sign = StringForKeyInUnserializedJSONDic(dict, @"sign");

    BOOL isRegistWx = [WXApi registerApp:kWeiXinAppKey withDescription:kWeiXinAppDescription];
    if (isRegistWx) {
        if ([WXApi isWXAppInstalled]) {
            BOOL success = [WXApi sendReq:rect];
            if (!success) {
                ShowAutoHideMBProgressHUD(KKeyWindow, @"支付失败，请稍后再试");
            }
        } else {
            ShowAutoHideMBProgressHUD(KKeyWindow, @"请安装微信客户端");
        }
    } else {
        ShowAutoHideMBProgressHUD(KKeyWindow, @"充值失败，请稍后再试");
    }
}

- (void)wxPayResult:(NSNotification *)noti {
    BaseResp *resp = noti.object;
    if (resp.errCode == WXSuccess) {
        ShowAutoHideMBProgressHUD(self.view, @"支付成功");
        [self paySuccess];
    } else {
        ShowAutoHideMBProgressHUD(self.view, resp.errStr);
    }
}

- (void)payWithAli:(NSString *)order {
    weakify(self);
    if (!order) {
        return;
    }
    [[AlipaySDK defaultService] payOrder:order fromScheme:kAliScheme callback:^(NSDictionary *resultDic) {
        strongify(weakSelf);
        NSInteger state = IntForKeyInUnserializedJSONDic(resultDic, @"resultStatus");
        if (state == 9000) {
            ShowAutoHideMBProgressHUD(strongSelf.view, @"支付成功");
            [self paySuccess];
        } else {
            ShowAutoHideMBProgressHUD(self.view, StringForKeyInUnserializedJSONDic(resultDic, @"memo"));
        }
    }];
}

- (void)aliPaySuccess:(NSNotification *)noti {
    NSDictionary *resultDic = noti.object;
    NSInteger state = IntForKeyInUnserializedJSONDic(resultDic, @"resultStatus");
    if (state == 9000) {
        ShowAutoHideMBProgressHUD(self.view, @"支付成功");
        [self paySuccess];
    } else {
        ShowAutoHideMBProgressHUD(self.view, StringForKeyInUnserializedJSONDic(resultDic, @"memo"));
    }
}

- (void)paySuccess {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    });
    
}
#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView {
    self.placeLabel.hidden = textView.text.length>0;
}
#pragma mark - 键盘弹出及收起
- (void)keyboardWasShown:(NSNotification *)noti {
    CGFloat height = FetchKeyBoardHeight(noti);
    self.bottomConstraint.constant = height-kIPhoneXBH;
    if (self.remarkTextView.isFirstResponder) {
        [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height-(KViewNavHeight-60-height)+5) animated:NO];
    }
}
- (void)keyboardWillBeHidden:(NSNotification *)noti {
    self.bottomConstraint.constant = 0;
}

@end
