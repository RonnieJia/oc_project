// 提现明细

#import "RJBaseTableViewCell.h"
@class MoneyInfoModel;

NS_ASSUME_NONNULL_BEGIN

@interface CashInfoCell : RJBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *refundLabel;
@property (weak, nonatomic) IBOutlet UIView *refundView;
@property (weak, nonatomic) IBOutlet UILabel *dateL;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *moneyL;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *refundHeight;
@property (nonatomic, strong) MoneyInfoModel *infoModel;
@end

NS_ASSUME_NONNULL_END
