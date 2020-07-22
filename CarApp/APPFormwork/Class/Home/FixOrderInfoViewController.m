//

#import "FixOrderInfoViewController.h"
#import "FixModel.h"
#import "NotesOrderUserView.h"
#import "CarInfoViewController.h"
#import "FixEditViewController.h"
#import "RefundReasonViewController.h"
#import "MapLocationViewController.h"
#import "ChatViewController.h"
#import "RepairInfoViewController.h"

@interface FixOrderInfoViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NotesOrderUserView *carInfoView;
@property (weak, nonatomic) IBOutlet UILabel *orderNumLabel;
@property (weak, nonatomic) IBOutlet UIView *moneyView;
@property (weak, nonatomic) IBOutlet UIView *cancelView;
@property (weak, nonatomic) IBOutlet UILabel *partMoneyL;
@property (weak, nonatomic) IBOutlet UILabel *hourMoneyL;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moneyCOntentHeight;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *orderInfoViews;
@property (weak, nonatomic) IBOutlet UILabel *cancelTitleL;
@property (weak, nonatomic) IBOutlet UILabel *cancelContentL;
@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UIView *linkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkLeft;
@property (weak, nonatomic) IBOutlet UIView *positionView;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelRight;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property(nonatomic, strong)NSString *orderStateString;
@end

@implementation FixOrderInfoViewController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"订单详情";
    self.scrollView.hidden=self.bottomView.hidden=YES;
    [self fetchData];
    weakify(self);
    self.carInfoView.pushCarInfoBlock = ^{
        CarInfoViewController *info = [CarInfoViewController new];
        info.car_id = weakSelf.fixModel.vehicle_id;
        [weakSelf.navigationController pushViewController:info animated:YES];
    };
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fixReportSuccess:) name:kFixReportSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fixCancelOrder:) name:kFixOrderCancel object:nil];
    self.cancelBtn.layer.borderWidth=1;
    self.cancelBtn.layer.borderColor = KTextGrayColor.CGColor;
}

- (void)fixCancelOrder:(NSNotification *)noti {// 取消订单
    FixModel *fix = noti.object;
    if (fix && [fix.order_rid isEqualToString:self.fixModel.order_rid]) {
        self.fixModel.fixState = FixStateCancel;
        [self fetchData];
    }
}

- (void)fixCompleted {// 维修完成
    self.fixModel.repair_state=2;
    [self displayInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFixCompleted object:self.fixModel.repair_id];
}

- (void)fixReportSuccess:(NSNotification *)noti {// 报价成功
    NSString *orderid = noti.object;
    if ([self.fixModel.order_rid isEqualToString:orderid]) {
        [self fetchData];
    }
}

- (void)fetchData {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient fetchFixInfo:self.fixModel.order_rid completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [weakSelf.fixModel loadDetail:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"info")];
            [weakSelf displayInfo];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)displayInfo {
    self.scrollView.hidden=self.bottomView.hidden=NO;
    self.carInfoView.nameLabel.text = self.fixModel.v_name;
    self.carInfoView.infoLabel.text = [NSString stringWithFormat:@"车主%@",self.fixModel.o_nickname];
    self.partMoneyL.text = [NSString stringWithFormat:@"￥%@",self.fixModel.parts_price];
    self.hourMoneyL.text = [NSString stringWithFormat:@"￥%@",self.fixModel.hours_price];
    self.orderNumLabel.text = self.fixModel.order_number;
    NSString *moneyStr = [NSString stringWithFormat:@"合计：￥%@",self.fixModel.price];
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:moneyStr];
    [att addAttribute:NSForegroundColorAttributeName value:KTextDarkColor range:NSMakeRange(0, 3)];
    [att addAttribute:NSFontAttributeName value:kFont(13) range:NSMakeRange(0, 3)];
    self.moneyLabel.attributedText = att;
    NSArray *orders = [self orderInfoShows];
    for (int i = 0; i<self.orderInfoViews.count; i++) {
        UIView *view = self.orderInfoViews[i];
        NSLayoutConstraint *heightCon = view.constraints.firstObject;
        if (i<orders.count) {
            UILabel *titleL = [view viewWithTag:0];
            titleL.text = StringForKeyInUnserializedJSONDic(orders[i], @"t");
            UILabel *valueL = [view viewWithTag:1];
            valueL.text = StringForKeyInUnserializedJSONDic(orders[i], @"v");
            heightCon.constant = 30;
        } else {
            heightCon.constant = 0;
            view.hidden=YES;
        }
    }
}
- (IBAction)fixInfoAction:(id)sender {
    RepairInfoViewController *info = [[RepairInfoViewController alloc] init];
    info.state = self.orderStateString;
    info.fixModel = self.fixModel;
    info.isFix = YES;
    [self.navigationController pushViewController:info animated:YES];
}

