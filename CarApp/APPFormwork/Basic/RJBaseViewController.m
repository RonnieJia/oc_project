#import "RJBaseViewController.h"

@interface RJBaseViewController ()
@property (nonatomic, copy)NavBarItemAction leftAction;
@property (nonatomic, copy)NavBarItemAction rightAction;

@property (nonatomic, copy)NavBarMoreAction rightMoreAction;
@property (nonatomic, copy)NavBarMoreAction leftMoreAction;

@end

@implementation RJBaseViewController
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"NavgationBarHide" ofType:@"plist"];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    NSString *classString = NSStringFromClass(self.class);
    if ([array containsObject:classString]) {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resignTextInputFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //注册键盘出现的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    //注册键盘消失的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.clientDataTask && self.clientDataTask.state == NSURLSessionTaskStateRunning) {
        [self.clientDataTask cancel];
        self.clientDataTask = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kViewControllerBgColor;
    
//    self.navigationItem.hidesBackButton = YES;
}

- (void)setNavBarBtnWithType:(NavBarType)type title:(NSString *)title action:(NavBarItemAction)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 60, 44);
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:KTextWhiteColor forState:UIControlStateNormal];
    btn.titleLabel.font = kFontWithSmallestSize;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -15;
    if (type == NavBarTypeLeft) {
        [btn addTarget:self action:@selector(leftNavBarItemAction:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItems = @[negativeSpacer, item];
        self.leftAction = [action copy];
    } else {
        [btn addTarget:self action:@selector(rightNavBarItemAction:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItems = @[negativeSpacer,item];
        self.rightAction = [action copy];
        self.rightNavBtn = btn;
    }
}

- (void)setNavBarBtnWithType:(NavBarType)type  norImg:(UIImage *)norImg selImg:(UIImage *)selImg action:(NavBarItemAction)action {
    [self setNavBarBtnWithType:type width:60 norImg:norImg selImg:selImg action:action];

}

- (void)setNavBarBtnWithType:(NavBarType)type width:(CGFloat)width norImg:(UIImage *)norImg selImg:(UIImage *)selImg action:(NavBarItemAction)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, width, 44);
    btn.backgroundColor = [UIColor clearColor];
    if (norImg) {
        [btn setImage:norImg forState:UIControlStateNormal];
    }
    if (selImg) {
        [btn setImage:selImg forState:UIControlStateHighlighted];
    }
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -15;
    if (type == NavBarTypeLeft) {
        [btn addTarget:selImg action:@selector(leftNavBarItemAction:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItems = @[negativeSpacer, item];
        self.leftAction = [action copy];
    } else {
        [btn addTarget:self action:@selector(rightNavBarItemAction:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItems = @[negativeSpacer,item];
        self.rightAction = [action copy];
    }
    
}


- (void)setNavBarBtnWithType:(NavBarType)type norImgs:(NSArray *)norImg action:(NavBarMoreAction)action {
    NSMutableArray *temp = [NSMutableArray array];
    int i = 100;
    for (UIImage *img in norImg) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 30, 44);
        btn.backgroundColor = [UIColor clearColor];
        btn.tag = i;
        i++;
        if (img) {
            [btn setImage:img forState:UIControlStateNormal];
        }
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
        [temp addObject:item];
        if (type == NavBarTypeLeft) {
            [btn addTarget:self action:@selector(leftNavBarItemAction:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [btn addTarget:self action:@selector(rightNavBarItemAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -15;
    [temp insertObject:negativeSpacer atIndex:0];
    if (type == NavBarTypeLeft) {
        self.navigationItem.leftBarButtonItems = temp;
        self.leftMoreAction = [action copy];
    } else {
        self.navigationItem.rightBarButtonItems = temp;
        self.rightMoreAction = [action copy];
    }
    
}
- (void)setScrollViewAdjustsScrollViewInsets:(UIScrollView *)scrollView {
    if (scrollView) {
#ifdef __IPHONE_11_0
        if ([scrollView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
            scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
#endif
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)leftNavBarItemAction:(UIButton *)button {
    if (button.tag >= 100) {
        if (self.leftMoreAction) {
            self.leftMoreAction(button.tag - 100, button);
        }
    } else {
        if (self.leftAction) {
            self.leftAction();
        }
    }
}
- (void)rightNavBarItemAction:(UIButton *)button {
    if (button.tag >= 100) {
        if (self.rightMoreAction) {
            self.rightMoreAction(button.tag-100, button);
        }
    } else {
    if (self.rightAction) {
        self.rightAction();
    }
    }
}

- (void)setTitle:(NSString *)title {
    if (title) {
        UILabel *titleLab = [UILabel labelWithFrame:CGRectMake(0, 0, 160, 44) textColor:kNavTitleColor font:kFontWithBigSize textAlignment:NSTextAlignmentCenter text:title];
        self.navigationItem.titleView = titleLab;
        titleLab = nil;
    }
}

- (void)setPopBackLeft {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:kBackImgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(popBackLeftItemAction)];
}

- (void)popBackLeftItemAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)setBackButton {
    return;
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    back.frame = CGRectMake(0, 0,44, 44);
    [back setImage:[UIImage imageNamed:kBackImgName] forState:UIControlStateNormal];
//    [back setTitle:@"" forState:UIControlStateNormal];
    [back setTitleColor:kRGBColor(138, 138, 138) forState:UIControlStateNormal];
    back.titleLabel.font = kFontWithSmallSize;
//    back.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    back.contentHorizontalAlignment = 1;
    [back addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [back addTarget:self action:@selector(backBtnCancelHighlight:) forControlEvents:UIControlEventAllEvents];
//    [self.navigationController.navigationBar addSubview:back];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]
                                 initWithCustomView:back];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];

    negativeSpacer.width = -15;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,backItem];
     
}

- (void)backBtnCancelHighlight:(UIButton *)btn {
    btn.highlighted = NO;
}

- (void)tableView:(UITableView *)tableView footerCount:(NSInteger)count height:(CGFloat)height {
    if (count == 0) {
        RJNullView *null = [[RJNullView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, height)];
        tableView.tableFooterView = null;
    } else {
        tableView.tableFooterView = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 0), nil);
    }
}

#pragma mark - 键盘弹出及收起
- (void)keyboardWasShown:(NSNotification *)noti {
}

- (void)keyboardWillBeHidden:(NSNotification *)noti {
}

#pragma mark - 隐藏弹出的键盘
- (void)resignTextInputFirstResponder {
    [self.view endEditing:YES];
}

- (void)backBtnAction {
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)tableView:(UITableView *)tableview footerView:(BOOL)empty height:(CGFloat)height {
    if (empty) {
        self.nullView.height = height;
        tableview.tableFooterView = self.nullView;
    } else {
        tableview.tableFooterView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kIPhoneXBH)];
    }
}

- (RJNullView *)nullView {
    if (!_nullView) {
        _nullView = [[RJNullView alloc] initWithFrame:self.view.bounds];
    }
    return _nullView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
