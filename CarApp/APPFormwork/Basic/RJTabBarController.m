#import "RJTabBarController.h"
#import "AppDelegate.h"
#import "HomeViewController.h"
#import "MineViewController.h"
#import "RJNavigationController.h"
#import "RJTabBar.h"

#define kTableBarFontSize                       [UIFont systemFontOfSize:10.0]
#define kTabBarTitleNormalColor                 [UIColor lightGrayColor]
#define kTabBarTitleSelectColor                 [UIColor blackColor]

@interface RJTabBarController ()<RJTabBarDelegate,UITabBarControllerDelegate>

@end

@implementation RJTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

+ (RJTabBarController *)curTabbarController{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    RJTabBarController* tabControl = (RJTabBarController*)appDelegate.window.rootViewController;
    
    return tabControl;
    
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.delegate = self;
    
    [self addChildViewController:[[HomeViewController alloc] init] title:@"首页" image:@"buticon010" selectImage:@"buticon011"];
    [self addChildViewController:[[MineViewController alloc] init] title:@"我的" image:@"buticon040" selectImage:@"bottomicon040"];
    
    RJTabBar *tabBar = [[RJTabBar alloc] init];
    tabBar.RJdelegate = self;
    [self setValue:tabBar forKey:@"tabBar"];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
//    if (![CurrentUserInfo sharedInstance].isLogin) {
//        RJNavigationController *nav = (RJNavigationController *)viewController;
//        if ([nav.viewControllers.firstObject isKindOfClass:[MineViewController class]]) {
//            ShowLogin(tabBarController);
//            return NO;
//        }
//    }
    return YES;
}

- (void)addChildViewController:(UIViewController *)childVC title:(NSString *)title image:(NSString *)norImage selectImage:(NSString *)selectImage {
    childVC.tabBarItem.image = [[UIImage imageNamed:norImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [childVC.tabBarItem setTitle:title];
    childVC.tabBarItem.selectedImage = [[UIImage imageNamed:selectImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [childVC.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:@"#656565"], NSFontAttributeName:[UIFont systemFontOfSize:12.0]} forState:UIControlStateNormal];
    [childVC.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:@"#14b5f9"], NSFontAttributeName:[UIFont systemFontOfSize:12.0]} forState:UIControlStateSelected];
    UINavigationController *nav = [[RJNavigationController alloc] initWithRootViewController:childVC];
    [self addChildViewController:nav];
}

#pragma mark - live button delegate
- (void)tabBarDidClickPlusButton:(RJTabBar *)tabBar {
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self becomeFirstResponder];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [self becomeFirstResponder];
    [super viewDidAppear:animated];
}

@end
