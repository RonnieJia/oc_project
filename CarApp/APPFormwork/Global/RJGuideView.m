//
//  RJGuideView.m
//  APPFormwork
//
//  Created by jia on 2020/4/2.
//  Copyright © 2020 RJ. All rights reserved.
//

#import "RJGuideView.h"
#import "AppDelegate.h"
#import "SDCycleScrollView.h"

@interface RJGuideView ()<SDCycleScrollViewDelegate>

@end

@implementation RJGuideView

+ (void)show {
    RJGuideView *view = [[RJGuideView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *vc = appdelegate.window.rootViewController;
    [vc.view addSubview:view];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        SDCycleScrollView *scroll = [SDCycleScrollView cycleScrollViewWithFrame:self.bounds imageNamesGroup:@[@"WechatIMG3",@"WechatIMG4",@"WechatIMG2"]];
        scroll.delegate = self;
        scroll.contentMode = UIViewContentModeScaleAspectFill;
        scroll.autoScroll = NO;
        [self addSubview:scroll];
        /*
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:scrollView];
        
        scrollView.pagingEnabled = YES;
        scrollView.contentSize = CGSizeMake(KScreenWidth*3, KScreenHeight);
        
        NSArray *arr = @[@"3",@"4",@"2"];
        for (int i = 0; i<3; i++) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(KScreenWidth*i, 0, self.width, self.height)];
            [scrollView addSubview:imgView];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"WechatIMG%@",arr[i]]];
        }
         */
    }
    return self;
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    if (index == 2) {
        [self removeFromSuperview];
    }
}

@end
