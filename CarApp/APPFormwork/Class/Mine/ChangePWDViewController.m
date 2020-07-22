

#import "ChangePWDViewController.h"
#import "IssueInputView.h"

@interface ChangePWDViewController ()
@property(nonatomic, weak)UITextField *mobileTF;
@property(nonatomic, weak)UITextField *codeTF;
@property(nonatomic, weak)UITextField *pwdTF;
@property(nonatomic, weak)UITextField *pwd2TF;
@property(nonatomic, assign)BOOL disAppear;
@end

@implementation ChangePWDViewController
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.disAppear = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改密码";
    [self setBackButton];
    [self createMainView];
}

- (void)createMainView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KViewNavHeight)];
    [self.view addSubview:scrollView];
    
    UIButton *codeBtn = RJCreateTextButton(CGRectMake(0, 0, 80, 40), kFontWithSmallSize, KTextDarkColor, nil, @"获取验证码");
    [codeBtn addTarget:self action:@selector(codeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    codeBtn.contentHorizontalAlignment=2;
    IssueInputView *mobile = [[IssueInputView alloc] initWithY:0 title:@"手机号" placeholder:@"请输入手机号" rightView:codeBtn];
    mobile.textField.text = GetUserName();
    mobile.textField.enabled = NO;
    [scrollView addSubview:mobile];
    IssueInputView *code = [[IssueInputView alloc] initWithY:mobile.bottom title:@"验证码" placeholder:@"请输入验证码" rightText:nil];
    [scrollView addSubview:code];
    IssueInputView *pwd = [[IssueInputView alloc] initWithY:code.bottom title:@"新密码" placeholder:@"请输入新密码" rightText:nil];
    pwd.textField.secureTextEntry=YES;
    [scrollView addSubview:pwd];
    IssueInputView *pwd2 = [[IssueInputView alloc] initWithY:pwd.bottom title:@"确认新密码" placeholder:@"请输入新密码" rightText:nil];
    pwd2.textField.secureTextEntry=YES;
    [scrollView addSubview:pwd2];
    
    self.mobileTF = mobile.textField;
    self.codeTF = code.textField;
    self.pwdTF = pwd.textField;
    self.pwd2TF = pwd2.textField;
    
    UIButton *changeBtn = RJCreateTextButton(CGRectMake(15, pwd2.bottom+50, KScreenWidth-30, 44), kFontWithSmallSize, KTextWhiteColor, createImageWithColor(KThemeColor), @"立即修改");
    [scrollView addSubview:changeBtn];
    changeBtn.layer.cornerRadius = 22;
    changeBtn.clipsToBounds = YES;
    scrollView.contentSize = CGSizeMake(KScreenWidth, changeBtn.bottom+30);
    [changeBtn addTarget:self action:@selector(changePWDBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(regisTextField)]];
}

- (void)changePWDBtnClick:(UIButton *)btn {
    if (self.mobileTF.text.length == 0) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入手机号");
        return;
    }
    if (self.codeTF.text.length == 0) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入验证码");
        return;
    }
    if (self.pwdTF.text.length == 0) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入新密码");
        return;
    }
    if (self.pwd2TF.text.length == 0) {
        ShowAutoHideMBProgressHUD(self.view, @"请确认新密码");
        return;
    }
    if (![self.pwd2TF.text isEqualToString:self.pwdTF.text]) {
        ShowAutoHideMBProgressHUD(self.view, @"两次输入密码不一致");
        return;
    }
    [self.view endEditing:YES];
    WaittingMBProgressHUD(self.view, @"");
    [kRJHTTPClient changePwd:self.mobileTF.text code:self.codeTF.text pwd:self.pwdTF.text completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            if ([self.mobileTF.text isEqualToString:GetUserName()]) {
                SaveUser(self.mobileTF.text, self.pwd2TF.text, [CurrentUserInfo sharedInstance].userId);
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
        FailedMBProgressHUD(self.view, response.message);
    }];
}

- (void)codeButtonClick:(UIButton *)btn {
    if (btn.selected) {
        return;
    }
    if (!IsNormalMobileNum(self.mobileTF.text)) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入正确手机号");
        return;
    }
    [kRJHTTPClient getVerifyCodeWithPhone:self.mobileTF.text type:MobileCodeTypeResetPwd completion:^(WebResponse *response) {
        if (response.code != WebResponseCodeSuccess) {
            ShowAutoHideMBProgressHUD(self.view, response.message);
        }
    }];
    btn.selected=YES;
    [self changeButtonText:60 btn:btn];
}

- (void)changeButtonText:(NSInteger)time btn:(UIButton *)btn {
    if (self.disAppear) {
        return;
    }
    if (time == 0) {
        btn.selected=NO;
        return;
    }
    [btn setTitle:[NSString stringWithFormat:@"%02zdS后获取",time] forState:UIControlStateSelected];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self changeButtonText:time-1 btn:btn];
    });
    
}

- (void)regisTextField {
    [self.view endEditing:YES];
}

@end
