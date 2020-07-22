

#import "GoodsListSortView.h"

@implementation GoodsListSortView

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, KScreenWidth, 45)];
    if (self) {
        self.backgroundColor = KTextWhiteColor;
        UIView *contentView = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 35), KTextWhiteColor);
        [self addSubview:contentView];
        contentView.layer.shadowColor = KTextDarkColor.CGColor;
        // 阴影偏移，默认(0, -3)
        contentView.layer.shadowOffset = CGSizeMake(0,3);
        // 阴影透明度，默认0
        contentView.layer.shadowOpacity = 0.4;
        // 阴影半径，默认3
        contentView.layer.shadowRadius = 2;
        
        CGFloat wid = (KScreenWidth-2)/3.0;
        NSArray *titles = @[@"分类",@"综合",@"价格"];
        for (int i = 0; i<3; i++) {
            RJButton *btn = [RJButton buttonWithFrame:CGRectMake(i*(wid+1), 0, wid, 35) title:titles[i] titleColor:KTextGrayColor titleFont:kFontWithSmallSize image:[UIImage imageNamed:i==0?@"select001":@"sort001"] selectImage:nil target:self selector:@selector(buttonClick:)];
            btn.type = RJButtonTypeTitleLeft;
            btn.tag = 100+i;
            [contentView addSubview:btn];
            if (i<2) {
                UIView *line = RJCreateSimpleView(CGRectMake(btn.right, 5, 1, 25), KSepLineColor);
                [contentView addSubview:line];
            }
        }
    }
    return self;
}

- (void)buttonClick:(UIButton *)btn {
    if (self.goodsListSortBlock) {
        self.goodsListSortBlock(btn.tag-100);
    }
}
@end
