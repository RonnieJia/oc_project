//
//  UIButton+Custom.m
//

#import "UIButton+Custom.h"

@implementation UIButton (Custom)

+ (instancetype)buttonWithFrame:(CGRect)frame title:(NSString *)title titleColor:(UIColor *)titleColor titleFont:(UIFont *)font image:(UIImage *)norImg selectImage:(UIImage *)selImg target:(id)target selector:(SEL)selector {
    UIButton *btn = [self buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    if (title)
      [btn setTitle:title forState:UIControlStateNormal];
    if (!titleColor) titleColor =  KTextBlackColor;
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    
    if (font) btn.titleLabel.font = font;
    
    if (norImg) [btn setImage:norImg forState:UIControlStateNormal];
    if (selImg) [btn setImage:selImg forState:UIControlStateSelected];
    
    if (target) {
        [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    
    return btn;
}

+ (UIButton *)sureButtonWithTop:(CGFloat)top title:(NSString *)title {
    UIButton *sureBtn = [self buttonWithFrame:CGRectMake(25, top, KScreenWidth-50, 40) title:title font:kFontWithDefaultSize titleColor:KTextWhiteColor target:nil action:NULL];
    sureBtn.layer.cornerRadius = 4.f;
    sureBtn.clipsToBounds = YES;
//    [sureBtn setImage:[UIImage imageNamed:@"button003"] forState:UIControlStateNormal];
//    [sureBtn setBackgroundImage:[UIImage imageNamed:@"button003"] forState:UIControlStateNormal];
    sureBtn.backgroundColor = KThemeColor;
    sureBtn.layer.masksToBounds = YES;
    return sureBtn;
}

+ (UIButton *)sureButtonWithTitle:(NSString *)title {
    UIButton *sureBtn = [self buttonWithFrame:CGRectMake(15, 0, KScreenWidth-30, 44) title:title font:kFontWithSmallSize titleColor:KTextWhiteColor target:nil action:NULL];
    sureBtn.layer.cornerRadius = 4.f;
    sureBtn.clipsToBounds = YES;
    [sureBtn setImage:[UIImage imageNamed:@"button003"] forState:UIControlStateNormal];

//    sureBtn.backgroundColor = [UIColor colorWithHex:@"#FA4B3D"];
    sureBtn.layer.masksToBounds = YES;
    return sureBtn;
}


+ (UIButton *)buttonWithFrame:(CGRect)frame image:(UIImage *)image target:(id)target action:(SEL)action {
    UIButton *button = [self buttonWithFrame:frame title:nil titleColor:nil titleFont:nil image:image selectImage:nil target:target selector:action];
    return button;
}

+ (UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)color target:(id)target action:(SEL)action {
    UIButton *button = [self buttonWithFrame:frame title:title titleColor:color titleFont:font image:nil selectImage:nil target:target selector:action];
    return button;
}
+ (UIButton *)buttonWithFrame:(CGRect)frame bottomTitle:(NSString *)title topImage:(NSString *)image font:(UIFont *)font titleColor:(UIColor *)color target:(id)target action:(SEL)action {
    UIButton *button = [self buttonWithFrame:frame title:title titleColor:color titleFont:font image:[UIImage imageNamed:image] selectImage:nil target:target selector:action];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
    [button setTitleEdgeInsets:UIEdgeInsetsMake(button.imageView.frame.size.height+15 ,-button.imageView.frame.size.width, 0.0,0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
    [button setImageEdgeInsets:UIEdgeInsetsMake(-10, 0.0,0.0, -button.titleLabel.bounds.size.width)];//图片距离右边框距离减少图片的宽度，其它不边
    
    return button;
}
+ (UIButton *)buttonWithFrame:(CGRect)frame leftTitle:(NSString *)title rightImage:(NSString *)image font:(UIFont *)font titleColor:(UIColor *)color target:(id)target action:(SEL)action {
    UIButton *button = [self buttonWithFrame:frame title:title titleColor:color titleFont:font image:[UIImage imageNamed:image] selectImage:nil target:target selector:action];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0 ,0, 0.0,button.imageView.frame.size.width)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
    [button setImageEdgeInsets:UIEdgeInsetsMake(0,  button.titleLabel.bounds.size.width+30,0.0,0.0)];//图片距离右边框距离减少图片的宽度，其它不边
    
    return button;
}
@end
