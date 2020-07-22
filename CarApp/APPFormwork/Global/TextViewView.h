//
//  TextViewView.h
//  APPFormwork
//
//  Created by 李正雷 on 2019/6/4.
//  Copyright © 2019年 RJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextViewView : UIView<UITextViewDelegate>
- (instancetype)initWithFrame:(CGRect)frame andPlaceHolderString:(NSString *)placeHolder;
@property(nonatomic,strong)UITextView *textView;
@property(nonatomic,strong)UILabel *placeholderLabel;
@property(nonatomic,strong)NSString *placeHolderString;
@end
