

#import "RJNavigationController.h"

#define kImgNavbarBackItem                [UIImage imageNamed:@"BackItem.png"]

@interface RJNavigationController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>
@property(nonatomic,weak) UIViewController* currentShowVC;

@end

@implementation RJNavigationController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 去掉底部阴影条
    if ([UINavigationBar instancesRespondToSelector:@selector(setShadowImage:)]) {// > iOS 6.0
        [self.navigationBar setShadowImage:createImageWithColor([UIColor clearColor])];
    }
    
    //设置背景
    if (kNavBarShowBGImg) {
        [self.navigationBar setBackgroundImage:[UIImage imageNamed:kNavBarBackgroundImg] forBarMetrics:UIBarMetricsDefault];
    } else {
        UIColor* color = kNavBarBgColo;
        self.navigationBar.barTintColor = color;
        self.navigationBar.backgroundColor = color;
    }
    self.navigationBar.translucent = NO;//    Bar的模糊效果
    
    //设置返回按钮颜色
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    
    
    NSDictionary *titleAtt = @{NSForegroundColorAttributeName: kNavTitleColor,
                               NSFontAttributeName:[UIFont systemFontOfSize:20]};
    [self.navigationBar setTitleTextAttributes:titleAtt];

    //支持滑动返回
    self.interactivePopGestureRecognizer.delegate = self;
    self.delegate = self;
    
    // 自定义返回图片(在返回按钮旁边) 这个效果由navigationBar控制
    [self.navigationBar setBackIndicatorImage:[UIImage imageNamed:kBackImgName]];
    [self.navigationBar setBackIndicatorTransitionMaskImage:[UIImage imageNamed:kBackImgName]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count >= 1) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
    viewController.navigationItem.backBarButtonItem = item;
    [super pushViewController:viewController animated:animated];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    
    if (navigationController.viewControllers.count == 1)
        self.currentShowVC = Nil;
    else
        self.currentShowVC = viewController;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //在根视图不响应手势，避免和侧滑产生冲突
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        return (self.currentShowVC == self.topViewController);
    }
    return YES;
}

@end

#pragma mark - Inline Functions

inline UIButton *FMNavBarBackButtonWithTargetAndAntion(id target, SEL action)
{
    if (target == nil && action == nil)
        return nil;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.bounds = CGRectMake(0, 0, 55.00, 44.00);
    [backBtn setImage:kImgNavbarBackItem forState:UIControlStateNormal];
    [backBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return backBtn;
}
