
#import "GoodsCateCollectionCell.h"
#import "Masonry.h"

@implementation GoodsCateCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kViewControllerBgColor;
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 6;
        UILabel *titleL = RJCreateLable(CGRectZero, kFontWithSmallestSize, KTextDarkColor, NSTextAlignmentCenter, @"");
        titleL.numberOfLines=2;
        self.titleLabel = titleL;
        [self.contentView addSubview:titleL];
        [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(5);
            make.right.mas_equalTo(-5);
            make.top.mas_equalTo(5);
            make.bottom.mas_equalTo(-5);
        }];
        
    }
    return self;
}
@end
