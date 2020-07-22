

#import "FixEditViewController.h"
#import "FixModel.h"
#import "NotesOrderUserView.h"
#import "CarInfoViewController.h"
#import "RepairModel.h"

@interface FixEditViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet NotesOrderUserView *carInfoView;
@property (weak, nonatomic) IBOutlet UITextField *partMoneyTF;
@property (weak, nonatomic) IBOutlet UITextField *hourMoneyTF;
@property (weak, nonatomic) IBOutlet UITextView *remarkTV;
@property (weak, nonatomic) IBOutlet UILabel *placeL;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContaist;

@end

@implementation FixEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑订单";
    [self displayCarInfo];
    [self.scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(regisInput)]];
}

- (void)regisInput {
    [self.view endEditing:YES];
}

- (void)displayCarInfo {
    if (self.repair) {
        self.carInfoView.nameLabel.text = self.repairModel.v_name;
        self.carInfoView.infoLabel.text = self.repairModel.o_nickname;
        weakify(self);
        self.carInfoView.pushCarInfoBlock = ^{
            CarInfoViewController *car = [CarInfoViewController new];
            car.car_id = weakSelf.repairModel.v_id;
            [weakSelf.navigationController pushViewController:car animated:YES];
        };
//        self.carInfoView.hiddenDetail = YES;
    } else {
        self.carInfoView.nameLabel.text = self.fixModel.v_name;
        self.carInfoView.infoLabel.text = self.fixModel.o_nickname;
        weakify(self);
        self.carInfoView.pushCarInfoBlock = ^{
            CarInfoViewController *car = [CarInfoViewController new];
            car.car_id = weakSelf.fixModel.vehicle_id;
            [weakSelf.navigationController pushViewController:car animated:YES];
        };
    }
}
- (IBAction)commitAction:(id)sender {
    if (IsStringEmptyOrNull(self.partMoneyTF.text) || !IsNumber(self.partMoneyTF.text)) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入配件金额");
        return;
    }
    if (IsStringEmptyOrNull(self.hourMoneyTF.text) || !IsNumber(self.hourMoneyTF.text) || [self.hourMoneyTF.text floatValue]==0) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入工时费金额");
        return;
    }
    
    if (self.partMoneyTF.text.length==0) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入配件金额");
        return;
    }
    if (self.hourMoneyTF.text.length == 0) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入工时费金额");
        return;
    }
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    if (self.repair) {// 报修订单报价
        [kRJHTTPClient repairOffer:self.repairModel.re_id pMoney:self.partMoneyTF.text hMoney:self.hourMoneyTF.text remark:self.remarkTV.text completion:^(WebResponse *response) {
            if (response.code == WebResponseCodeSuccess) {
                ///报价成功
                weakSelf.repairModel.is_offer=1;
                weakSelf.repairModel.re_price = [NSString stringWithFormat:@"%.2f",([weakSelf.partMoneyTF.text floatValue]+[weakSelf.hourMoneyTF.text floatValue])];
                weakSelf.repairModel.parts_money = weakSelf.partMoneyTF.text;
                weakSelf.repairModel.working_money = weakSelf.hourMoneyTF.text;
                [[NSNotificationCenter defaultCenter] postNotificationName:kRepairOffer object:weakSelf.repairModel];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
        }];
    } else {// 维修订单报价
        [kRJHTTPClient fixOffer:self.fixModel.order_rid pMoney:self.partMoneyTF.text hMoney:self.hourMoneyTF.text remark:self.remarkTV.text completion:^(WebResponse *response) {
            if (response.code == WebResponseCodeSuccess) {
                ///报价成功
                weakSelf.fixModel.price = [NSString stringWithFormat:@"%.2f",([weakSelf.partMoneyTF.text floatValue]+[weakSelf.hourMoneyTF.text floatValue])];
                weakSelf.fixModel.parts_price = weakSelf.partMoneyTF.text;
                weakSelf.fixModel.hours_price = weakSelf.hourMoneyTF.text;
                weakSelf.fixModel.is_offer=1;
                [[NSNotificationCenter defaultCenter] postNotificationName:kFixReportSuccess object:weakSelf.fixModel.order_rid];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
            
        }];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    self.placeL.hidden = textView.text.length>0;
}

#pragma mark - 键盘弹出及收起
- (void)keyboardWasShown:(NSNotification *)noti {
    CGFloat height = FetchKeyBoardHeight(noti)-kIPhoneXBH;
    self.bottomContaist.constant = height;
}

- (void)keyboardWillBeHidden:(NSNotification *)noti {
    self.bottomContaist.constant = 0;
}

@end
