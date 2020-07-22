//

#import "RepairOrderInfoViewController.h"
#import "RepairModel.h"
#import "NotesOrderUserView.h"
#import "FixEditViewController.h"
#import "RefundReasonViewController.h"
#import "RepairRefundViewController.h"
#import "RepairInfoViewController.h"
#import "LinkOnlineView.h"
#import "ChatViewController.h"
#import "CarInfoViewController.h"

@interface RepairOrderInfoViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NotesOrderUserView *orderUserInfo;
@property (weak, nonatomic) IBOutlet UIView *moneyView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moneyViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *pMoneyL;
@property (weak, nonatomic) IBOutlet UILabel *hMoneyL;
@property (weak, nonatomic) IBOutlet UILabel *orderNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *orderInfoViewa;
@property (weak, nonatomic) IBOutlet UIView *cancelView;
@property (weak, nonatomic) IBOutlet UILabel *cancelReason;
@property (weak, nonatomic) IBOutlet UILabel *cancelDescL;
@property (weak, nonatomic) IBOutlet UIView *commitView;
@property (weak, nonatomic) IBOutlet UIButton *offerBtn;
@property (weak, nonatomic) IBOutlet UIButton *refuseBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offerRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *refuseRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelRight;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *linkLeftView;
@property (weak, nonatomic) IBOutlet UIView *linkRightView;

@property(nonatomic, strong)NSString *stateString;

@end

@implementation RepairOrderInfoViewController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"订单详情";
    self.refuseBtn.layer.borderColor = self.cancelBtn.layer.borderColor = KTextGrayColor.CGColor;
    self.refuseBtn.layer.borderWidth = self.cancelBtn.layer.borderWidth = 1;
    [self fetchData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repairOffer:) name:kRepairOffer object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repairOffer:) name:kRepairRefund object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repairOffer:) name:kRepairCancel object:nil];
    weakify(self);
    [self setNavBarBtnWithType:NavBarTypeRight title:@"在线联系" action:^{
        [[LinkOnlineView sharedInstance] showWithBlock:^(NSInteger index) {
            [weakSelf linkWithType:index];
        }];
    }];
}

- (void)linkWithType:(NSInteger)type {
    NSString *userName, *appKey;
    if (type==0) {
        userName = [NSString stringWithFormat:kTrailerWord,self.repairModel.t_id];
        appKey = kTrailerAppKey;
    } else if (type == 1) {
        userName = kPlatformWord;
        appKey = kPlatformAppKey;
    } else {
        userName = [NSString stringWithFormat:kCarOwnerWord,self.repairModel.o_id];
        appKey = kCarOwnerAppKey;
    }
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

- (void)repairOffer:(NSNotification *)noti {// 报价完成
    RepairModel *rModel = noti.object;
    if (rModel == self.repairModel) {
        [self fetchData];
    }
}

- (void)fetchData {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient fetchRepairInfo:self.repairModel.re_id completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [weakSelf.repairModel loadDetail:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"info")];
            [weakSelf displayInfo];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}


- (void)displayInfo {
    self.bottomView.hidden=NO;
    self.orderUserInfo.nameLabel.text = self.repairModel.v_name;
    self.orderUserInfo.infoLabel.text = [NSString stringWithFormat:@"车主%@",self.repairModel.o_nickname];
    weakify(self);
    self.orderUserInfo.pushCarInfoBlock = ^{
        CarInfoViewController *car = [CarInfoViewController new];
        car.car_id = weakSelf.repairModel.v_id;
        [weakSelf.navigationController pushViewController:car animated:YES];

    };
    self.pMoneyL.text = [NSString stringWithFormat:@"￥%@",self.repairModel.parts_money];
    self.hMoneyL.text = [NSString stringWithFormat:@"￥%@",self.repairModel.working_money];
    NSString *totalMoney = [NSString stringWithFormat:@"合计：￥%@",self.repairModel.re_price];
    NSMutableAttributedString *att= [[NSMutableAttributedString alloc] initWithString:totalMoney];
    [att addAttribute:NSForegroundColorAttributeName value:kTextRedColor range:NSMakeRange(3, totalMoney.length-3)];
    [att addAttribute:NSFontAttributeName value:kFontWithSmallestSize range:NSMakeRange(0, 3)];
    self.moneyLabel.attributedText=att;
    [self showViewWithRepairState];
    self.scrollView.hidden=NO;
}


