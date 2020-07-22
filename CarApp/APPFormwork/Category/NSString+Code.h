
#import <Foundation/Foundation.h>

@interface NSString (Code)
- (NSString *)stringWithUniCodeString:(NSString *)unicode;
- (CGFloat)heightWithMaxWid:(CGFloat)wid font:(CGFloat)size;
- (CGFloat)widthWithMaxWid:(CGFloat)wid font:(CGFloat)size;

- (NSString *)priceNum;


/*
 *获取汉字拼音的首字母, 返回的字母是大写形式, 例如: @"俺妹", 返回 @"A".
 *如果字符串开头不是汉字, 而是字母, 则直接返回该字母, 例如: @"b彩票", 返回 @"B".
 *如果字符串开头不是汉字和字母, 则直接返回 @"#", 例如: @"&哈哈", 返回 @"#".
 *字符串开头有特殊字符(空格,换行)不影响判定, 例如@"       a啦啦啦", 返回 @"A".
 */
- (NSString *)getFirstLetter;

/**
 汉字转拼音
 */
- (NSString *)transformToChinese;

@end
