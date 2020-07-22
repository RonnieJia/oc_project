

#import "ShopOderCell.h"
#import "ShopOrderListModel.h"

@implementation ShopOderCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *cellIndentifier = @"ShopOderCell";
    ShopOderCell *cell = (ShopOderCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(nil == cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIndentifier owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.containerView.layer.borderColor = KSepLineColor.CGColor;
        cell.containerView.layer.borderWidth=1.0;
        cell.containerView.layer.shadowColor = KTextDarkColor.CGColor;
        // 阴影偏移，默认(0, -3)
        cell.containerView.layer.shadowOffset = CGSizeMake(0,3);
        // 阴影透明度，默认0
        cell.containerView.layer.shadowOpacity = 0.3;
        // 阴影半径，默认3
        cell.containerView.layer.shadowRadius = 2;
    }
    return cell;
}

- (void)setOrderModel:(ShopOrderModel *)orderModel {
    _orderModel = orderModel;
    self.nameLabel.text = orderModel.goods_name;
    [self.iconImgView rj_setImageWithPath:orderModel.goods_picture placeholderImage:KDefaultImg];
//    self.nameLabel.text = orderModel.
    self.typeLabel.text = orderModel.sku_name;
    self.countLabel.text = [NSString stringWithFormat:@"x%zd",orderModel.num];
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@",orderModel.price];
    NSString *total = [NSString stringWithFormat:@"共计%zd件商品，合计￥%@",orderModel.num,orderModel.total_price];
    NSMutableAttributedString *att= [[NSMutableAttributedString alloc] initWithString:total];
    [att addAttribute:NSForegroundColorAttributeName value:kTextRedColor range:NSMakeRange(total.length-1-orderModel.total_price.length, orderModel.total_price.length+1)];
    self.moneyLabel.attributedText = att;
    self.state = orderModel.orderStates;
}
- (IBAction)buttonClickAction:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"申请退款"]) {
        if (self.shopOrderCellBlock) {
            self.shopOrderCellBlock(0, self.state, self.orderModel);
        }
        return;
    }
    if (self.state == ShopOrderStateDispatchin) {
        if (sender == self.rightBtn) {// 确认收货
            if (self.shopOrderCellBlock) {
                self.shopOrderCellBlock(1, self.state, self.orderModel);
            }
        }
    }
}

- (void)setState:(ShopOrderState)state {
    _state = state;
    self.leftBtn.hidden=self.rightBtn.hidden=YES;
    self.stateLabel.hidden=YES;
    switch (state) {
        case ShopOrderStateWait:
        {
            self.lBtnWidthConstraint.constant = 0;
            self.rBtnWidthConstraint.constant = 0;
        }
            break;
        case ShopOrderStatePayed:
        {
            self.lBtnWidthConstraint.constant = 0;
            self.rBtnWidthConstraint.constant = 70;
            self.rightBtn.hidden=NO;
            self.rightBtn.backgroundColor = KTextWhiteColor;
            self.rightBtn.layer.borderColor = KSepLineColor.CGColor;
            self.rightBtn.layer.borderWidth=1;
            [self.rightBtn setTitleColor:KTextGrayColor forState:UIControlStateNormal];
            [self.rightBtn setTitle:self.orderModel.refund_status==3?@"拒绝退款":@"申请退款" forState:UIControlStateNormal];
        }
            break;
        case ShopOrderStateDispatchin:
        {
            self.lBtnWidthConstraint.constant = 70;
            self.rBtnWidthConstraint.constant = 70;
            self.leftBtn.hidden=self.rightBtn.hidden = NO;
            self.leftBtn.backgroundColor = KTextWhiteColor;
            self.leftBtn.layer.borderColor = KSepLineColor.CGColor;
            self.leftBtn.layer.borderWidth=1;
            [self.leftBtn setTitleColor:KTextGrayColor forState:UIControlStateNormal];
            [self.leftBtn setTitle:self.orderModel.refund_status==3?@"拒绝退款":@"申请退款" forState:UIControlStateNormal];
            self.rightBtn.layer.borderWidth=0;
            self.rightBtn.backgroundColor = KThemeColor;
            [self.rightBtn setTitleColor:KTextWhiteColor forState:UIControlStateNormal];
            [self.rightBtn setTitle:@"确认收货" forState:UIControlStateNormal];
        }
            
            break;
        case ShopOrderStateFinished:
        {
            self.lBtnWidthConstraint.constant = 0;
            self.rBtnWidthConstraint.constant = 70;
            self.rightBtn.hidden=NO;
            self.rightBtn.backgroundColor = KTextWhiteColor;
            self.rightBtn.layer.borderColor = KSepLineColor.CGColor;
            self.rightBtn.layer.borderWidth=1;
            [self.rightBtn setTitleColor:KTextGrayColor forState:UIControlStateNormal];
            [self.rightBtn setTitle:self.orderModel.refund_status==3?@"拒绝退款":@"申请退款" forState:UIControlStateNormal];
        }
            break;
        case ShopOrderStateReturn:
        {
            self.stateLabel.hidden=NO;
            if (self.orderModel.refund_status==1) {
                self.stateLabel.text=@"申请退款";
            } else if (self.orderModel.refund_status==2) {
                self.stateLabel.text=@"已退款";
            } else if (self.orderModel.refund_status == 3) {
                self.stateLabel.text=@"拒绝退款";
            }
            self.lBtnWidthConstraint.constant = 0;
            self.rBtnWidthConstraint.constant = 0;
        }
            break;
            
        default:
            break;
    }
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
