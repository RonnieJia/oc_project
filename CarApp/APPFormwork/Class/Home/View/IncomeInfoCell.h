// 收入明细

#import "RJBaseTableViewCell.h"
@class MoneyInfoModel;

NS_ASSUME_NONNULL_BEGIN

@interface IncomeInfoCell : RJBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *monLabel;
@property (nonatomic, strong) MoneyInfoModel *model;
@end

NS_ASSUME_NONNULL_END
