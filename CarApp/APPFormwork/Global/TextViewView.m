//
//  TextViewView.m
//  APPFormwork
//
//  Created by 李正雷 on 2019/6/4.
//  Copyright © 2019年 RJ. All rights reserved.
//

#import "TextViewView.h"

@implementation TextViewView
- (instancetype)initWithFrame:(CGRect)frame andPlaceHolderString:(NSString *)placeHolder
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
        self.placeHolderString = placeHolder;
    }
    return self;
}
-(void)awakeFromNib{
    [super awakeFromNib];
    
}
-(void)setPlaceHolderString:(NSString *)placeHolderString{
    _placeHolderString = placeHolderString;
    _placeholderLabel.text = placeHolderString;
}
-(void)createUI{
    self.textView = [[UITextView alloc]initWithFrame:self.bounds];
    [self addSubview:self.textView];
    self.textView.font = kFontWithSmallSize;
    self.textView.textColor = KTextDarkColor;
    self.textView.delegate = self;
    self.placeholderLabel = [UILabel labelWithFrame:CGRectMake(5, 5, self.textView.width-10, 20) textColor:KTextGrayColor font:kFontWithSmallSize text:_placeHolderString];
    [self.textView addSubview:self.placeholderLabel];
    self.textView.returnKeyType = UIReturnKeyDone;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if(textView.text.length < 1){
        self.placeholderLabel.text = _placeHolderString;
        self.placeholderLabel.hidden = NO;
    }
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
        _placeholderLabel.hidden = YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
