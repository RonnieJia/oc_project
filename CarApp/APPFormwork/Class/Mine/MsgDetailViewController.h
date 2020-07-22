//

#import "BaseTableViewController.h"
@class MessageModel;

NS_ASSUME_NONNULL_BEGIN

@interface MsgDetailViewController : BaseTableViewController
@property (weak, nonatomic) IBOutlet UILabel *dateL;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *contentL;
@property (nonatomic, strong) MessageModel *msgModel;
@end

NS_ASSUME_NONNULL_END
