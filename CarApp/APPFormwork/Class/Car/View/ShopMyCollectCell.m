//
#import "ShopMyCollectCell.h"
#import "ShopGoodsModel.h"

@implementation ShopMyCollectCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *cellIndentifier = @"ShopMyCollectCell";
    ShopMyCollectCell *cell = (ShopMyCollectCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(nil == cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIndentifier owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.iconImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return cell;
}

- (void)setGoodsModel:(ShopGoodsModel *)goodsModel {
    _goodsModel = goodsModel;
    [self.iconImgView rj_setImageWithPath:goodsModel.pictures placeholderImage:KDefaultImg];
    self.namelabel.text = goodsModel.goods_name;
    self.typeLabel.text = goodsModel.category_name;
    NSString *price = goodsModel.price;
    NSString *sale_proce = goodsModel.sale_price;
    NSString *priceStr = [NSString stringWithFormat:@"￥%@ ￥%@",sale_proce,price];
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:priceStr];
    NSDictionary *lineDic = @{NSStrikethroughStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],NSFontAttributeName:kFont(12),NSForegroundColorAttributeName:KTextGrayColor};
    [att addAttributes:lineDic range:NSMakeRange(sale_proce.length+2, price.length+1)];
    [att addAttribute:NSForegroundColorAttributeName value:kTextRedColor range:NSMakeRange(0, sale_proce.length+1)];
    [att addAttribute:NSFontAttributeName value:kFont(12) range:NSMakeRange(0, 1)];
    self.priceLabel.attributedText = att;
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
