// 商城

#import "ShopCollectionViewCell.h"
#import "ShopGoodsModel.h"

@implementation ShopCollectionViewCell
- (void)setGoodsModel:(ShopGoodsModel *)goodsModel {
    _goodsModel = goodsModel;
    [self.iconImgView rj_setImageWithPath:goodsModel.picture placeholderImage:KDefaultImg];
    self.goodsName.text = goodsModel.goods_name;
    self.cateLabel.text = goodsModel.category_name;
    NSString *price = goodsModel.price;
    NSString *sale_price = goodsModel.sale_price;
    NSString *str = [NSString stringWithFormat:@"￥%@ ￥%@",sale_price, price];
    NSMutableAttributedString *att=[[NSMutableAttributedString alloc] initWithString:str];
    [att addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:@"#FF4B00"] range:NSMakeRange(0, sale_price.length+1)];
    [att addAttribute:NSFontAttributeName value:kFont(12) range:NSMakeRange(sale_price.length+2, price.length+1)];
    [att addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(sale_price.length+2, price.length+1)];
    self.priceLabel.attributedText=att;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

@end
