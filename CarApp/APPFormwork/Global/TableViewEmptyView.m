//
//  TableViewEmptyView.m
//  APPFormwork
//
//  Created by jia on 2018/3/6.
//  Copyright © 2018年 RJ. All rights reserved.
//

#import "TableViewEmptyView.h"

@implementation TableViewEmptyView
+ (UIView *)footerViewWithDataCount:(NSInteger)count {
    if (count > 0) {
        return [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kIPhoneXBH)];
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KViewNavHeight-kIPhoneXBH)];
        UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"null"]];
        imgV.center = CGPointMake(view.width/2, view.height/2);
        [view addSubview:imgV];
        return view;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
