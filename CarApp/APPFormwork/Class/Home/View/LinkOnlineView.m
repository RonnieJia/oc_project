//
//  LinkOnlineView.m
//  APPFormwork

#import "LinkOnlineView.h"

@implementation LinkOnlineView
+ (instancetype)sharedInstance {
    static LinkOnlineView *_link = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _link = [[LinkOnlineView alloc] init];
    });
    return _link;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [KTextBlackColor colorWithAlphaComponent:0.4];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSelf)];
        
        UIView *contentView = RJCreateSimpleView(CGRectMake(0, 0, 270, 200), KTextWhiteColor);
        [contentView addGestureRecognizer:[UITapGestureRecognizer new]];
        contentView.center = CGPointMake(KScreenWidth/2, KScreenHeight/2);
        [self addSubview:contentView];
        contentView.layer.cornerRadius = 4;
        contentView.clipsToBounds = YES;
        
        UIView *titleV = RJCreateSimpleView(CGRectMake(0, 0, contentView.width, 50), KThemeColor);
        [contentView addSubview:titleV];
        UILabel *titleL = RJCreateLable(CGRectMake(30, 10, titleV.width-60, 30), kFontWithSmallSize, KTextWhiteColor, NSTextAlignmentCenter, @"在线联系");
        [titleV addSubview:titleL];
        UIButton *closeB = RJCreateButton(CGRectMake(titleV.width-30, 0, 30, 50), kFont(20), KTextWhiteColor, nil, nil, nil, @"×");
        [titleV addSubview:closeB];
        [closeB addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
        
        NSArray *titleArr = @[@"联系挂车厂",@"联系平台",@"联系车主"];
        for (int i = 0; i<3; i++) {
            UIView *v = RJCreateSimpleView(CGRectMake(0, 50+i*50, contentView.width, 50), KTextWhiteColor);
            [contentView addSubview:v];
            UILabel *titlL = RJCreateDefaultLable(CGRectMake(20, 10, 100, 30), kFontWithSmallSize, KTextDarkColor, titleArr[i]);
            [v addSubview:titlL];
            
            UIButton *btn = RJCreateImageButton(v.bounds, [UIImage imageNamed:@"come"], nil);
            btn.contentHorizontalAlignment=2;
            btn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
            [v addSubview:btn];
            btn.tag = 100+i;
            [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [v addSubview:RJCreateSimpleView(CGRectMake(10, 49, v.width-20, 1), KSepLineColor)];
        }
    }
    return self;
}
- (void)showWithBlock:(LinkOnlineBlock)block {
    self.block = block;
    [KKeyWindow addSubview:self];
}
- (void)btnAction:(UIButton *)btn {
    if (self.block) {
        self.block(btn.tag-100);
        self.block = nil;
    }
    [self closeSelf];
}

- (void)closeSelf {
    [self removeFromSuperview];
}

@end
