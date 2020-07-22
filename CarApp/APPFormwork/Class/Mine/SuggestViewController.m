//
#import "SuggestViewController.h"

@interface SuggestViewController ()<UITextViewDelegate,UITextFieldDelegate>
@property(nonatomic, weak)UILabel *placeLabel;
@property(nonatomic, weak)UITextView *contentTextView;
@property(nonatomic, weak)UITextField *mobileTF;
@property(nonatomic, weak)UIScrollView *scrollView;
@end

@implementation SuggestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"意见反馈";
    [self setBackButton];
    [self createMainView];
}

- (void)createMainView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KViewNavHeight)];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIView *inputView = RJCreateSimpleView(CGRectMake(10, 10, KScreenWidth-20, 250), KTextWhiteColor);
    [scrollView addSubview:inputView];
    inputView.layer.cornerRadius = 6;
    UILabel *placeL = RJCreateDefaultLable(CGRectMake(10, 13, inputView.width-20, 16), kFontWithSmallSize, KTextGrayColor, @"在这里留下你的意见吧~");
    [inputView addSubview:placeL];
    self.placeLabel = placeL;
    
    UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, inputView.width-10, inputView.height-10)];
    [inputView addSubview:tv];
    tv.backgroundColor = [UIColor clearColor];
    tv.font = kFontWithSmallSize;
    tv.textColor = KTextDarkColor;
    self.contentTextView = tv;
    tv.returnKeyType = UIReturnKeyDone;
    tv.delegate = self;
    
    UILabel *label = RJCreateDefaultLable(CGRectMake(0, 0, 80, 45), kFontWithSmallSize, KTextGrayColor, @"联系方式：");
    [label sizeToFit];
    label.width = label.width+10;
    label.textAlignment = NSTextAlignmentRight;
    UITextField *mobileTF = RJCreateTextField(CGRectMake(10, inputView.bottom+10, KScreenWidth-20, 45), kFontWithSmallSize, KTextDarkColor, KTextGrayColor, KTextWhiteColor, label, nil, NO, @"手机/邮箱（选填）", nil);
    [scrollView addSubview:mobileTF];
    mobileTF.layer.cornerRadius = 4;
    mobileTF.clipsToBounds=YES;
    mobileTF.returnKeyType = UIReturnKeyDone;
    mobileTF.delegate = self;
    self.mobileTF = mobileTF;
    
    UIButton *btn = RJCreateTextButton(CGRectMake(13, mobileTF.bottom+50, KScreenWidth-26, 44), kFontWithSmallSize, KTextWhiteColor, createImageWithColor(KThemeColor), @"确认提交");
    [scrollView addSubview:btn];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 22;
    btn.clipsToBounds=YES;
    [scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignINput)]];
    scrollView.contentSize = CGSizeMake(KScreenWidth, btn.bottom+30);
}

- (void)btnAction {
    if (IsStringEmptyOrNull(self.contentTextView.text)) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入你的意见~");
        return;
    }
    [self resignINput];
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient feedback:self.contentTextView.text mobile:self.mobileTF.text completion:^(WebResponse *response) {
        FailedMBProgressHUD(weakSelf.view, response.message);
        if (response.code == WebResponseCodeSuccess) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }
    }];
}

- (void)textViewDidChange:(UITextView *)textView {
    self.placeLabel.hidden = textView.text.length>0;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self resignINput];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self resignINput];
    return NO;
}

- (void)resignINput {
    [self.view endEditing:YES];
}


#pragma mark - 键盘弹出及收起
- (void)keyboardWasShown:(NSNotification *)noti {
    CGFloat keyboardHeight=FetchKeyBoardHeight(noti);
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.height = KViewNavHeight-keyboardHeight;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification *)noti {
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.height = KViewNavHeight;
    }];
}

@end
