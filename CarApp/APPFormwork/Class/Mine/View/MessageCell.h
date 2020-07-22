
#import "RJBaseTableViewCell.h"
@class MessageModel;

NS_ASSUME_NONNULL_BEGIN

@interface MessageCell : RJBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *contentL;
@property (weak, nonatomic) IBOutlet UIView *flagView;
@property (weak, nonatomic) IBOutlet UILabel *dateL;
@property (nonatomic, strong) MessageModel *msgModel;
@end

NS_ASSUME_NONNULL_END
