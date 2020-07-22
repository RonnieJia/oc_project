//

#import "ShopHeaderView.h"
#import "UIImageView+Car.h"

@implementation ShopHeaderView
- (instancetype)init {
    self = [super init];
    if (self) {
        /*
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
        */
        CGFloat widTotal = (KScreenWidth-24-5);
        CGFloat widBanner1 = widTotal * (257.0/(257+87.0));
        CGFloat height = widBanner1 * 127.0/257.0;
        UIImageView *banner1 = RJCreateSimpleImageView(CGRectMake(12, 5, widBanner1, height), nil);
        [self addSubview:banner1];
        banner1.tag = 1000;
        
        UIImageView *banner2 = RJCreateSimpleImageView(CGRectMake(banner1.right+5, banner1.top, widTotal-widBanner1, height), nil);
        [self addSubview:banner2];
        banner2.tag = 1001;
        banner1.userInteractionEnabled = banner2.userInteractionEnabled = YES;
        [banner1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTapAction:)]];
        [banner2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTapAction:)]];
        
        CGFloat widB = (KScreenWidth-24-10)/3.0;
        CGFloat heiB = widB * 98.0 / 113.0;
        for (int i = 0; i<3; i++) {
            UIImageView *bannerItem = RJCreateSimpleImageView(CGRectMake(12+i%3*(widB+5), banner1.bottom+5, widB, heiB), nil);
            bannerItem.userInteractionEnabled=YES;
            [self addSubview:bannerItem];
            bannerItem.tag = 1002+i;
            [bannerItem addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTapAction:)]];
        }
        
        UIImageView *banner3 = RJCreateSimpleImageView(CGRectMake(0, banner1.bottom+15+heiB, KScreenWidth, KAUTOSIZE(84)), nil);
        [self addSubview:banner3];
        banner3.contentMode = UIViewContentModeScaleToFill;
        banner3.tag = 1005;
        
        self.size = CGSizeMake(KScreenWidth, banner3.bottom+10);
    }
    return self;
}

- (void)bannerTapAction:(UITapGestureRecognizer *)tap {
    UIImageView *imgView = (UIImageView *)tap.view;
    if (!IsStringEmptyOrNull(imgView.goods_id)) {
        if (self.shopHeaderBannerBlock) {
            self.shopHeaderBannerBlock(imgView.goods_id);
        }
    }
}

- (void)display:(NSDictionary *)dic {
    NSArray *bannerList = ObjForKeyInUnserializedJSONDic(dic, @"banner_list");
    CGFloat top = 0;
    UIImageView *imgView2 = (UIImageView *)[self viewWithTag:1005];
    NSInteger count = 0;
    if (bannerList && [bannerList isKindOfClass:[NSArray class]]) {
        if (bannerList.count == 2) {
            count = 2;
        } else if (bannerList.count < 5 && bannerList.count>= 3) {
            count = 3;
        } else if (bannerList.count>=5) {
            count = 5;
        }
        if (count>0) {
            for (int i = 0; i<5; i++) {
                UIImageView *imgView = (UIImageView *)[self viewWithTag:1000+i];
                if (count==3) {
                    if (i>=2) {
                        imgView.top = 105;
                        [imgView rj_setImageWithPath:StringForKeyInUnserializedJSONDic(bannerList[i], @"pcture")];
                        imgView.goods_id = StringForKeyInUnserializedJSONDic(bannerList[i-2], @"goods_id");
                        top = imgView.bottom+10;
                    } else {
                        imgView.hidden = YES;
                    }
                } else {
                    if (i<count) {
                        [imgView rj_setImageWithPath:StringForKeyInUnserializedJSONDic(bannerList[i], @"pcture")];
                        imgView.goods_id = StringForKeyInUnserializedJSONDic(bannerList[i], @"goods_id");
                        top = imgView.bottom+10;
                    } else {
                        imgView.hidden = YES;
                    }
                }
            }
        }else {
            top = 105;
        }
        
        imgView2.top = top;
        self.height = top+KAUTOSIZE(84)+10;
    }
    [imgView2 rj_setImageWithPath:StringForKeyInUnserializedJSONDic(dic, @"one_picture") placeholderImage:[UIImage imageNamed:@"banner002"]];
}

@end
