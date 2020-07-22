
#import "WithdrawCashViewController.h"
#import "BindZFBViewController.h"

@interface WithdrawCashViewController ()
@property (weak, nonatomic) IBOutlet UITextField *moneyTextField;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UIButton *bingBtn;

@end

@implementation WithdrawCashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"提现";
    self.moneyLabel.text = [NSString stringWithFormat:@"账户余额 ￥%@",[CurrentUserInfo sharedInstance].balance];
    [self setBackButton];
    [self isBindZFB];
}

- (void)isBindZFB {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    self.clientDataTask = [kRJHTTPClient isBindZFBCompletion:^(WebResponse *response) {
        if ([response.message containsString:@"已绑定"]||response.code == 102) {
            weakSelf.bingBtn.selected= YES;
        } else {
            weakSelf.bingBtn.selected= NO;
        }
        FinishMBProgressHUD(weakSelf.view);
    }];
}
- (IBAction)cashMoney:(id)sender {
    if (!self.bingBtn.selected) {
        ShowAutoHideMBProgressHUD(self.view, @"请绑定支付宝");
        return;
    }
    if (IsStringEmptyOrNull(self.moneyTextField.text) || !IsNumber(self.moneyTextField.text) || [self.moneyTextField.text floatValue]==0) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入提现金额");
        return;
    }
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient cashMoney:self.moneyTextField.text completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [CurrentUserInfo sharedInstance].balance = [NSString stringWithFormat:@"%.2f",[[CurrentUserInfo sharedInstance].balance floatValue]-[weakSelf.moneyTextField.text floatValue]];
            weakSelf.moneyTextField.text = nil;
            weakSelf.moneyLabel.text = [NSString stringWithFormat:@"账户余额 ￥%@",[CurrentUserInfo sharedInstance].balance];
        }
        FailedMBProgressHUD(weakSelf.view, response.message);
    }];
}

- (IBAction)bindZFB:(UIButton *)sender {
    BindZFBViewController *zfb = [BindZFBViewController new];
    zfb.hadBind = self.bingBtn.selected;
    [zfb setBindZFBSuccess:^{
        [self isBindZFB];
    }];
    [self.navigationController pushViewController:zfb animated:YES];
}

@end
