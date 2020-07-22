
#import <UIKit/UIKit.h>

@interface RJNullView : UIView
+ (void)showInView:(UIView *)view frame:(CGRect)frame;
+ (void)hideInView:(UIView *)view;
/**
 在某个视图上显示，且覆盖
 */
+ (void)showInView:(UIView *)view;

+ (void)tableView:(UITableView *)tableView footerSize:(CGSize)size;
@end
