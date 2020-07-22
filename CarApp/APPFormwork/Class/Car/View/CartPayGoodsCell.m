
#import "CartPayGoodsCell.h"
#import "CartModel.h"
#import "ShopChangeCountView.h"
#import "ShopGoodsModel.h"

@implementation CartPayGoodsCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *cellIndentifier = @"CartPayGoodsCell";
    CartPayGoodsCell *cell = (CartPayGoodsCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(nil == cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIndentifier owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.numView.addBtn addTarget:cell action:@selector(numChanged:) forControlEvents:UIControlEventTouchUpInside];
        [cell.numView.reduceBtn addTarget:cell action:@selector(numChanged:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}


- (void)numChanged:(UIButton *)btn {
    NSInteger num;
    if (self.buyNow) {
        if (btn == self.numView.addBtn) {
             num = self.numView.num+1;
        } else {
            if (self.numView.num>1) {
                num = self.numView.num-1;
            } else {
                return;
            }
        }
        self.numView.num = num;
        if (self.payChangeNumBlock) {
            self.payChangeNumBlock(num);
        }
        return;
    }
    if (btn == self.numView.addBtn) {
         num = self.model.num+1;
    } else {
        if (self.model.num>1) {
            num = self.model.num-1;
        } else {
            return;
        }
    }
    
    WaittingMBProgressHUD(KKeyWindow, @"");
    weakify(self);
    [kRJHTTPClient cartGoods:self.model.cart_id num:num completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            weakSelf.numView.num = num;
            weakSelf.model.num =num;
            if (weakSelf.payChangeNumBlock) {
                weakSelf.payChangeNumBlock(num);
            }
            FinishMBProgressHUD(KKeyWindow);
        } else {
            FailedMBProgressHUD(KKeyWindow, response.message);
        }
    }];
}
- (void)displsyBuy:(ShopGoodsModel *)goods sku:(SkuModel *)sku num:(NSInteger)num {
    self.buyNow = YES;
    self.nameLabel.text = goods.goods_name;
    [self.iconImgView rj_setImageWithPath:goods.picture placeholderImage:KDefaultImg];
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@",sku.sale_price];
    self.typeLabel.text = sku.sku_name;
    self.numView.num = num;
}
-(void)setModel:(CartModel *)model {
    _model = model;
    self.nameLabel.text = model.goods_name;
    [self.iconImgView rj_setImageWithPath:model.picture placeholderImage:KDefaultImg];
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@",model.sale_price];
    self.typeLabel.text = model.sku_name;
    self.numView.num = model.num;
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
