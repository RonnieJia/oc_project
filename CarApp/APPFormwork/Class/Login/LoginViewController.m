#import "LoginViewController.h"
#import "AppEntrance.h"
#import "RegisViewController.h"
#import "RJNavigationController.h"
#import "LossPwdViewController.h"
//#import <AlibabaAuthSDK/ALBBSDK.h>
#import "WXApi.h"
#import <UMShare/UMShare.h>

#import "CityListViewController.h"
#import "LoginViews.h"
#import "RJUUID.h"
#import "Masonry.h"
#import "AgreeViewController.h"

static NSInteger const kLossBtnTag  = 100;
static NSInteger const kLoginBtnTag = 101;
static NSInteger const kRegisBtnTag = 102;

@interface LoginViewController ()<UITextFieldDelegate>
@property(nonatomic, weak)UIScrollView *scrollView;
@property(nonatomic, assign)NSInteger time;
@property(nonatomic, assign)BOOL pushToAgreement;
@property(nonatomic, strong)LoginViews *loginView;
@property(nonatomic, weak)UIButton *agreeBtn;
@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.pushToAgreement=NO;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    if (!self.pushToAgreement) {
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timerActionToChange) object:nil];
//    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resignTextInputFirstResponder];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeMainView];
}

- (void)makeMainView {
    self.view.backgroundColor = KTextWhiteColor;
    UIScrollView *mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    [self.view addSubview:mainScrollView];
    mainScrollView.bounces = NO;
    self.scrollView = mainScrollView;
    mainScrollView.backgroundColor = [UIColor clearColor];
    [mainScrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignTextInputFirstResponder)]];
    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [mainScrollView addSubview:self.loginView];
    weakify(self);
    self.loginView.loginBlock = ^(NSInteger index) {
        strongify(weakSelf);
        if (index == 1) {
            [strongSelf.navigationController pushViewController:[RegisViewController new] animated:YES];
        } else if(index == 2) {//记住密码
            [strongSelf.navigationController pushViewController:[LossPwdViewController new] animated:YES];
        } else if (index == 3) {
            [weakSelf userLogin];
        } else if (index == 4) {
            [AppEntrance setTabBarRoot];
        }
    };
    self.scrollView.contentSize=CGSizeMake(KScreenWidth, self.loginView.height);
    
    
    UIView *agreementView = RJCreateSimpleView(CGRectZero, KTextWhiteColor);
    [self.view addSubview:agreementView];
    [agreementView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-kIPhoneXBH);
        make.height.mas_equalTo(30);
    }];
    
    
    UIButton *btn = RJCreateImageButton(CGRectZero, [UIImage imageNamed:@"block001"], [UIImage imageNamed:@"block002"]);
    [agreementView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.and.height.mas_equalTo(12);
        make.centerY.equalTo(agreementView);
    }];
    btn.selected=YES;
    self.agreeBtn = btn;
    [btn addTarget:self action:@selector(agreeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label = RJCreateDefaultLable(CGRectZero, kFontWithSmallestSize, KTextGrayColor, @"同意并接受");
    [agreementView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(btn.mas_right).offset(5);
        make.centerY.equalTo(agreementView);
    }];
    UIButton *btn2 = RJCreateTextButton(CGRectZero, kFontWithSmallestSize, KTextGrayColor, nil, @"《用户服务协议》");
    [agreementView addSubview:btn2];
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label.mas_right);
        make.centerY.equalTo(agreementView);
    }];
    UILabel *label2 = RJCreateDefaultLable(CGRectZero, kFontWithSmallestSize, KTextGrayColor, @"和");
    [agreementView addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(btn2.mas_right);
        make.centerY.equalTo(agreementView);
    }];
    UIButton *btn3 = RJCreateTextButton(CGRectZero, kFontWithSmallestSize, KTextGrayColor, nil, @"《隐私政策》");
    [agreementView addSubview:btn3];
    [btn3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label2.mas_right);
        make.centerY.equalTo(agreementView);
        make.right.mas_equalTo(0);
    }];
    btn3.tag = 101;
    [btn3 addTarget:self action:@selector(pushToAgreementController:) forControlEvents:UIControlEventTouchUpInside];
    [btn2 addTarget:self action:@selector(pushToAgreementController:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)pushToAgreementController:(UIButton *)btn {
    self.pushToAgreement = YES;
    AgreeViewController *agree = [AgreeViewController new];
    if (btn.tag==101) {
        agree.yinsi = YES;
    }
    [self .navigationController pushViewController:agree animated:YES];
}

- (void)alibbLogin {
    /*
    ALBBSDK *albbSDK = [ALBBSDK sharedInstance];
    [albbSDK setAppkey:kAliKey];
    [albbSDK setAuthOption:NormalAuth];
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [albbSDK auth:self successCallback:^(ALBBSession *session) {
        NSLog(@"%@",session.bindCode);
        ALBBUser *user = [session getUser];
        [weakSelf tbLogin:user.openId nick:user.nick head:user.avatarUrl];
        FinishMBProgressHUD(weakSelf.view);
    } failureCallback:^(ALBBSession *session, NSError *error) {
        if (session.isCanceledByUser) {
            FinishMBProgressHUD(weakSelf.view);
        } else {
        FailedMBProgressHUD(weakSelf.view, @"获取淘宝授权失败");
        }
    }];*/
}

- (void)wechatLogin {
    if ([WXApi isWXAppInstalled]) {
        weakify(self);
        WaittingMBProgressHUD(self.view, @"");
        [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_WechatSession currentViewController:nil completion:^(id result, NSError *error) {
            if (error) {
                FailedMBProgressHUD(weakSelf.view, @"获取微信授权失败");
            } else {
                UMSocialUserInfoResponse *resp = result;
                [weakSelf wechatLogin:resp.openid nick:resp.name head:resp.iconurl];
            }
        }];
    } else {
        ShowAutoHideMBProgressHUD(self.view, @"获取微信授权失败（未安装）");
    }
}
- (void)wechatLogin:(NSString *)openid nick:(NSString *)nick head:(NSString *)head {
    weakify(self);
//    self.clientDataTask = [kRJHTTPClient userLoginType:0 openid:openid name:nick imei:[RJUUID getUUID] completion:^(WebResponse *response) {
//        if (response.code == WebResponseCodeSuccess) {
//            [AppEntrance setTabBarRoot];
//            FinishMBProgressHUD(weakSelf.view);
//        } else {
//            FailedMBProgressHUD(weakSelf.view, response.message);
//        }
//    }];
}

- (void)tbLogin:(NSString *)openid nick:(NSString *)nick head:(NSString *)head {
    weakify(self);
    /*
    self.clientDataTask = [kRJHTTPClient tbLogin:openid nick:nick headerpic:head completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            NSDictionary *dic = response.responseObject;
            if ([dic.allKeys containsObject:@"status"] && IntForKeyInUnserializedJSONDic(dic, @"status")==0) {
                ChangeMobileViewController *mobile = [ChangeMobileViewController new];
                mobile.bind = YES;
                NSString *uid = StringForKeyInUnserializedJSONDic(response.responseObject, @"userId");
                mobile.uid = uid;
                mobile.bindMobileBlock = ^(NSString *mobile) {
                    NSMutableDictionary *resultDic = [@{} mutableCopy];
                    AddObjectForKeyIntoDictionary(head, @"head_pic", resultDic);
                    AddObjectForKeyIntoDictionary(nick, @"nickname", resultDic);
                    AddObjectForKeyIntoDictionary(uid, @"userId", resultDic);
                    AddObjectForKeyIntoDictionary(mobile, mobile, resultDic);
                    
                    SaveUserInfo(resultDic);
                    [CurrentUserInfo userLogin:resultDic];
                    SaveUser(@"third", openid, [CurrentUserInfo sharedInstance].userId);
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                };
                [weakSelf.navigationController pushViewController:mobile animated:YES];
            } else {
                NSDictionary *result = ObjForKeyInUnserializedJSONDic(response.responseObject, @"result");
                if (result && [result isKindOfClass:[NSDictionary class]]) {
                    
                    SaveUserInfo(result);
                    [CurrentUserInfo userLogin:result];
                    SaveUser(@"third", openid, [CurrentUserInfo sharedInstance].userId);
                }
                [CurrentUserInfo sharedInstance].head_pic = head;
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
     */
}


- (void)resignTextInputFirstResponder {
    [self.view endEditing:YES];
}


#pragma mark - 键盘弹出及收起
- (void)keyboardWasShown:(NSNotification *)noti {
    CGFloat keyHeight = FetchKeyBoardHeight(noti);
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.height = KScreenHeight-keyHeight;
        self.loginView.height = KAUTOSIZE(210)+400;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification *)noti {
//    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.height = KScreenHeight;
//    }];
    
}

- (void)agreeBtnAction:(UIButton *)btn {
    btn.selected = !btn.selected;
}

/// 登录
- (void)userLogin {
//    [CurrentUserInfo sharedInstance].userId = @"2";
//    [AppEntrance setTabBarRoot];
//    return;
//    self.loadView.use
    if (IsStringEmptyOrNull(self.loginView.userName.text)) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入手机号");
        return;
    }
    if (IsStringEmptyOrNull(self.loginView.pwd.text)) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入手机号");
        return;
    }
    if (!self.agreeBtn.selected) {
        ShowAutoHideMBProgressHUD(self.view, @"请同意接受《用户服务协议》和《隐私政策》");
        return;
    }
    weakify(self);
    [self resignTextInputFirstResponder];
    WaittingMBProgressHUD(self.view, @"");
    [kRJHTTPClient userLogin:self.loginView.userName.text pwd:self.loginView.pwd.text completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            // 本地保存用户
            ClearUser();
            SaveUser(weakSelf.loginView.userName.text, weakSelf.loginView.pwd.text, [CurrentUserInfo sharedInstance].userId);
            [AppEntrance setTabBarRoot];
            FinishMBProgressHUD(weakSelf.view);
            [CurrentUserInfo loginJMessage];
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (LoginViews *)loginView{
    if (!_loginView) {
        _loginView = [[LoginViews alloc] init];
    }
    return _loginView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
