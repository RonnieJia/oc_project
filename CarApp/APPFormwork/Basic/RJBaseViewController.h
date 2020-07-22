#import <UIKit/UIKit.h>
#import "RJNullView.h"
typedef void(^NavBarItemAction)();
typedef void(^NavBarMoreAction)(NSInteger index, UIButton *btn);

@interface RJBaseViewController : UIViewController
@property (nonatomic, strong)NSURLSessionDataTask *clientDataTask;
@property(nonatomic,weak)UIButton *rightNavBtn;

- (void)tableView:(UITableView *)tableView footerCount:(NSInteger)count height:(CGFloat)height;
- (void)setNavBarBtnWithType:(NavBarType)type title:(NSString *)title action:(NavBarItemAction)action;
- (void)setNavBarBtnWithType:(NavBarType)type norImg:(UIImage *)norImg selImg:(UIImage *)selImg action:(NavBarItemAction)action;
- (void)setNavBarBtnWithType:(NavBarType)type width:(CGFloat)width norImg:(UIImage *)norImg selImg:(UIImage *)selImg action:(NavBarItemAction)action;
- (void)setNavBarBtnWithType:(NavBarType)type norImgs:(NSArray *)norImg action:(NavBarMoreAction)action;

- (void)setScrollViewAdjustsScrollViewInsets:(UIScrollView *)scrollView;

- (void)setBackButton;
- (void)backBtnAction;
- (void)setPopBackLeft;

-(void)tableView:(UITableView *)tableview footerView:(BOOL)empty height:(CGFloat)height;
@property(nonatomic, strong)RJNullView *nullView;
@end
