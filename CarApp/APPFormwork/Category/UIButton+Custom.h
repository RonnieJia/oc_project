//
//  UIButton+Custom.h  2016/10/31.
//

#import <UIKit/UIKit.h>

@interface UIButton (Custom)
+ (UIButton *)sureButtonWithTitle:(NSString *)title;
+ (UIButton *)sureButtonWithTop:(CGFloat)top title:(NSString *)title;
+ (UIButton *)buttonWithFrame:(CGRect)frame image:(UIImage *)image target:(id)target action:(SEL)action;
+ (UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)color target:(id)target action:(SEL)action;
+ (instancetype)buttonWithFrame:(CGRect)frame title:(NSString *)title titleColor:(UIColor *)titleColor titleFont:(UIFont *)font image:(UIImage *)norImg selectImage:(UIImage *)selImg target:(id)target selector:(SEL)selector;
+ (UIButton *)buttonWithFrame:(CGRect)frame bottomTitle:(NSString *)title topImage:(NSString *)image font:(UIFont *)font titleColor:(UIColor *)color target:(id)target action:(SEL)action;//图片文字上下排布
+ (UIButton *)buttonWithFrame:(CGRect)frame leftTitle:(NSString *)title rightImage:(NSString *)image font:(UIFont *)font titleColor:(UIColor *)color target:(id)target action:(SEL)action;//图片右边，文字左边
@end
