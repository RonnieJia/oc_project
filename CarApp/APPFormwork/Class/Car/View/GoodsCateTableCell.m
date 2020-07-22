#import "GoodsCateTableCell.h"
#import "Masonry.h"

@implementation GoodsCateTableCell
- (void)setupViews {
    self.backgroundColor = kViewControllerBgColor;
    UILabel *titleL = RJCreateLable(CGRectZero, kFontWithSmallSize, KTextDarkColor, NSTextAlignmentCenter, @"分类名字");
    titleL.numberOfLines = 2;
    [self.contentView addSubview:titleL];
    
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.mas_equalTo(5);
        make.bottom.and.right.mas_equalTo(-5);
    }];
    self.titleLabel = titleL;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (self.selected == selected) {
        return;
    }
    if (selected) {
        self.backgroundColor = KTextWhiteColor;
    } else {
        self.backgroundColor = kViewControllerBgColor;
    }
    [super setSelected:selected animated:animated];
}

@end
