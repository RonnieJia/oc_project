
#import <UIKit/UIKit.h>
#if defined __cplusplus
extern "C" {
#endif
    
    //自定义的返回按钮
    extern inline UIButton *FMNavBarBackButtonWithTargetAndAntion(id target, SEL action);
    
#if defined __cplusplus
};
#endif


@interface RJNavigationController : UINavigationController

@end
