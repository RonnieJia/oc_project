

#import "ShopCartHeaderView.h"

@implementation ShopCartHeaderView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.size = CGSizeMake(KScreenWidth, 50);
        UIImageView *imgView = RJCreateSimpleImageView(CGRectMake(0, 0, KScreenWidth, 37), [UIImage imageNamed:@"picketback_hx"]);
        imgView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:imgView];
        
        UIView *btnView = RJCreateSimpleView(CGRectMake(12, 5, KScreenWidth-24, 45), KTextWhiteColor);
        [self addSubview:btnView];
        
        UIButton *allBtn = RJCreateButton(CGRectMake(0, 0, btnView.width, 45), kFontWithSmallSize, KTextDarkColor, nil, nil, [UIImage imageNamed:@"circle003"], @" 全选");
        allBtn.contentHorizontalAlignment=1;
        allBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [allBtn setImage:[UIImage imageNamed:@"circle004"] forState:UIControlStateSelected];
        allBtn.adjustsImageWhenHighlighted=NO;
        [btnView addSubview:allBtn];
        self.chooseBtn = allBtn;
        [allBtn addTarget:self action:@selector(chooseAll:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:btnView.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(6, 6)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
        //设置大小
        maskLayer.frame = btnView.bounds;
        //设置图形样子
        maskLayer.path = maskPath.CGPath;
        btnView.layer.mask = maskLayer;
    }
    return self;
}

- (void)chooseAll:(UIButton *)btn {
    self.allChoose = !self.allChoose;
    if (self.shopCartAllChooseBlcok) {
        self.shopCartAllChooseBlcok(self.allChoose);
    }
}

- (void)setAllChoose:(BOOL)allChoose {
    if (self.allChoose == allChoose) {
        return;
    }
    _allChoose = allChoose;
    self.chooseBtn.selected = _allChoose;
}

@end
