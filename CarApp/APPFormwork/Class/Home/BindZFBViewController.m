

#import "BindZFBViewController.h"

@interface BindZFBViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *userTF;

@end

@implementation BindZFBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"绑定用户";
    [self setBackButton];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(regisTextField)]];
    if (self.hadBind) {
        self.nameTF.text = [CurrentUserInfo sharedInstance].alipay_name;
        self.userTF.text = [CurrentUserInfo sharedInstance].alipay_number;
    }
}
- (IBAction)bingZFB:(id)sender {
    if (self.nameTF.text.length==0) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入账户名称");
        return;
    }
    if (self.userTF.text.length==0) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入支付宝账号");
        return;
    }
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient bindZFB:self.nameTF.text num:self.userTF.text completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            if (weakSelf.bindZFBSuccess) {
                weakSelf.bindZFBSuccess();
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }
        FailedMBProgressHUD(weakSelf.view, response.message);
    }];
}

- (void)regisTextField {
    [self.view endEditing:YES];
}


@end
