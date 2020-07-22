

#import "RescueEditViewController.h"
#import "NotesOrderUserView.h"
#import "RescueModel.h"
#import "CarInfoViewController.h"
#import "RescueInfoViewController.h"

@interface RescueEditViewController ()
@property (weak, nonatomic) IBOutlet NotesOrderUserView *carOrderView;
@property (weak, nonatomic) IBOutlet UITextField *pmoneyTF;
@property (weak, nonatomic) IBOutlet UITextField *wmoneyTF;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstaint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation RescueEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = KTextWhiteColor;
    self.title = @"编辑订单";
    self.carOrderView.nameLabel.text = self.rescueModel.v_name;
    self.carOrderView.infoLabel.text = [NSString stringWithFormat:@"车主%@",self.rescueModel.r_name];
    weakify(self);
    self.carOrderView.pushCarInfoBlock = ^{
        CarInfoViewController *info = [[CarInfoViewController alloc] init];
        info.car_id=weakSelf.rescueModel.vehicle_id;
        [weakSelf.navigationController pushViewController:info animated:YES];
    };
    [self setBackButton];
    [self.scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(regisInput)]];
}
- (void)regisInput {
    [self.view endEditing:YES];
}
- (IBAction)commitAction:(UIButton *)sender {
    if (IsStringEmptyOrNull(self.pmoneyTF.text) || !IsNumber(self.pmoneyTF.text)) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入配件金额");
        return;
    }
    if (IsStringEmptyOrNull(self.wmoneyTF.text) || !IsNumber(self.wmoneyTF.text) || [self.wmoneyTF.text floatValue]==0) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入工时费金额");
        return;
    }
    [self.view endEditing:YES];
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    self.clientDataTask = [kRJHTTPClient rescueEdit:self.rescueModel.r_id pmoney:self.pmoneyTF.text time:self.wmoneyTF.text completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            weakSelf.rescueModel.repair_state = 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:kRescueOffer object:weakSelf.rescueModel];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }
        FailedMBProgressHUD(weakSelf.view, response.message);
    }];
}
- (IBAction)pushToRescueInfo:(id)sender {
    RescueInfoViewController *info = [[RescueInfoViewController alloc] init];
    info.rescueModel = self.rescueModel;
    [self.navigationController pushViewController:info animated:YES];
}


#pragma mark - 键盘弹出及收起
- (void)keyboardWasShown:(NSNotification *)noti {
    CGFloat height = FetchKeyBoardHeight(noti)-kIPhoneXBH;
    self.bottomConstaint.constant = height;
}

- (void)keyboardWillBeHidden:(NSNotification *)noti {
    self.bottomConstaint.constant = 0;
}

@end
