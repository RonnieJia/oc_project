//

#import "IncomeInfoCell.h"
#import "MoneyInfoModel.h"

@implementation IncomeInfoCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *cellIndentifier = @"IncomeInfoCell";
    IncomeInfoCell *cell = (IncomeInfoCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(nil == cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIndentifier owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)setModel:(MoneyInfoModel *)model {
    _model = model;
    [self.iconImgView rj_setImageWithPath:model.picturs placeholderImage:KDefaultImg];
    self.nameLabel.text = model.describe;
    self.moneyLabel.text = model.name;
    NSString *payType = @"支付宝支付";
    if (model.pay_type==2) {
        payType = @"微信支付";
    } else if (model.pay_type==3) {
        payType = @"现金支付";
    }
    self.dateLabel.text = [NSString stringWithFormat:@"%@ | %@",payType,model.create_time];
    self.monLabel.text = [NSString stringWithFormat:@"%@%@",model.sign==2?@"-":@"+", model.money];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