- (IBAction)bottomSureAction:(id)sender {
    UIButton *btn = sender;
    if ([btn.currentTitle isEqualToString:@"维修完成"]) {
        WaittingMBProgressHUD(self.view, @"");
        weakify(self);
        [kRJHTTPClient fixComplete:self.fixModel.order_rid completion:^(WebResponse *response) {
            if (response.code == WebResponseCodeSuccess) {
                [weakSelf fixCompleted];
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
        }];
    } else if ([btn.currentTitle isEqualToString:@"报价"]) {
        FixEditViewController *edit = [FixEditViewController new];
        edit.fixModel = self.fixModel;
        [self.navigationController pushViewController:edit animated:YES];
    }
}
- (IBAction)bottomCancelAction:(id)sender {
    RefundReasonViewController *cancel = [RefundReasonViewController new];
    cancel.type = 1;
    cancel.cancelType = 0;
    cancel.order_id = self.fixModel.order_rid;
    cancel.obj = self.fixModel;
    [self.navigationController pushViewController:cancel animated:YES];
}
- (IBAction)locationAction:(id)sender {
    MapLocationViewController *map = [[MapLocationViewController alloc] init];
    map.lat = self.fixModel.lat;
    map.lon = self.fixModel.lng;
    map.oName = self.fixModel.o_nickname;
    [self.navigationController pushViewController:map animated:YES];
}
- (IBAction)phoneAction:(id)sender {
    makePhoneCall(self.fixModel.phone);
}
- (IBAction)linkAction:(id)sender {
    NSString *userName = [NSString stringWithFormat:kCarOwnerWord,self.fixModel.owner_id];
    NSString *appKey = kCarOwnerAppKey;
    weakify(self);
    [JMSGConversation createSingleConversationWithUsername:userName appKey:appKey completionHandler:^(id resultObject, NSError *error) {
        if (!error && resultObject && [resultObject isKindOfClass:JMSGConversation.class]) {
            ChatViewController *chat = [[ChatViewController alloc] init];
            chat.conversation=resultObject;
            [weakSelf.navigationController pushViewController:chat animated:YES];
        } else {
            ShowAutoHideMBProgressHUD(self.view, @"请稍后再试~");
        }
    }];
}

- (NSArray *)orderInfoShows {
    NSMutableArray *arr = [NSMutableArray array];
    NSString *orderSta;
    NSString *createTime = getStringFromTimeintervalString(self.fixModel.create_time, @"yyyy-MM-dd HH:mm")?:@"";
    NSString *offerTime = getStringFromTimeintervalString(self.fixModel.offer_time, @"yyyy-MM-dd HH:mm")?:@"";
    NSString *sureTime = getStringFromTimeintervalString(self.fixModel.repair_time, @"yyyy-MM-dd HH:mm")?:@"";
    NSString *payTime = getStringFromTimeintervalString(self.fixModel.pay_time, @"yyyy-MM-dd HH:mm")?:@"";
    NSString *cancelTime = getStringFromTimeintervalString(self.fixModel.cancel_time, @"yyyy-MM-dd HH:mm")?:@"";
    
    switch (self.fixModel.fixState) {
        case FixStateWait:
        {
            orderSta = self.fixModel.is_offer==1?@"已报价":@"等待接单";
            if (self.fixModel.is_offer==1) {
                [arr addObject:@{@"t":@"报价时间",@"v":offerTime}];
                self.sureButton.hidden=YES;
                self.cancelRight.constant = 15;
            } else {
                self.moneyView.hidden=YES;
                self.moneyCOntentHeight.constant = 0;
            }

        }
            break;
        case FixStateAccept:
        {
            orderSta = self.fixModel.repair_state==2?@"等待车主付款":@"维修中";
            if (self.fixModel.repair_state==2) {
                self.sureButton.hidden = YES;
                self.cancelBtn.hidden = YES;
            } else {// 维修中
                [self.sureButton setTitle:@"维修完成" forState:UIControlStateNormal];
            }
            [arr addObject:@{@"t":@"报价时间",@"v":offerTime}];
            [arr addObject:@{@"t":@"确认时间",@"v":sureTime}];
        }
            break;
        case FixStateComplete:
        {
            orderSta = @"已完成";
            self.linkLeft.constant = 5;
            self.cancelBtn.hidden=self.sureButton.hidden=self.phoneView.hidden=self.positionView.hidden=YES;
            NSString *payment = @"支付宝支付";
            if (self.fixModel.payment_type==2) {
                payment = @"微信支付";
            } else if (self.fixModel.payment_type == 3) {
                payment = @"现金支付";
            }
            [arr addObject:@{@"t":@"支付方式",@"v":payment}];
            [arr addObject:@{@"t":@"报价时间",@"v":offerTime}];
            [arr addObject:@{@"t":@"确认时间",@"v":sureTime}];
            [arr addObject:@{@"t":@"支付时间",@"v":payTime}];
        }
            break;
        case FixStateCancel:
        {
            self.cancelBtn.hidden=self.sureButton.hidden=self.phoneView.hidden=self.positionView.hidden=YES;
            self.linkLeft.constant = 5;
            self.moneyView.hidden=YES;
            self.moneyCOntentHeight.constant = 0;
            self.cancelView.hidden=NO;
            self.cancelTitleL.text = self.fixModel.cancel_title;
            self.cancelContentL.text = self.fixModel.cancel_content;
            orderSta = self.fixModel.cancel_state==1?@"车主取消":@"维修点取消";
            [arr addObject:@{@"t":@"取消时间",@"v":cancelTime}];
        }
            break;
        default:
            break;
    }
    self.orderStateString = orderSta;
    [arr insertObject:@{@"t":@"下单时间",@"v":createTime} atIndex:self.fixModel.fixState==FixStateComplete?1:0];
    [arr insertObject:@{@"t":@"订单状态",@"v":orderSta} atIndex:0];
    return arr;
}

@end
