//

#import "ShopCartCell.h"
#import "CartModel.h"
#import "ShopChangeCountView.h"

@implementation ShopCartCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *cellIndentifier = @"ShopCartCell";
    ShopCartCell *cell = (ShopCartCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(nil == cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIndentifier owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.iconImgView.contentMode=UIViewContentModeScaleToFill;
        [cell.cartNumView.addBtn addTarget:cell action:@selector(numChanged:) forControlEvents:UIControlEventTouchUpInside];
        [cell.cartNumView.reduceBtn addTarget:cell action:@selector(numChanged:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (void)numChanged:(UIButton *)btn {
    NSInteger num;
    if (btn == self.cartNumView.addBtn) {
         num = self.cartModel.num+1;
    } else {
        if (self.cartModel.num>1) {
            num = self.cartModel.num-1;
        } else {
            return;
        }
    }
    WaittingMBProgressHUD(KKeyWindow, @"");
    weakify(self);
    [kRJHTTPClient cartGoods:self.cartModel.cart_id num:num completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            weakSelf.cartModel.num = num;
            weakSelf.cartNumView.num =num;
            if (weakSelf.cartModel.choose && weakSelf.cartNumChangeBlock) {
                weakSelf.cartNumChangeBlock(YES);
            }
            FinishMBProgressHUD(KKeyWindow);
        } else {
            FailedMBProgressHUD(KKeyWindow, response.message);
        }
    }];
}

- (void)setCartModel:(CartModel *)cartModel {
    _cartModel = cartModel;
    [self.iconImgView rj_setImageWithPath:cartModel.goods_picture placeholderImage:KDefaultImg];
    self.nameLabel.text = cartModel.goods_name;
    self.priceLabel.text = [NSString stringWithFormat:@"%@",cartModel.price];
    self.typeLabel.text=cartModel.sku_name;
    self.chooseBtn.selected = cartModel.choose;
    self.cartNumView.num = cartModel.num;//[NSString stringWithFormat:@"%zd",cartModel.num];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)chooseCartGoods:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    self.cartModel.choose = sender.selected;
    if (self.cartItemChooseBlock) {
        self.cartItemChooseBlock(sender.selected);
    }
}

@end
