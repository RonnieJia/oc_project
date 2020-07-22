#import "AppEntrance.h"
#import "RJTabBarController.h"
#import "RJNavigationController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "RJADLaunchView.h"

#import "RJMainRootViewController.h"
#import "CityListModel.h"

#import "RJUUID.h"
#import "RJGuideView.h"

@implementation AppEntrance

+ (void)setRootViewController {
    BOOL isFirstRun = !([[NSUserDefaults standardUserDefaults] boolForKey:kAppFirstRun]);
    if (isFirstRun) {
        [self setLoginForRoot];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAppFirstRun];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [RJGuideView show];
    } else {
        if (IsSaveUser()) {// 自动登录
            [CurrentUserInfo sharedInstance].userId = GetUserId();
            [AppEntrance setTabBarRoot];
            [CurrentUserInfo loginJMessage];
        } else {
            [self setLoginForRoot];
        }
        [RJADLaunchView showAD];
    }

}

+ (void)setTabBarRoot {
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.window.rootViewController = [[RJMainRootViewController alloc] init];
}
+ (void)setLoginForRoot {
    LoginViewController *login = [LoginViewController new];
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *vc = appdelegate.window.rootViewController;
    if (vc && [vc isKindOfClass:[UIViewController class]]) {
        vc = nil;
    }
    appdelegate.window.rootViewController = [[RJNavigationController alloc] initWithRootViewController:login];
}
@end
