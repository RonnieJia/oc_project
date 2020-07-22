#import "RescueOrderViewController.h"
#import "RescueModel.h"
#import "NotesOrderUserView.h"
#import "RescueInfoViewController.h"
#import "SceneView.h"
#import "RescueEditViewController.h"
#import "CarInfoViewController.h"
#import "MapLocationViewController.h"

@interface RescueOrderViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moneyTimeConstraint;// 报价时间
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sureTimeConstraint;// 确认时间
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *payTimeConstraint;// 支付时间
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *payTypeConstraint;// 支付方式
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moneyInfoConstraint;// 费用明细
@property (weak, nonatomic) IBOutlet UILabel *refuseLabel;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight;

@property (nonatomic, strong) SceneView *senceView;
@end

@implementation RescueOrderViewController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"订单详情";
    [self setBackButton];
    [self fetchDetail];
    weakify(self);
    self.orderUserInfo.pushCarInfoBlock = ^{
        CarInfoViewController *info = [[CarInfoViewController alloc] init];
        info.car_id=weakSelf.rescueModel.vehicle_id;
        [weakSelf.navigationController pushViewController:info animated:YES];
    };
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rescueOfferSuccess:) name:kRescueOffer object:nil];
}

- (void)rescueOfferSuccess:(NSNotification *)noti {
    RescueModel *model = noti.object;
    if ([model.r_id isEqualToString:self.rescueModel.r_id]) {
        [self fetchDetail];
    }
}

- (void)displayInfo {
    self.orderNum.text = self.rescueModel.order_number;
    self.orderUserInfo.nameLabel.text = self.rescueModel.v_name;
    self.orderUserInfo.infoLabel.text = [NSString stringWithFormat:@"司机%@",self.rescueModel.r_name];
    self.orderStartTimeLabel.text = getStringFromTimeintervalString(self.rescueModel.create_time, @"yyyy-MM-dd hh:mm");
    self.acceptTimeLabel.text = getStringFromTimeintervalString(self.rescueModel.receipt_time, @"yyyy-MM-dd hh:mm");
    self.moneyTimeLabel.text = getStringFromTimeintervalString(self.rescueModel.offer_time, @"yyyy-MM-dd hh:mm");
    self.sureTimeLabel.text = getStringFromTimeintervalString(self.rescueModel.repair_time, @"yyyy-MM-dd hh:mm");
    self.payTimeLabel.text = getStringFromTimeintervalString(self.rescueModel.pay_time, @"yyyy-MM-dd hh:mm");
    self.partMoneyLabel.text = [NSString stringWithFormat:@"￥%@",self.rescueModel.parts_money];
    self.timeMoneyLabel.text = [NSString stringWithFormat:@"￥%@",self.rescueModel.working_money];
    NSString *totalMoney = [NSString stringWithFormat:@"合计：￥%@",self.rescueModel.money];
    NSMutableAttributedString *att= [[NSMutableAttributedString alloc] initWithString:totalMoney];
    [att addAttribute:NSForegroundColorAttributeName value:kTextRedColor range:NSMakeRange(3, totalMoney.length-3)];
    [att addAttribute:NSFontAttributeName value:kFontWithSmallestSize range:NSMakeRange(0, 3)];
    self.moneyLabel.attributedText=att;
    
    
    NSString *payType = @"支付宝支付";
    if (self.rescueModel.payment==2) {
        payType = @"微信支付";
    } else if (self.rescueModel.payment==3) {
        payType = @"现金支付";
    }
    self.payTypeLabel.text = payType;
    [self showViewWithRescueState];
}
- (void)fetchDetail {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    self.clientDataTask = [kRJHTTPClient fetchRescueDetail:self.rescueModel.r_id completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [weakSelf.rescueModel loadRescueDetail:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"info")];
            [weakSelf displayInfo];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}