- (void)showViewWithRepairState {
    NSMutableArray *infosArr = [NSMutableArray array];
    NSString *stateStr;
    [infosArr addObject:@{@"t":@"挂车厂", @"v":self.repairModel.t_name?:@""}];
    [infosArr addObject:@{@"t":@"下单时间",@"v":getStringFromTimeintervalString(self.repairModel.create_time, @"yyyy-MM-dd HH:mm")?:@""}];
    
    NSDictionary *payDic = @{@"t":@"支付时间",@"v":getStringFromTimeintervalString(self.repairModel.pay_time, @"yyyy-MM-dd HH:mm")?:@""};
    NSDictionary *compleDic = @{@"t":@"完成时间",@"v":getStringFromTimeintervalString(self.repairModel.complete_time, @"yyyy-MM-dd HH:mm")?:@""};
    self.moneyView.hidden = NO;
    self.moneyViewHeight.constant=139;
    switch (self.repairModel.re_repair_state) {
        case RepairStateWait:{// 已接单
            if (self.repairModel.is_offer==1) {// 已报价
                stateStr = @"已报价,等待车厂付款";
                [infosArr addObject:@{@"t":@"报价时间",@"v":getStringFromTimeintervalString(self.repairModel.offer_time, @"yyyy-MM-dd HH:mm")?:@""}];
                self.offerBtn.hidden=YES;
                self.refuseBtn.hidden = YES;
            } else {
                self.moneyView.hidden = YES;
                self.moneyViewHeight.constant=0;
                stateStr = @"等待接单";
            }
        }
            break;
        case RepairStateAccept:{//
            stateStr = @"维修中";
            [infosArr addObject:payDic];
            self.linkLeftView.hidden=self.linkRightView.hidden=self.refuseBtn.hidden=self.offerBtn.hidden=YES;
//            self.offerRight.constant=15;
            self.cancelRight.constant = 15;
//            [self.offerBtn setTitle:@"已完成" forState:UIControlStateNormal];
        }
            break;
        case RepairStateComplete:{
            self.bottomView.hidden=YES;
            stateStr = @"已完成";
            [infosArr addObject:payDic];
            [infosArr addObject:compleDic];
        }
            break;
        case RepairStateCancel:{
            self.bottomView.hidden=self.moneyView.hidden=YES;
            self.moneyViewHeight.constant=0;
            self.cancelView.hidden=NO;
            self.cancelReason.text = self.repairModel.type_title;
            self.cancelDescL.text = self.repairModel.cancel_content;
            stateStr = self.repairModel.cancel_state==1?@"车主取消":@"维修点取消";
            [infosArr addObject:@{@"t":@"取消时间",@"v":getStringFromTimeintervalString(self.repairModel.cancel_time, @"yyyy-MM-dd HH:mm")?:@""}];
        }
            break;
        case RepairStateRefuse:{
            if (self.repairModel.is_trailer_confirm==2) {//挂车厂不认可
                self.cancelBtn.hidden=self.offerBtn.hidden=self.refuseBtn.hidden=YES;
            } else {
                self.bottomView.hidden=YES;
            }
            self.moneyView.hidden=YES;
            self.moneyViewHeight.constant=0;
            self.commitView.hidden=YES;
            if (self.repairModel.is_trailer_confirm==2) {
                self.commitView.hidden=NO;
                stateStr = @"挂车厂不认可";
            } else if (self.repairModel.is_repair_confirm==2) {
                stateStr = @"维修点不认可";
            }
            
            [infosArr addObject:@{@"t":@"否认时间",@"v":getStringFromTimeintervalString(self.repairModel.no_approval_time1, @"yyyy-MM-dd HH:mm")?:@""}];
        }
            break;
        default:
            break;
    }
    self.orderNumLabel.text = self.repairModel.re_number;
    self.stateString = stateStr;
     [infosArr insertObject:@{@"t":@"订单状态",@"v":stateStr} atIndex:0];
    for (int i = 0; i<self.orderInfoViewa.count; i++) {
        UIView *view = self.orderInfoViewa[i];
        CGFloat defauHei = 30;
        if (i<infosArr.count) {
            UILabel *tL = [view viewWithTag:0];
            UILabel *cL = [view viewWithTag:1];
            tL.text = StringForKeyInUnserializedJSONDic(infosArr[i], @"t");
            cL.text = StringForKeyInUnserializedJSONDic(infosArr[i], @"v");
        } else {
            defauHei=0;
            view.hidden=YES;
        }
        NSLayoutConstraint *hei = view.constraints.firstObject;
        if (hei && hei.constant==30) {
            hei.constant=defauHei;
        } else {
            for (NSLayoutConstraint *con in view.constraints) {
                if (con.constant==30 && con.identifier&& [con.identifier isEqualToString:@"h"]) {
                    con.constant=defauHei;
                }
            }
        }
    }
}

/// 已完成
- (void)repairOrderComplete {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient repairComplete:self.repairModel.re_id completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRepairCompleted object:self.repairModel];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }
        FailedMBProgressHUD(weakSelf.view, response.message);
    }];
}

- (IBAction)offerAction:(id)sender {// 报价
    UIButton *btn = sender;
    if ([btn.currentTitle isEqualToString:@"已完成"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定已完成？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        weakify(self);
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf repairOrderComplete];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    FixEditViewController *edit = [[FixEditViewController alloc] init];
    edit.repair = YES;
    edit.repairModel = self.repairModel;
    [self.navigationController pushViewController:edit animated:YES];
}
- (IBAction)repairInfoAction:(id)sender {//报修信息
    RepairInfoViewController *info = [[RepairInfoViewController alloc] init];
    info.state = self.stateString;
    info.repairModel = self.repairModel;
    [self.navigationController pushViewController:info animated:YES];
}
- (IBAction)commitToPT:(id)sender {//提交订单到平台
    WaittingMBProgressHUD(self.view, @"");
    [kRJHTTPClient repairSubmitAdmin:self.repairModel.re_id completion:^(WebResponse *response) {
        FailedMBProgressHUD(self.view, response.message);
    }];
}
- (IBAction)refundAction:(id)sender {// 不认可
    RepairRefundViewController *refund = [[RepairRefundViewController alloc] init];
    refund.repairModel = self.repairModel;
    [self.navigationController pushViewController:refund animated:YES];
}
- (IBAction)cancelAction:(id)sender {// 取消订单
    RefundReasonViewController *cancel = [[RefundReasonViewController alloc] init];
    cancel.type=1;
    cancel.cancelType=1;
    cancel.order_id = self.repairModel.re_id;
    cancel.obj = self.repairModel;
    [self.navigationController pushViewController:cancel animated:YES];
}

/// 联系车主
- (IBAction)linkPhoneCall:(id)sender {
    [self linkWithType:0];
}

/// 联系平台
- (IBAction)linkPlatform:(id)sender {
    [self linkWithType:1];
}
@end
