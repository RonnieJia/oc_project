
#import "BindPhoneViewController.h"

@interface BindPhoneViewController ()
@property (weak, nonatomic) IBOutlet UITextField *mobileTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property(nonatomic, weak)UIButton *codeBtn;
@property(nonatomic, assign)NSInteger time;

@end

@implementation BindPhoneViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButton];
    self.title = @"绑定手机号";
    self.btn.layer.cornerRadius = 17;
    
    UIButton *btn = RJCreateTextButton(CGRectMake(0, 0, 85, 30), kFontWithSmallSize, KTextWhiteColor, nil, @"获取验证码");
    self.mobileTF.rightView = btn;
    btn.backgroundColor = [UIColor colorWithHex:@"#FF2D24"];
    btn.layer.cornerRadius = 4;
    btn.clipsToBounds = YES;
    self.mobileTF.rightViewMode = UITextFieldViewModeAlways;
    self.codeBtn = btn;
    [btn addTarget:self action:@selector(fetchCodeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

/// 获取验证码
- (void)fetchCodeButtonAction:(UIButton *)button {
    if (!IsNormalMobileNum(self.mobileTF.text)) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入手机号");
        return;
    }
    button.selected=YES;
    self.time = 60;
    [self timerActionToChange];
    weakify(self);
    [kRJHTTPClient getVerifyCodeWithPhone:self.mobileTF.text type:MobileCodeTypeResetPwd completion:^(WebResponse *response) {
        //        if (response.code != WebResponseCodeSuccess) {
        //            ShowAutoHideMBProgressHUD(weakSelf.view, response.message);
        //        }
    }];
}

- (void)timerActionToChange {
    if (self.time <= 0) {
        self.codeBtn.selected = NO;
    } else {
        [self.codeBtn setTitle:[NSString stringWithFormat:@"%zds后重发",self.time--] forState:UIControlStateSelected];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timerActionToChange) object:nil];
        [self performSelector:@selector(timerActionToChange) withObject:nil afterDelay:1.0];
    }
}


- (IBAction)bindAction:(id)sender {
    if (self.mobileTF.text.length == 0) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入手机号");
        return;
    }
    if (self.codeTF.text.length == 0) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入验证码");
        return;
    }
    [self.view endEditing:YES];
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
//    self.clientDataTask = [kRJHTTPClient changeMobile:self.mobileTF.text code:self.codeTF.text pwd:@"" wx:YES completion:^(WebResponse *response) {
//        if (response.code == WebResponseCodeSuccess) {
//            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
//            FinishMBProgressHUD(weakSelf.view);
//        } else {
//            [CurrentUserInfo sharedInstance].userId = nil;
//            FailedMBProgressHUD(weakSelf.view, response.message);
//        }
//    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
