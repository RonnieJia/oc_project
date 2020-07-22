#import "RegisViewController.h"
#import "AgreeViewController.h"
#import "RegisContentView.h"

@interface RegisViewController ()<UITextFieldDelegate>
@property(nonatomic,strong)RegisContentView *regisView;
@property(nonatomic, weak)UIScrollView  *scrollView;
@property(nonatomic, assign)BOOL pushToAgreement;
@property(nonatomic, assign)NSInteger time;
@end

@implementation RegisViewController
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.pushToAgreement = NO;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (!self.pushToAgreement) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timerActionToChange) object:nil];
     }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self resignTextInputFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButton];
    [self makeMainView];
}
- (void)makeMainView {
    self.view.backgroundColor = KTextWhiteColor;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    UIScrollView *mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    [self.view addSubview:mainScrollView];
    mainScrollView.bounces = NO;
    self.scrollView = mainScrollView;
    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    mainScrollView.backgroundColor = [UIColor clearColor];
    [mainScrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignTextInputFirstResponder)]];
    [mainScrollView addSubview:self.regisView];
    mainScrollView.contentSize = CGSizeMake(KScreenWidth, self.regisView.bottom+30);
    
    weakify(self);
    self.regisView.regisBlock = ^(NSInteger index) {
        strongify(weakSelf);
        if (index == 1) {
            [strongSelf.navigationController popViewControllerAnimated:YES];
        } else if (index == 2) {
            [strongSelf.navigationController popViewControllerAnimated:YES];
//            [strongSelf pushToAgreementController];
        } else if (index == 3) {
            [strongSelf userRegisAction];
        } else if (index == 4) {
            [strongSelf pushToAgreementController];
        } else if (index == 5) {
            strongSelf.regisView.agreeBtn.selected = !strongSelf.regisView.agreeBtn.selected;
        }
    };
    
    self.regisView.mobile.codeBtnActionBlock = ^(UIButton * btn) {
        [weakSelf fetchCodeButtonAction:btn];
    };
}
/// 查看注册协议
- (void)pushToAgreementController {
    self.pushToAgreement = YES;
    [self .navigationController pushViewController:[AgreeViewController new] animated:YES];
}
/// 获取验证码
- (void)fetchCodeButtonAction:(UIButton *)button {
    if (!IsNormalMobileNum(self.regisView.mobile.text)) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入手机号");
        return;
    }
    if (button.selected) {
        return;
    }
    button.selected=YES;
    self.time = 60;
    [self timerActionToChange];
    weakify(self);
    [kRJHTTPClient getVerifyCodeWithPhone:self.regisView.mobile.text type:MobileCodeTypeRegis completion:^(WebResponse *response) {
        ShowAutoHideMBProgressHUD(weakSelf.view, response.message);
    }];
}

- (void)timerActionToChange {
    if (self.time <= 0) {
        self.regisView.mobile.codeBtn.selected = NO;
    } else {
        [self.regisView.mobile.codeBtn setTitle:[NSString stringWithFormat:@"%zds后重发",self.time--] forState:UIControlStateSelected];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timerActionToChange) object:nil];
        [self performSelector:@selector(timerActionToChange) withObject:nil afterDelay:1.0];
    }
}

/// 用户注册
- (void)userRegisAction {
    if (![self verifyUserInput]) {
        return;
    }
    if (!self.regisView.agreeBtn.selected) {
        ShowAutoHideMBProgressHUD(self.view, @"请阅读并同意《用户协议》");
        return;
    }
    [self resignTextInputFirstResponder];
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    self.clientDataTask = [kRJHTTPClient userRegisWithMobile:self.regisView.mobile.text verify:self.regisView.code.text invite:@"" pwd:self.regisView.pwd.text completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            SuccessMBProgressHUD(weakSelf.view, response.message);
//            [weakSelf regisJMessage];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)regisJMessage {
    [JMSGUser registerWithUsername:[NSString stringWithFormat:kRepairWord,@"21"] password:@"123456" completionHandler:^(id resultObject, NSError *error) {
        if (!error) {
            
        }
    }];
}


/**
 注册
 */
- (BOOL)verifyUserInput {
    if (IsStringEmptyOrNull(self.regisView.mobile.text)) {
        ShowAutoHideMBProgressHUD(self.view, self.regisView.mobile.placeholder);
        return NO;
    }
    if (IsStringEmptyOrNull(self.regisView.code.text)) {
        ShowAutoHideMBProgressHUD(self.view, self.regisView.code.placeholder);
        return NO;
    }
    if (IsStringEmptyOrNull(self.regisView.pwd.text)) {
        ShowAutoHideMBProgressHUD(self.view, self.regisView.pwd.placeholder);
        return NO;
    }
    return YES;
}

- (void)resignTextInputFirstResponder {
    [self.regisView endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (RegisContentView *)regisView {
    if (!_regisView) {
        _regisView = [[RegisContentView alloc] init];
//        [_regisView.codeBtn addTarget:self action:@selector(fetchCodeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _regisView;
}

#pragma mark - 键盘弹出及收起
- (void)keyboardWasShown:(NSNotification *)noti {
    //键盘高度
    CGFloat keyBoardHeight = [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.scrollView.contentSize = CGSizeMake(KScreenWidth, self.regisView.bottom + keyBoardHeight);
}

- (void)keyboardWillBeHidden:(NSNotification *)noti {
    self.scrollView.contentSize = CGSizeMake(KScreenWidth, self.regisView.bottom);
}

@end
