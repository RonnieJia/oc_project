// 绑定支付宝

#import "BaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BindZFBViewController : BaseTableViewController
@property(nonatomic, copy)void(^bindZFBSuccess)();
@property (nonatomic, assign) BOOL hadBind;

@end

NS_ASSUME_NONNULL_END
