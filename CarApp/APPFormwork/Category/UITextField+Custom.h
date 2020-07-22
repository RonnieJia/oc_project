//
//  UITextField+Custom.h
//  APPFormwork
//
//  Created by jia on 2017/8/11.
//  Copyright © 2017年 RJ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RJTextFieldStyle) {
    RJTextFieldStyleNone        = 0,
    RJTextFieldStyleBottomLine  = 1,
    RJTextFieldStyleRoundBorder = 2,
};

@interface UITextField (Custom)
- (void)setLeftMargin:(CGFloat)left rightMargin:(CGFloat)right;

+ (instancetype)textFieldWithFrame:(CGRect)frame textColor:(UIColor *)textColor font:(UIFont *)font placeholder:(NSString *)placeholder placeholderColor:(UIColor *)placeholderColor style:(RJTextFieldStyle)style borderColor:(UIColor *)borderColor leftView:(UIView *)leftView clearBtn:(BOOL)clearBtn;


+ (instancetype)textFieldWithBottomLineFrame:(CGRect)frame textColor:(UIColor *)textColor font:(UIFont *)font placeholder:(NSString *)placeholder placeholderColor:(UIColor *)placeholderColor leftImage:(NSString *)img;
@end
