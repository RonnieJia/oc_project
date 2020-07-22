

#import "GoodsListTableCell.h"
#import "ShopGoodsModel.h"

@implementation GoodsListTableCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *cellIndentifier = @"GoodsListTableCell";
    GoodsListTableCell *cell = (GoodsListTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(nil == cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIndentifier owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.containerView.layer.borderColor = KSepLineColor.CGColor;
        cell.containerView.layer.borderWidth=1.0;
        cell.containerView.layer.cornerRadius = 6;
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

- (void)setGoodsModel:(ShopGoodsModel *)goodsModel {
    _goodsModel = goodsModel;
    [self.iconImgView rj_setImageWithPath:goodsModel.picture placeholderImage:KDefaultImg];
    self.nameLabel.text = goodsModel.goods_name;
    self.cateNameLabel.text = goodsModel.category_name;
    NSString *price = [NSString stringWithFormat:@"￥%@",goodsModel.price];
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:price attributes:@{NSStrikethroughStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleSingle]}];
    self.priceLabel.attributedText = att;
    self.salePriceLabel.text = [NSString stringWithFormat:@"￥%@",goodsModel.sale_price];
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
