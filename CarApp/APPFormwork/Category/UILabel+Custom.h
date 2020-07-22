//
//  UILabel+Custom.h
//

#import <UIKit/UIKit.h>

@interface UILabel (Custom)
/** 默认NSTextAlignmentLeft */
+(UILabel *)labelWithFrame:(CGRect)frame textColor:(UIColor *)textColor font:(UIFont *)font text:(NSString *)text;
/** 快速创建 */
+ (UILabel *)labelWithFrame:(CGRect)frame textColor:(UIColor *)textColor font:(UIFont *)font textAlignment:(NSTextAlignment)alignment text:(NSString *)text;
@end
