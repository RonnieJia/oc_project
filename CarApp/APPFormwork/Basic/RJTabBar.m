//
//  RJTabBar.m
//  RJMySelfTabbar
//
//  Created by jia on 2017/1/6.
//  Copyright © 2017年 RJ. All rights reserved.
//

#import "RJTabBar.h"

@interface RJTabBar()
@property(nonatomic, weak)UIButton *plusBtn;// 中间的发布按钮
@property(nonatomic, weak)UIView *foreView;
@end

@implementation RJTabBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //去掉顶部阴影条
//        [self setShadowImage:[UIImage new]];
//        self.backgroundImage = createImageWithColor(kTextRedColor);
        
        UIButton *plusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [plusBtn setImage:[UIImage imageNamed:@"tabbar_issue"] forState:UIControlStateNormal];
        [plusBtn setImage:[UIImage imageNamed:@"tabbar_issue"] forState:UIControlStateHighlighted];
        [plusBtn setImage:[UIImage imageNamed:@"tabbar_issue"] forState:UIControlStateSelected];
        plusBtn.backgroundColor = KThemeColor;
        plusBtn.frame = CGRectMake(0, 0, 55, 55);
        plusBtn.layer.cornerRadius = 55/2.0;
        plusBtn.layer.masksToBounds = YES;
        [plusBtn addTarget:self action:@selector(plusBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:plusBtn];
        self.plusBtn = plusBtn;
    }
    return self;
}



- (void)layoutSubviews {
    [super layoutSubviews];
    self.foreView.centerX = self.width/2.0;
    self.plusBtn.center = CGPointMake(self.width/2.0, self.height/2.0 - 10);
    [self bringSubviewToFront:self.plusBtn];
    CGFloat width = self.frame.size.width / 5.0;
    CGFloat tabBarButtonIndex = 0;
    for (UIView *childView in self.subviews) {
        if ([childView isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            if (tabBarButtonIndex ==  2) {
                tabBarButtonIndex = 3;
            }
            childView.frame = CGRectMake(tabBarButtonIndex * width, childView.frame.origin.y, width, CGRectGetHeight(childView.frame));
            tabBarButtonIndex++;
        }
    }
    
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.hidden) {
        return nil;
    }
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        CGPoint tempoint = [self.plusBtn convertPoint:point fromView:self];
        if (CGRectContainsPoint(self.plusBtn.bounds, tempoint))
        {
            view = self.plusBtn;
        }
    }
    return view;
}

- (void)plusBtnClick:(UIButton *)sender {
    RJLog(@"click center button ");
    if (self.RJdelegate && [self.RJdelegate respondsToSelector:@selector(tabBarDidClickPlusButton:)]) {
        [self.RJdelegate tabBarDidClickPlusButton:self];
    }
}

@end
