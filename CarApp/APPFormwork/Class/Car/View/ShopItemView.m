//
//  ShopItemView.m
//  APPFormwork
//
//  Created by jia on 2019/12/6.
//  Copyright © 2019 RJ. All rights reserved.
//

#import "ShopItemView.h"

@implementation ShopItemView
- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = kViewControllerBgColor;
        self.clipsToBounds=YES;
        
        UIImageView *themeView = RJCreateSimpleImageView(CGRectMake(0, 70-KAUTOSIZE(130), KScreenWidth, KAUTOSIZE(130)), [UIImage imageNamed:@"shopback"]);
        [self addSubview:themeView];
        
        UIView *shopmenuBaqck = RJCreateSimpleView(CGRectMake(12, 10, KScreenWidth-24, 85), [UIColor clearColor]);
        [self addSubview:shopmenuBaqck];
        shopmenuBaqck.layer.shadowColor = KTextDarkColor.CGColor;
        // 阴影偏移，默认(0, -3)
        shopmenuBaqck.layer.shadowOffset = CGSizeMake(0,3);
        // 阴影透明度，默认0
        shopmenuBaqck.layer.shadowOpacity = 0.3;
        // 阴影半径，默认3
        shopmenuBaqck.layer.shadowRadius = 2;
        
        UIImageView *shopmenu = RJCreateSimpleImageView(CGRectMake(12, 10, KScreenWidth-24, 85), [UIImage imageNamed:@"shopmenu"]);
        shopmenu.userInteractionEnabled=YES;
        shopmenu.contentMode=UIViewContentModeScaleToFill;
        shopmenu.layer.cornerRadius = 6;
        shopmenu.clipsToBounds=YES;
        [self addSubview:shopmenu];
        
        CGFloat wid = shopmenu.width/4.0;
        NSArray *titles = @[@"全部分类",@"我的收藏",@"购物车",@"商城订单"];
        NSArray *clas = @[@"ShopCategoryViewController",@"ShopMyCollectViewController",@"ShopCartViewController",@"ShopOrderViewController"];
        for (int i = 0; i<4; i++) {
            RJButton *item = [RJButton buttonWithFrame:CGRectMake(i%4 * wid, 5, wid, 80) title:titles[i] titleColor:KTextDarkColor titleFont:kFontWithSmallestSize image:[UIImage imageNamed:[NSString stringWithFormat:@"shopicon00%d",i+1]] selectImage:nil target:self selector:NULL];
            item.margin = 5;
            item.type = RJButtonTypeTitleBottom;
            item.cla = clas[i];
            [item addTarget:self action:@selector(shopItemClick:) forControlEvents:UIControlEventTouchUpInside];
            [shopmenu addSubview:item];
        }
        
        self.size = CGSizeMake(KScreenWidth, shopmenu.bottom+10);
    }
    return self;
}



- (void)shopItemClick:(RJButton *)btn {
    if (self.shopHeaderCallBack) {
        self.shopHeaderCallBack(btn.tag, btn.cla);
    }
}
@end
