//

#import "CashInfoCell.h"
#import "MoneyInfoModel.h"

@implementation CashInfoCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *cellIndentifier = @"CashInfoCell";
    CashInfoCell *cell = (CashInfoCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(nil == cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIndentifier owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
- (void)setInfoModel:(MoneyInfoModel *)infoModel {
    _infoModel = infoModel;
    if (infoModel.state == 2) {
        self.refundView.hidden = NO;
        self.refundHeight.constant = 40;
        self.refundLabel.text = [NSString stringWithFormat:@"拒绝原因:%@",infoModel.content];
    } else {
        self.refundView.hidden=YES;
        self.refundHeight.constant = 0;
    }
    [self.iconImgView rj_setImageWithPath:infoModel.picturs];
    self.titleL.text = [NSString stringWithFormat:@"提现%@元",infoModel.money];
    if (infoModel.state==2) {
        self.dateL.text = @"拒绝提现";
    } else if (infoModel.state == 0) {
        self.dateL.text = @"等待处理";
    } else {
        self.dateL.text = @"提现成功";
    }
//    self.dateL.text = infoModel.create_time;
    self.moneyL.text = infoModel.create_time;//[NSString stringWithFormat:@"-%@",infoModel.money];
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
