#import "LossPwdViewController.h"
#import "LossPasswordView.h"

@interface LossPwdViewController ()
@property(nonatomic, weak)UIScrollView *scrollView;
@property(nonatomic, strong)LossPasswordView *lossView;
@property(nonatomic, assign)NSInteger time;
@end

@implementation LossPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timerActionToChange) object:nil];
}

- (void)setupSubviews {
    self.view.backgroundColor = KTextWhiteColor;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, KScreenHeight)];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    scrollView.bounces = NO;
    [self setScrollViewAdjustsScrollViewInsets:self.scrollView];
    [scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(regisTF)]];
    [scrollView addSubview:self.lossView];
    scrollView.contentSize = CGSizeMake(KScreenWidth, self.lossView.bottom);
    weakify(self);
    self.lossView.code.codeBtnActionBlock = ^(UIButton * btn) {
        [weakSelf codeButtonAction:btn];
    };
    self.lossView.losspwdBlock = ^(NSInteger index) {
        strongify(weakSelf);
        if (index == 1) {
            [strongSelf.navigationController popViewControllerAnimated:YES];
        } else if(index == 3) {
            if (IsStringEmptyOrNull(strongSelf.lossView.mobile.text)) {
                ShowAutoHideMBProgressHUD(strongSelf.view, strongSelf.lossView.mobile.placeholder);
                return;
            }
            if (IsStringEmptyOrNull(strongSelf.lossView.code.text)) {
                ShowAutoHideMBProgressHUD(strongSelf.view, strongSelf.lossView.code.placeholder);
                return;
            }
            if (IsStringEmptyOrNull(strongSelf.lossView.pwd.text)) {
                ShowAutoHideMBProgressHUD(strongSelf.view, strongSelf.lossView.pwd.placeholder);
                return;
            }
//            if (IsStringEmptyOrNull(strongSelf.lossView.pwd2.text)) {
//                ShowAutoHideMBProgressHUD(strongSelf.view, strongSelf.lossView.pwd2.placeholder);
//                return;
//            }
            [strongSelf.view endEditing:YES];
            WaittingMBProgressHUD(strongSelf.view, @"");
            [kRJHTTPClient lossPwd:strongSelf.lossView.mobile.text code:strongSelf.lossView.code.text pwd:strongSelf.lossView.pwd.text completion:^(WebResponse *response) {
                FailedMBProgressHUD(strongSelf.view, response.message);
                if (response.code == WebResponseCodeSuccess) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [strongSelf.navigationController popViewControllerAnimated:YES];
                    });
                }
            }];
        }
    };
    
    self.lossView.mobile.codeBtnActionBlock = ^(UIButton * btn) {
        strongify(weakSelf);
        [strongSelf codeButtonAction:btn];
    };
    
    UIButton *backBtn = RJCreateImageButton(CGRectMake(0, StatusBarHeight, 44, 44), [UIImage imageNamed:kBackImgName], nil);
    [self.view addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)regisTF {
    [self.view endEditing:YES];
}

- (void)codeButtonAction:(UIButton *)sender {
    if (!sender.isSelected) {
        if (self.lossView.mobile.text.length == 0) {
            ShowAutoHideMBProgressHUD(self.view, @"请输入手机号");
            return;
        }
        if (!IsNormalMobileNum(self.lossView.mobile.text)) {
            ShowAutoHideMBProgressHUD(self.view, @"请输入正确的手机号");
            return;
        }
        sender.selected = YES;
        self.time = 60;
        [self timerActionToChange];
        self.clientDataTask = [kRJHTTPClient getVerifyCodeWithPhone:self.lossView.mobile.text type:MobileCodeTypeResetPwd completion:^(WebResponse *response) {
            
        }];
    }
}

- (void)timerActionToChange {
    if (self.time <= 0) {
        self.lossView.mobile.codeBtn.selected = NO;
    } else {
        [self.lossView.mobile.codeBtn setTitle:[NSString stringWithFormat:@"%zds后重发",self.time--] forState:UIControlStateSelected];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timerActionToChange) object:nil];
        [self performSelector:@selector(timerActionToChange) withObject:nil afterDelay:1.0];
    }
}

#pragma mark - 键盘弹出及收起
- (void)keyboardWasShown:(NSNotification *)noti {
    CGFloat keyHeight = FetchKeyBoardHeight(noti);
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.height = KScreenHeight-keyHeight;
        self.lossView.height = KAUTOSIZE(210)+405;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification *)noti {
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.height = KScreenHeight;
    }];
}


- (LossPasswordView *)lossView {
    if (!_lossView) {
        _lossView = [[LossPasswordView alloc] init];
    }
    return _lossView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
