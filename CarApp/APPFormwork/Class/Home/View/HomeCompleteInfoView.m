//
//  HomeCompleteInfoView.m
//  APPFormwork
//
//  Created by jia on 2019/11/11.
//  Copyright © 2019 RJ. All rights reserved.
//

#import "HomeCompleteInfoView.h"



@implementation HomeCompleteInfoView
- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [KTextBlackColor colorWithAlphaComponent:0.3];
        
        
        UIView *contentVIew = RJCreateView(CGRectMake(30, 0, KScreenWidth-60, (KScreenWidth-60)*235/370.0), KTextWhiteColor, YES, 6, nil, 0);
        [self addSubview:contentVIew];
        contentVIew.center = CGPointMake(KScreenWidth/2, KScreenHeight/2);
        
        UIButton *btn = RJCreateTextButton(CGRectMake(0, 0, contentVIew.width, 60), kFontWithDefaultSize, KTextWhiteColor, [UIImage imageNamed:@"centerback002_h"], @"温馨提示");
        [contentVIew addSubview:btn];
        btn.userInteractionEnabled = NO;
        
        UILabel *label = RJCreateLable(CGRectMake(10, contentVIew.height/2-10, contentVIew.width-20, 20), kFontWithSmallSize, KTextBlackColor, NSTextAlignmentCenter, @"您的信息不完善，需要完善信息");
        [contentVIew addSubview:label];
        label.adjustsFontSizeToFitWidth = YES;
        
        
        UIButton *btn2 = RJCreateTextButton(CGRectMake(0, contentVIew.height-50, 80, 30), kFontWithDefaultSize, KTextWhiteColor, [UIImage imageNamed:@"button001"], @"去完善");
        [contentVIew addSubview:btn2];
        btn2.centerX = contentVIew.width/2;
        [btn2 addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)btnAction {
    [self removeFromSuperview];
    if (self.blcok) {
        self.blcok();
    }
}


- (void)show:(void (^)())block {
    self.blcok = block;
    [KKeyWindow addSubview:self];
}

@end
