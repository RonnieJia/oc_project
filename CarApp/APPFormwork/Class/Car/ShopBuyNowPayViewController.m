//
#import "ShopBuyNowPayViewController.h"
#import "ShopOrderAddressView.h"
#import "AddressListViewController.h"
#import "AddressModel.h"
#import "CartPayGoodsListView.h"
#import "ShopGoodsModel.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"

@interface ShopBuyNowPayViewController ()<UITextViewDelegate>
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

@implementation ShopBuyNowPayViewController
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
    if (![CurrentUserInfo sharedInstance].addressModel) {
        [self fetchUserAddress];
    } else {
        self.addressView.addressModel = [CurrentUserInfo sharedInstance].addressModel;
    }
    weakify(self);
    self.addressView.addressListBlock = ^{
        strongify(weakSelf);
        AddressListViewController *address = [[AddressListViewController alloc] init];
        address.chooseAddress = YES;
        address.addressBlock = ^(AddressModel * _Nonnull address) {
            strongSelf.addressView.addressModel = address;
        };
        [strongSelf.navigationController pushViewController:address animated:YES];
    };
    self.goodsContentView.changeNumBlock = ^(NSInteger num) {
        strongify(weakSelf);
        strongSelf.num = num;
        [strongSelf calculateMoney];
    };
    [self.scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(regisTF)]];
    [self displayOrderInfo];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxPayResult:) name:kWeixinPayRespNotificarion object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aliPaySuccess:) name:kALiPayResultNoti object:nil];
}

- (void)regisTF {
    [self.view endEditing:YES];
}

- (void)fetchUserAddress {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient fetchAddressListCompletion:^(WebResponse *response) {
        if (response.code==WebResponseCodeSuccess) {
            NSArray *tmp = [AddressModel listWithJSONArray:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"list")];
            if (tmp && tmp.count>0) {
                for (AddressModel *m in tmp) {
                    if (m.is_default) {
                        [CurrentUserInfo sharedInstance].addressModel = m;
                        strongify(weakSelf);
                        strongSelf.addressView.addressModel = [CurrentUserInfo sharedInstance].addressModel;
                        break;
                    }
                }
                
            }
        }
        FinishMBProgressHUD(weakSelf.view);
    }];
}

- (void)displayOrderInfo {
    self.scrollView.hidden = NO;
    self.goodsContentHeight.constant = 90;
    [self.goodsContentView buy:self.goodsModel sku:self.sku num:self.num];
    [self calculateMoney];
}

- (void)calculateMoney {
    CGFloat money=0,shiping=0;
    money = [self.sku.sale_price floatValue] * self.num;
    shiping = [self.goodsModel.shipping_fee floatValue];
    self.moneyLabel.text = [NSString stringWithFormat:@"￥%.2f",money];
    self.sendLabel.text = [NSString stringWithFormat:@"￥%.2f",shiping];
    self.totalLabel.text = [NSString stringWithFormat:@"合计：￥%.2f",(money+shiping)];
}
- (IBAction)payButtonClick:(id)sender {
    [self.view endEditing:YES];
    if (!self.addressView.addressModel) {
        ShowAutoHideMBProgressHUD(self.view, @"请选择收货地址");
        return;
    }
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient payBuyNowOrder:self.goodsModel.goods_id sku:self.sku.sku_id num:self.num paytype:self.selectBtn.tag address:self.addressView.addressModel.aid message:self.remarkTextView.text completion:^(WebResponse *response) {
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
                [self payCompletion];
            }
        } else {
            ShowAutoHideMBProgressHUD(KKeyWindow, @"支付失败，请稍后再试");
            [self payCompletion];
        }
    } else {
        ShowAutoHideMBProgressHUD(KKeyWindow, @"支付失败，请稍后再试");
        [self payCompletion];
        
    }
}

- (void)wxPayResult:(NSNotification *)noti {
    BaseResp *resp = noti.object;
    if (resp.errCode == WXSuccess) {
        ShowAutoHideMBProgressHUD(self.view, @"支付成功");
        [self payCompletion];
    } else {
        if (resp.errCode==-2) {
            ShowAutoHideMBProgressHUD(self.view, @"取消支付");
        } else {
            if (IsStringEmptyOrNull(resp.errStr)) {
                ShowAutoHideMBProgressHUD(self.view, @"支付失败");
            } else {
                ShowAutoHideMBProgressHUD(self.view, resp.errStr);
            }
        }
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
            [self payCompletion];
        } else {
            NSString *memo = StringForKeyInUnserializedJSONDic(resultDic, @"memo");
            if (IsStringEmptyOrNull(memo)) {
                memo = @"支付失败";
            }
            ShowAutoHideMBProgressHUD(self.view, memo);
        }
    }];
}

- (void)aliPaySuccess:(NSNotification *)noti {
    NSDictionary *resultDic = noti.object;
    NSInteger state = IntForKeyInUnserializedJSONDic(resultDic, @"resultStatus");
    if (state == 9000) {
        ShowAutoHideMBProgressHUD(self.view, @"支付成功");
        [self payCompletion];
    } else {
        ShowAutoHideMBProgressHUD(self.view, StringForKeyInUnserializedJSONDic(resultDic, @"memo"));
    }
}

- (void)payCompletion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
    
}

- (IBAction)payTypeButtonClick:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    self.selectBtn.selected=NO;
    sender.selected=YES;
    self.selectBtn = sender;
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
