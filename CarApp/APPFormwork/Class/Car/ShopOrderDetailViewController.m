#import "ShopOrderDetailViewController.h"
#import "ShopOrderInfoItem.h"
#import "ShopOrderListModel.h"
#import "AddressModel.h"
#import "RefundReasonViewController.h"
#import "PayTypeView.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Masonry.h"

@interface ShopOrderDetailViewController ()
@property(nonatomic, assign)ShopOrderState detailState;
@end

@implementation ShopOrderDetailViewController
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"订单详情";
    self.returnBtn.layer.cornerRadius = 16;
    self.returnBtn.layer.borderColor = KSepLineColor.CGColor;
    self.returnBtn.layer.borderWidth = 1;
    [self fetchOrderDetail];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxPayResult:) name:kWeixinPayRespNotificarion object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aliPaySuccess:) name:kALiPayResultNoti object:nil];
}

- (void)fetchOrderDetail {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient fetchShopOrderDetail:self.orderModel.order_id completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [weakSelf displayOrderInfo:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"info")];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)displayOrderInfo:(NSDictionary *)dic {
    NSInteger refund_status = IntForKeyInUnserializedJSONDic(dic, @"refund_status");// 1\2退款
    NSInteger pay_status = IntForKeyInUnserializedJSONDic(dic, @"order_status");// 1-已支付
    NSInteger shipping_status = IntForKeyInUnserializedJSONDic(dic, @"shipping_status");
    if (refund_status == 1 || refund_status == 2) {
        self.detailState = ShopOrderStateReturn;
    } else {
        if (pay_status==0) {
            self.detailState = ShopOrderStateWait;
        } else {
            self.detailState = shipping_status+2;
        }
    }
    
    [self showAddress:dic];
    [self showGoodsInfo:dic];
    [self showOrderMoney:dic];
    [self showOrderDetail:dic];
    [self showRemarkInfo:dic];
    [self showOtherInfo:dic];
    [self showReturnInfo:dic];
    [self bottomViewShow:dic];
    
    self.scrollView.hidden = NO;
}

- (void)showAddress:(NSDictionary *)dic {
    AddressModel *address = [AddressModel new];
    address.consigner = StringForKeyInUnserializedJSONDic(dic, @"receiver_name");
    address.mobile = StringForKeyInUnserializedJSONDic(dic, @"receiver_mobile");
    address.address=StringForKeyInUnserializedJSONDic(dic, @"receiver_address");
    self.addressView.addressModel = address;
}

- (void)showGoodsInfo:(NSDictionary *)dic {
    [self.goodsIcon rj_setImageWithPath:StringForKeyInUnserializedJSONDic(dic, @"goods_picture") placeholderImage:KDefaultImg];
    self.goodsNameL.text = StringForKeyInUnserializedJSONDic(dic, @"goods_name");
    self.goodsSkuL.text = StringForKeyInUnserializedJSONDic(dic, @"sku_name");
    self.goodsNumL.text = [NSString stringWithFormat:@"x%zd",IntForKeyInUnserializedJSONDic(dic, @"num")];
    self.goodsPriceL.text = [NSString stringWithFormat:@"￥%@",StringForKeyInUnserializedJSONDic(dic, @"price")];
}
- (void)showOrderMoney:(NSDictionary *)dic {
    self.orderModel.total_price=StringForKeyInUnserializedJSONDic(dic, @"total_price");
    CGFloat total = FloatForKeyInUnserializedJSONDic(dic, @"total_price");
    CGFloat shipping = FloatForKeyInUnserializedJSONDic(dic, @"shipping_money");
    self.goodsMoneyLabel.text = [NSString stringWithFormat:@"￥%.2f",total-shipping];
    self.sendMoneyLabel.text = [NSString stringWithFormat:@"￥%.2f",shipping];
    NSString *payMon = [NSString stringWithFormat:@"合计：￥%.2f",total];
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:payMon];
    [att addAttribute:NSForegroundColorAttributeName value:KTextDarkColor range:NSMakeRange(0, 3)];
    [att addAttribute:NSFontAttributeName value:kFontWithSmallSize range:NSMakeRange(0, 3)];
    self.payMoneyLabel.attributedText=att;
}
/// 订单明细
- (void)showOrderDetail:(NSDictionary *)dic {
    NSArray *arr = [ShopOrderDataManager orderInfoList:dic orderState:self.detailState];
    CGFloat top = 0;
    for (int i = 0; i<arr.count; i++) {
        ShopOrderInfoItem *item = [[ShopOrderInfoItem alloc] init];
        item.top = top;
        item.info = arr[i];
        [self.orderInfoContentView addSubview:item];
        top = item.bottom;
    }
    self.orderContentHeight.constant = top;
}

- (void)showRemarkInfo:(NSDictionary *)dic {
    if (self.detailState==ShopOrderStateWait) {
        self.remarkView.hidden=YES;
    } else {
        NSString *remark = StringForKeyInUnserializedJSONDic(dic, @"buyer_message");
        if (IsStringEmptyOrNull(remark)) {
            self.remarkLabel.text = @"买家未留言";
            self.remarkLabel.textColor = KTextGrayColor;
        } else {
            self.remarkLabel.textColor = KTextDarkColor;
            self.remarkLabel.text = remark;
        }
    }
}

