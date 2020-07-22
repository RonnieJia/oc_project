//

#import "RJBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MineCell : RJBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;


@property (nonatomic, strong) JMSGConversation *conversation;
@end

NS_ASSUME_NONNULL_END
