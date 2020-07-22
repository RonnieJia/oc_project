//

#import "GoodsDetailInfoView.h"
#import "ShopGoodsModel.h"

@implementation GoodsDetailInfoView

- (instancetype)initWithGoods:(ShopGoodsModel *)goods {
    self = [super init];
    if (self) {
        self.backgroundColor = kViewControllerBgColor;
        self.goodsModel = goods;
        
        UIImageView *icon = RJCreateSimpleImageView(CGRectMake(0, 0, KScreenWidth, KAUTOSIZE(275)), nil);
        icon.contentMode = UIViewContentModeScaleAspectFill;
        icon.clipsToBounds = YES;
        [self addSubview:icon];
        NSString *pic = goods.picture;
        NSArray *picStr = [pic componentsSeparatedByString:@","];
        if (picStr && picStr.count>0) {
            [icon rj_setImageWithPath:picStr.firstObject];
        }
        
        UIView *titleView = RJCreateSimpleView(CGRectMake(0, icon.bottom, KScreenWidth, 90), KTextWhiteColor);
        [self addSubview:titleView];
        
        UIButton *shareBtn = RJCreateTextButton(CGRectMake(KScreenWidth-50, 19, 50, 21), kFontWithSmallestSize, KTextWhiteColor, [UIImage imageNamed:@"shareback001"], @"分享");
        [titleView addSubview:shareBtn];
        [shareBtn addTarget:self action:@selector(shareBtnClick) forControlEvents:UIControlEventTouchUpInside];
        shareBtn.hidden=YES;
        
        UILabel *priceL = RJCreateDefaultLable(CGRectMake(10, shareBtn.top-4, shareBtn.left-20, 29), [UIFont boldSystemFontOfSize:20], [UIColor colorWithHex:@"#B00000"], [NSString stringWithFormat:@"￥%@",goods.sale_price]);
        [titleView addSubview:priceL];
        
        UILabel *nameL = RJCreateDefaultLable(CGRectMake(10, shareBtn.bottom+16, KScreenWidth-20, 20), kFontWithDefaultSize, KTextBlackColor, goods.goods_name);
        nameL.numberOfLines = 0;
        [nameL sizeToFit];
        [titleView addSubview:nameL];
        titleView.height = nameL.bottom+15;
        
        UIView *typeView = RJCreateSimpleView(CGRectMake(0, titleView.bottom+10, KScreenWidth, 40), KTextWhiteColor);
        [self addSubview:typeView];
        [typeView addSubview:RJCreateDefaultLable(CGRectMake(10, 10, 50, 20), kFontWithSmallestSize, KTextGrayColor, @"已选")];
        [typeView addSubview:RJCreateSimpleImageView(CGRectMake(KScreenWidth-17, 14, 7, 12), [UIImage imageNamed:@"come001"])];
        UILabel *typeL = RJCreateDefaultLable(CGRectMake(50, 10, KScreenWidth-77, 20), kFontWithSmallSize, KTextDarkColor, @"请选择规格");
        self.typeLabel = typeL;
        [typeView addSubview:typeL];
        UIButton *typebtn = [UIButton buttonWithType:UIButtonTypeCustom];
        typebtn.frame = typeView.bounds;
        [typeView addSubview:typebtn];
        [typebtn addTarget:self action:@selector(typeBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *addressView = RJCreateSimpleView(CGRectMake(0, typeView.bottom+1, KScreenWidth, 40), KTextWhiteColor);
        [self addSubview:addressView];
        [addressView addSubview:RJCreateDefaultLable(CGRectMake(10, 10, 50, 20), kFontWithSmallestSize, KTextGrayColor, @"送至")];
        [addressView addSubview:RJCreateSimpleImageView(CGRectMake(KScreenWidth-17, 14, 7, 12), [UIImage imageNamed:@"come001"])];
        UILabel *addressL = RJCreateDefaultLable(CGRectMake(50, 10, KScreenWidth-77, 20), kFontWithSmallSize, KTextDarkColor, @"请选择地址");
        self.addressLabel = addressL;
        [addressView addSubview:addressL];
        UIButton *addbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addbtn.frame = addressView.bounds;
        [addressView addSubview:addbtn];
        [addbtn addTarget:self action:@selector(addBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIView *shopView = RJCreateSimpleView(CGRectMake(0, addressView.bottom+10, KScreenWidth, 71), KTextWhiteColor);
        [self addSubview:shopView];
        
        UIImageView *shopImg = RJCreateSimpleImageView(CGRectMake(10, 13, 45, 45), nil);
        [shopView addSubview:shopImg];
        shopImg.backgroundColor = kViewControllerBgColor;
        [shopImg rj_setImageWithPath:goods.photo placeholderImage:KDefaultImg];
        
        UILabel *shopTitleL = RJCreateDefaultLable(CGRectMake(shopImg.right+10, 4+shopImg.top, KScreenWidth-20-shopImg.right, 17), kFontWithSmallSize, KTextDarkColor, goods.parts_name);
        [shopView addSubview:shopTitleL];
        
        UILabel *shopAdresL = RJCreateDefaultLable(CGRectMake(shopTitleL.left, shopTitleL.bottom+5, shopTitleL.width, 15), kFontWithSmallestSize, KTextGrayColor, goods.parts_address);
        [shopView addSubview:shopAdresL];
        
        UIView *detailView = RJCreateSimpleView(CGRectMake(0, shopView.bottom+10, KScreenWidth, 40), KTextWhiteColor);
        [self addSubview:detailView];
        UIImageView *imgView = RJCreateSimpleImageView(CGRectMake(0, 0, 164, 8), [UIImage imageNamed:@"title001"]);
        imgView.center = CGPointMake(KScreenWidth/2, 20);
        [detailView addSubview:imgView];
        UILabel *detL = RJCreateLable(CGRectMake(0, 0, 100, 40), kFontWithDefaultSize, KTextDarkColor, NSTextAlignmentCenter, @"商品详情");
        [detailView addSubview:detL];
        detL.centerX = KScreenWidth/2.0;
        
        self.size = CGSizeMake(KScreenWidth, detailView.bottom);
        
    }
    return self;
}
- (void)typeBtnClick {
    if (self.goodsBtnBlock) {
        self.goodsBtnBlock(0);
    }
}
- (void)addBtnClick {
    if (self.goodsBtnBlock) {
        self.goodsBtnBlock(1);
    }
}

- (void)shareBtnClick {
    if (self.goodsBtnBlock) {
        self.goodsBtnBlock(2);
    }
}

@end
