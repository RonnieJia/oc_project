//
//  UITextField+Custom.m
//  APPFormwork
//
//  Created by jia on 2017/8/11.
//  Copyright © 2017年 RJ. All rights reserved.
//

#import "UITextField+Custom.h"

@implementation UITextField (Custom)
- (void)setLeftMargin:(CGFloat)left rightMargin:(CGFloat)right {
    if (left > 0) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, left, self.height)];
        self.leftViewMode = UITextFieldViewModeAlways;
        self.leftView = v;
    }
    if (right>0) {
        UIView *v2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, right, self.height)];
        self.rightViewMode = UITextFieldViewModeAlways;
        self.rightView = v2;
    }
}
+ (instancetype)textFieldWithBottomLineFrame:(CGRect)frame textColor:(UIColor *)textColor font:(UIFont *)font placeholder:(NSString *)placeholder placeholderColor:(UIColor *)placeholderColor leftImage:(NSString *)img {
    UIImageView *imgView = nil;
    if (img) {
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, frame.size.height)];
        imgView.contentMode = UIViewContentModeLeft;
        imgView.image = [UIImage imageNamed:img];
    }
    
    return [self textFieldWithFrame:frame textColor:textColor font:font placeholder:placeholder placeholderColor:placeholderColor style:RJTextFieldStyleBottomLine borderColor:KTextGrayColor leftView:imgView clearBtn:YES];
}


+ (instancetype)textFieldWithFrame:(CGRect)frame textColor:(UIColor *)textColor font:(UIFont *)font placeholder:(NSString *)placeholder placeholderColor:(UIColor *)placeholderColor style:(RJTextFieldStyle)style borderColor:(UIColor *)borderColor leftView:(UIView *)leftView clearBtn:(BOOL)clearBtn {
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    if (textColor) {
        textField.textColor = textColor;
    }
    if (font) {
        textField.font = font;
    }
    if (placeholder) {
        textField.placeholder = placeholder;
//        if (placeholderColor) {
//            [textField setValue:placeholderColor forKeyPath:@"_placeholderLabel.textColor"];
//        }
    }
    if (leftView) {
        textField.leftView = leftView;
        textField.leftViewMode = UITextFieldViewModeAlways;
    }
    if (clearBtn) {
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    
    if (style == RJTextFieldStyleBottomLine) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, textField.height-1, textField.width, 1.0)];
        line.backgroundColor = borderColor;
        [textField addSubview:line];
    } else if (style == RJTextFieldStyleRoundBorder) {
        if (!borderColor) {
            borderColor = KSepLineColor;
        }
        textField.layer.borderColor = [borderColor CGColor];
        textField.layer.borderWidth = 1.0f;
        textField.layer.cornerRadius = 4.0f;
    }
    return textField;
}
@end
