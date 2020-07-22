
#import <UIKit/UIKit.h>
@class CYLTabBarController;
NS_ASSUME_NONNULL_BEGIN

@interface RJMainRootViewController : UINavigationController
+ (void)customizeInterfaceWithTabBarController:(CYLTabBarController *)tabBarController;
- (void)createNewTabBar;
@end

NS_ASSUME_NONNULL_END
