//
//  NSMutableAttributedString+label.m
//  APPFormwork
//
//  Created by jia on 2018/3/23.
//  Copyright © 2018年 RJ. All rights reserved.
//

#import "NSMutableAttributedString+label.h"

@implementation NSMutableAttributedString (label)
- (NSMutableAttributedString *)initWithString:(NSString *)string lineSpace:(CGFloat)space firstHeadIndent:(CGFloat)firstHeadIndet {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //行间距
    UIFont *font;
    paragraphStyle.lineSpacing = space; //首行缩进
    paragraphStyle.firstLineHeadIndent = firstHeadIndet;
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSParagraphStyleAttributeName:paragraphStyle}];
    return att;
}
@end
