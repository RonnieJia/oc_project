//

#import "PayTypeView.h"

@interface PayTypeView ()
@property(nonatomic, weak)UIButton *selectBtn;
@end

@implementation PayTypeView
- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [KTextBlackColor colorWithAlphaComponent:0.4];
        
        UIView *ContentView = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 200), KTextWhiteColor);
        [self addSubview:ContentView];
        ContentView.bottom = self.height;
        
        UILabel *titleL = RJCreateLable(CGRectMake(10, 10, KScreenWidth-20, 20), kFontWithSmallSize, KTextBlackColor, NSTextAlignmentCenter, @"选择支付方式");
        [ContentView addSubview:titleL];
        
        UIButton *close = RJCreateTextButton(CGRectMake(KScreenWidth-40, 0, 40, 40), kFont(20), KTextDarkColor, nil, @"×");
        [close addTarget:self action:@selector(closePay) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *we = RJCreateSimpleView(CGRectMake(0, 60, KScreenWidth, 40), KTextWhiteColor);
        [ContentView addSubview:we];
        UIImageView *imgView = RJCreateSimpleImageView(CGRectMake(13, 9,22, 22), [UIImage imageNamed:@"weixin"]);
        [we addSubview:imgView];
        
        UILabel *label = RJCreateDefaultLable(CGRectMake(imgView.right+10, 10, 100, 20), kFontWithSmallSize, KTextDarkColor, @"微信支付");
        [we addSubview:label];
        UIButton *weBtn = RJCreateImageButton(we.bounds, [UIImage imageNamed:@"circle001"], [UIImage imageNamed:@"circle002"]);
        weBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 13);
        weBtn.contentHorizontalAlignment = 2;
        [we addSubview:weBtn];
        [we addSubview:RJCreateSimpleView(CGRectMake(13, 39, KScreenWidth-26, 1), KSepLineColor)];
        
        UIView *zfb = RJCreateSimpleView(CGRectMake(0, we.bottom, KScreenWidth, 40), KTextWhiteColor);
        [ContentView addSubview:zfb];
        UIImageView *imgView2 = RJCreateSimpleImageView(CGRectMake(13, 9, 22, 22), [UIImage imageNamed:@"zhifubao002"]);
        [zfb addSubview:imgView2];
        
        UILabel *label2 = RJCreateDefaultLable(CGRectMake(imgView.right+10, 10, 100, 20), kFontWithSmallSize, KTextDarkColor, @"支付宝支付");
        [zfb addSubview:label2];
        UIButton *zfbBtn = RJCreateImageButton(zfb.bounds, [UIImage imageNamed:@"circle001"], [UIImage imageNamed:@"circle002"]);
        zfbBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 13);
        zfbBtn.contentHorizontalAlignment = 2;
        [zfb addSubview:zfbBtn];
        [zfbBtn addTarget:self action:@selector(chooseType:) forControlEvents:UIControlEventTouchUpInside];
        [weBtn addTarget:self action:@selector(chooseType:) forControlEvents:UIControlEventTouchUpInside];
        weBtn.tag = 2;
        zfbBtn.tag = 1;
        [zfb addSubview:RJCreateSimpleView(CGRectMake(13, 39, KScreenWidth-26, 1), KSepLineColor)];
        
        UIButton *payBtn = RJCreateTextButton(CGRectMake(15, zfb.bottom+50, KScreenWidth-30, 40), kFontWithSmallSize, KTextWhiteColor, createImageWithColor(KThemeColor), @"支付");
        [payBtn addTarget:self action:@selector(payAction) forControlEvents:UIControlEventTouchUpInside];
        [ContentView addSubview:payBtn];
        ContentView.height = payBtn.bottom+30+kIPhoneXBH;
        ContentView.bottom = KScreenHeight;
        [ContentView addGestureRecognizer:[UITapGestureRecognizer new]];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePay)]];
    }
    return self;
}

- (void)chooseType:(UIButton *)btn {
    if (btn.selected) {
        return;
    }
    btn.selected = YES;
    if (self.selectBtn) {
        self.selectBtn.selected = NO;
    }
    self.selectBtn = btn;
}

- (void)payAction {
    if (!self.selectBtn) {
        ShowAutoHideMBProgressHUD(self, @"请选择支付方式");
        return;
    }
    if (self.block) {
        self.block(self.selectBtn.tag);
    }
    [self closePay];
}

- (void)closePay {
    [self removeFromSuperview];
}

- (void)showWithTypeBlock:(OrderPayBlock)payBlock {
    self.block = [payBlock copy];
    [KKeyWindow addSubview:self];
}

@end
