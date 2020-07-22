//
#import "SceneView.h"

@implementation SceneView

- (instancetype)init{
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [KTextBlackColor colorWithAlphaComponent:0.35];
        
        UIView *contentView = RJCreateSimpleView(CGRectMake(0, 0, 270, 170), KTextWhiteColor);
        [self addSubview:contentView];
        contentView.layer.cornerRadius = 6;
        contentView.clipsToBounds = YES;
        contentView.center = CGPointMake(self.width/2, self.height/2);
        
        UIImageView *titleView = RJCreateSimpleImageView(CGRectMake(0, 0, contentView.width, 50), [UIImage imageNamed:@"tipheader"]);
        titleView.userInteractionEnabled=YES;
        [contentView addSubview:titleView];
        UIButton *close = RJCreateTextButton(CGRectMake(240, 15, 30, 20), kFontWithBigbigestSize, KTextWhiteColor, nil, @"×");
        [close addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:close];
        UILabel *titleL = RJCreateLable(CGRectMake(0, 10, 100, 30), kFontWithDefaultSize, KTextWhiteColor, NSTextAlignmentCenter, @"温馨提示");
        [titleView addSubview:titleL];
        titleL.centerX = titleView.width/2;
        
        
        UIButton *btn1 = RJCreateTextButton(CGRectMake(20, contentView.height-41, 105, 26), kFontWithDefaultSize, KTextWhiteColor, createImageWithColor([UIColor colorWithHex:@"#3072CC"]), @"进行维修");
        [contentView addSubview:btn1];
        btn1.clipsToBounds = YES;
        btn1.layer.cornerRadius = 13;
        
        UIButton *btn2 = RJCreateTextButton(CGRectMake(20+btn1.right,btn1.top, 105, 26), kFontWithDefaultSize, KTextWhiteColor, createImageWithColor([UIColor colorWithHex:@"#3072CC"]), @"拒绝维修");
        [contentView addSubview:btn2];
        btn2.clipsToBounds = YES;
        btn2.layer.cornerRadius = 13;
        btn2.tag = 1;
        [btn2 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn1 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *infoL = RJCreateLable(CGRectMake(10, titleView.bottom+10, 250, btn1.top - titleView.bottom-20), kFontWithSmallSize, KTextDarkColor, NSTextAlignmentCenter, @"您已到达现场，是否进行维修");
        [contentView addSubview:infoL];
    }
    return self;
}

- (void)buttonAction:(UIButton *)btn {
    [self closeSelf];
    if (self.block) {
        self.block(btn.tag);
    }
}

- (void)showWithCallback:(SceneCallBack)callback {
    self.block = callback;
    [KKeyWindow addSubview:self];
}

- (void)closeSelf {
    [self removeFromSuperview];
}

@end
