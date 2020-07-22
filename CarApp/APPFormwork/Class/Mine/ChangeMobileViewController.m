

#import "ChangeMobileViewController.h"
#import "IssueInputView.h"

@interface ChangeMobileViewController ()
@property(nonatomic, weak)UITextField *mobileTF;
@property(nonatomic, weak)UITextField *codeTF;
@property(nonatomic, assign)BOOL disAppear;
@end

@implementation ChangeMobileViewController
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.disAppear = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改手机号";
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
    [scrollView addSubview:mobile];
    IssueInputView *code = [[IssueInputView alloc] initWithY:mobile.bottom title:@"验证码" placeholder:@"请输入验证码" rightText:nil];
    [scrollView addSubview:code];
    
    self.mobileTF = mobile.textField;
    self.codeTF = code.textField;
    
    UIButton *changeBtn = RJCreateTextButton(CGRectMake(15, code.bottom+50, KScreenWidth-30, 44), kFontWithSmallSize, KTextWhiteColor, createImageWithColor(KThemeColor), @"立即修改");
    [scrollView addSubview:changeBtn];
    changeBtn.layer.cornerRadius = 22;
    changeBtn.clipsToBounds = YES;
    scrollView.contentSize = CGSizeMake(KScreenWidth, changeBtn.bottom+30);
    [changeBtn addTarget:self action:@selector(changeMobileBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(regisTextField)]];
}

- (void)changeMobileBtnClick:(UIButton *)btn {
    if (self.mobileTF.text.length==0) {
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
    [kRJHTTPClient changeMobile:self.mobileTF.text code:self.codeTF.text completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }
        FailedMBProgressHUD(weakSelf.view, response.message);
    }];
}

- (void)codeButtonClick:(UIButton *)btn {
    if (btn.selected) {
        return;
    }
    if (!IsNormalMobileNum(self.mobileTF.text)) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入正确的手机号");
        return;
    }
    [kRJHTTPClient getVerifyCodeWithPhone:self.mobileTF.text type:MobileCodeTypeChangeMobile completion:^(WebResponse *response) {
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