- (void)showViewWithRescueState {
    NSInteger itemHideTag = 7;
    self.refuseLabel.text = @"接单时间";
    switch (self.rescueModel.rescueState) {
        case RescueStateAccept:{// 已接单
            itemHideTag = 5;
            if (self.rescueModel.repair_state==0) {////维修状态0已接单 1维修中（同意维修） 2维修完成等待付款
                if (self.rescueModel.is_offer==1) {// 已报价
                    self.orderStateLabel.text = @"已报价";
                    self.bottomBtn.hidden=YES;
                    itemHideTag = 4;
                } else {// 未报价
                    itemHideTag = 3;
                    self.moneyView.hidden=YES;
                    self.moneyInfoConstraint.constant=0;
                    self.orderStateLabel.text = @"已接单";
                    self.moneyTimeConstraint.constant=0;
                    [self.bottomBtn setTitle:@"到达现场" forState:UIControlStateNormal];
                }
                self.sureTimeConstraint.constant = 0;
            } else if (self.rescueModel.repair_state == 1) {
                self.orderStateLabel.text = @"维修中";
                [self.bottomBtn setTitle:@"维修完成" forState:UIControlStateNormal];
            } else {
                self.orderStateLabel.text = @"等待车主付款";
                self.bottomBtn.hidden=YES;
            }
            self.payTimeConstraint.constant = 0;
            self.payTypeConstraint.constant = 0;
        }
            break;
        case RescueStateFinish:{// 已完成
            self.orderStateLabel.text = @"已完成";
            itemHideTag = 7;
            self.bottomView.hidden = YES;
            self.bottomHeight.constant = 0;
        }
            break;
        case RescueStateRefuse:{
            self.moneyView.hidden=YES;
            self.moneyInfoConstraint.constant=0;
            self.moneyTimeConstraint.constant=0;
            self.sureTimeConstraint.constant =0;
            self.payTimeConstraint.constant = 0;
            self.payTypeConstraint.constant = 0;
            self.orderStateLabel.text = @"已拒绝";
            self.refuseLabel.text = @"拒绝时间";
            self.acceptTimeLabel.text = getStringFromTimeintervalString(self.rescueModel.refuse_time, @"yyyy-MM-dd HH:mm");
            self.bottomView.hidden = YES;
            self.bottomHeight.constant = 0;
            itemHideTag = 3;
        }
            break;
        default:
            break;
    }
    for (int i = 0; i<7; i++) {
        UIView *view = [self.orderView viewWithTag:100+i];
        view.hidden = i>=itemHideTag;
    }
}
- (IBAction)rescueInfoBtnClick:(id)sender {
    RescueInfoViewController *info = [[RescueInfoViewController alloc] init];
    info.rescueModel = self.rescueModel;
    [self.navigationController pushViewController:info animated:YES];
}
- (IBAction)bottomBtnAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if ([btn.currentTitle isEqualToString:@"到达现场"]) {
        weakify(self);
        [self.senceView showWithCallback:^(NSInteger index) {
            if (index == 0) {// 进行维修
                RescueEditViewController *rescue = [[RescueEditViewController alloc] init];
                rescue.rescueModel = weakSelf.rescueModel;
                [weakSelf.navigationController pushViewController:rescue animated:YES];
            } else {// 拒绝维修
                [weakSelf refuseRescue];
            }
        }];
    } else if ([btn.currentTitle isEqualToString:@"维修完成"]) {
        WaittingMBProgressHUD(self.view, @"");
        weakify(self);
        [kRJHTTPClient rescueComplete:self.rescueModel.r_id completion:^(WebResponse *response) {
            if (response.code == WebResponseCodeSuccess) {
                weakSelf.rescueModel.repair_state = 2;
                [weakSelf displayInfo];
                if (weakSelf.rescueRepairComplete) {
                    weakSelf.rescueRepairComplete();
                }
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
        }];
    }
}

- (void)refuseRescue {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient rescueRefuse:self.rescueModel.r_id completion:^(WebResponse *response) {
        
        FailedMBProgressHUD(weakSelf.view, response.message);
        if (response.code == WebResponseCodeSuccess) {
            if (weakSelf.rescueRepairRefuse) {
                weakSelf.rescueRepairRefuse(self.rescueModel, NO);
            }
            [self fetchDetail];
        }
    }];
}
- (IBAction)locationAction:(id)sender {
    MapLocationViewController *location = [MapLocationViewController new];
    location.lat = self.rescueModel.latitude;
    location.lon = self.rescueModel.longitude;
    location.oName = self.rescueModel.o_nickname;
    location.address = self.rescueModel.r_position;
    [self.navigationController pushViewController:location animated:YES];
}
- (IBAction)contactAction:(id)sender {
    makePhoneCall(self.rescueModel.o_number);
}

- (SceneView *)senceView {
    if (!_senceView) {
        _senceView = [[SceneView alloc] init];
    }
    return _senceView;
}
@end