- (void)showOtherInfo:(NSDictionary *)dic {
    if (self.detailState == ShopOrderStateFinished || self.detailState == ShopOrderStateDispatchin) {
        NSString *eNum = StringForKeyInUnserializedJSONDic(dic, @"express_number");
        NSString *eCom = StringForKeyInUnserializedJSONDic(dic, @"express_name");
        NSArray *arr = @[@{@"title":@"快递单号",@"info":eNum},
        @{@"title":@"快递公司",@"info":eCom}];
        CGFloat top = 0;
        for (int i = 0; i<arr.count; i++) {
            ShopOrderInfoItem *item = [[ShopOrderInfoItem alloc] init];
            item.top = top;
            item.info = arr[i];
            [self.otherContentView addSubview:item];
            top = item.bottom;
        }
        self.otherContentHeight.constant = top+10;
    } else {
        self.otherInfoView.hidden=YES;
    }
}
- (void)showReturnInfo:(NSDictionary *)dic {
    if (self.detailState==ShopOrderStateWait) {
        self.returnView.hidden=YES;
        return;
    }
    NSInteger returnStatus = IntForKeyInUnserializedJSONDic(dic, @"refund_status");
    if (returnStatus>0) {
        NSArray *arr = [ShopOrderDataManager orderReturnInfoList:dic orderState:self.detailState];
        self.returnView.hidden=NO;
        CGFloat top = 0;
        for (int i = 0; i<arr.count; i++) {
            ShopOrderInfoItem *item = [[ShopOrderInfoItem alloc] init];
            item.top = top;
            item.info = arr[i];
            [self.returnContentView addSubview:item];
            top = item.bottom;
        }
        self.returnContentHeight.constant = top+10;
        if (self.detailState == ShopOrderStateFinished || self.detailState == ShopOrderStateDispatchin) {
            
        } else {
            [self.returnView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.remarkView.mas_bottom).offset(5);
            }];
        }
    } else {
        self.returnView.hidden = YES;
    }
    
}

- (void)bottomViewShow:(NSDictionary *)dic {
    self.bottomView.hidden=NO;
    ShopOrderState orderStatus;
    NSInteger payStates = IntForKeyInUnserializedJSONDic(dic, @"order_status");//0-未支付 1-已支付
    NSInteger shippingState = IntForKeyInUnserializedJSONDic(dic, @"shipping_status");
    NSInteger returnState = IntForKeyInUnserializedJSONDic(dic, @"refund_status");
    if (returnState==1 || returnState==2) {
        orderStatus = ShopOrderStateReturn;
        self.bottomView.hidden = YES;
        self.bottomViewHeight.constant = 0;
    } else {
        if (payStates==0 && shippingState<=0) {
            orderStatus = ShopOrderStateWait;
            self.returnBtn.hidden = YES;
        } else {
            orderStatus = shippingState+2;
            if (orderStatus == ShopOrderStatePayed || orderStatus == ShopOrderStateFinished) {
                self.sureButton.hidden = YES;
                self.returnTrailing.constant = 10;
            } else if (orderStatus == ShopOrderStateDispatchin) {
                [self.sureButton setTitle:@"确认收货" forState:UIControlStateNormal];
            }
            if (returnState==3) {
                [self.returnBtn setTitle:@"拒绝退款" forState:UIControlStateNormal];
            }
        }
    }
}
- (IBAction)refundButtonClick:(id)sender {
    UIButton *btn = sender;
    if ([btn.currentTitle isEqualToString:@"申请退款"]) {
        RefundReasonViewController *refund = [RefundReasonViewController new];
        refund.order_id = self.orderModel.order_id;
        weakify(self);
        refund.refuseMoneySuccess = ^{// 退款成功
            [weakSelf fetchOrderDetail];
            if (weakSelf.orderRefuseComplete) {
                weakSelf.orderRefuseComplete();
            }
        };
        [self.navigationController pushViewController:refund animated:YES];
    }
}
- (IBAction)sureButtonClick:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"确认收货"]) {
        WaittingMBProgressHUD(self.view, @"");
        weakify(self);
        [kRJHTTPClient orderReceived:self.orderModel.order_id completion:^(WebResponse *response) {
            if (response.code == WebResponseCodeSuccess) {
                if (self.orderReceiveComplete) {
                    self.orderReceiveComplete();
                }
                [self fetchOrderDetail];// 刷新
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
        }];
    } else if ([sender.currentTitle isEqualToString:@"去付款"]) {
        PayTypeView *pay = [[PayTypeView alloc] init];
        weakify(self);
        [pay showWithTypeBlock:^(NSInteger type) {
            [weakSelf payOrderWithType:type];
        }];
    }
}



- (void)payOrderWithType:(NSInteger)type {
    [self.view endEditing:YES];
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient payOrderAgain:self.orderModel.order_id money:self.orderModel.total_price type:type completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            NSDictionary *result = ObjForKeyInUnserializedJSONDic(response.responseObject, @"result");
            if (type==1) {
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
            } else {
                
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
    NSDictionary *resultDict = noti.object;
    NSInteger status = IntForKeyInUnserializedJSONDic(resultDict, @"resultStatus");
    if (status == 9000) {
        ShowAutoHideMBProgressHUD(self.view, @"支付成功");
        [self paySuccess];
    } else {
        ShowAutoHideMBProgressHUD(self.view, StringForKeyInUnserializedJSONDic(resultDict, @"memo"));
    }
}

- (void)paySuccess {
    if (self.orderPaySuccess) {
        self.orderPaySuccess();
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}
@end
