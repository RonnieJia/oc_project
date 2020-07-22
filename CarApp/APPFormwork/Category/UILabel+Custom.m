//
//  UILabel+Custom.m

#import "UILabel+Custom.h"

@implementation UILabel (Custom)

+(UILabel *)labelWithFrame:(CGRect)frame textColor:(UIColor *)textColor font:(UIFont *)font text:(NSString *)text {
    return [self labelWithFrame:frame textColor:textColor font:font textAlignment:NSTextAlignmentLeft text:text];
}
+ (UILabel *)labelWithFrame:(CGRect)frame textColor:(UIColor *)textColor font:(UIFont *)font textAlignment:(NSTextAlignment)alignment text:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    if (textColor) {
        label.textColor = textColor;
    } else {
        label.textColor = [UIColor blackColor];
    }
    if (font) {
        label.font = font;
    } else {
        label.font = kFontWithDefaultSize;
    }
    label.textAlignment = alignment;
    if (!IsStringEmptyOrNull(text)) {
        label.text = text;
    }
    return label;
}
@end
