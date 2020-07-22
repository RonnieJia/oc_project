//

#import "GoodsDetailBottomView.h"
#import "ShopGoodsModel.h"

@implementation GoodsDetailBottomView

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, KScreenHeight-46-kIPhoneXBH, KScreenWidth, 46+kIPhoneXBH)];
    if (self) {
        self.backgroundColor = KTextWhiteColor;
        NSArray *imgsArr = @[@"iphone004",@"link004",@"collect010"];
        NSArray *titlesArr = @[@"联系",@"客服",@"收藏"];

        CGFloat itemW = 45;
        if (KScreenWidth<321) {
            itemW = 40;
        }
        for (int i = 0; i<3; i++) {
            RJButton *item = [RJButton buttonWithFrame:CGRectMake(5+i*(5+itemW), 4, itemW, 38) title:titlesArr[i] titleColor:KTextGrayColor titleFont:kFontWithSmallestSize image:[UIImage imageNamed:imgsArr[i]] selectImage:i==2?[UIImage imageNamed:@"collect011"]:nil target:self selector:NULL];
            item.margin = 5;
            [item addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            item.tag = 100+i;
            if (i==2) {
                [item setTitle:@"已收藏" forState:UIControlStateSelected];
            }
            item.type = RJButtonTypeTitleBottom;
            [self addSubview:item];
        }
        
        CGFloat wid = (KScreenWidth-12-3*(itemW+5)-5)/2.0;
        if (wid>111) {
            wid = 111;
        }
        
        UIButton *buyBtn = RJCreateTextButton(CGRectMake(KScreenWidth-wid-13, 4, wid, 38), kFontWithSmallSize, KTextWhiteColor, [UIImage imageNamed:@"shareback002"], @"立即购买");
        [self addSubview:buyBtn];
        buyBtn.adjustsImageWhenHighlighted=NO;
        UIButton *cartBtn = RJCreateTextButton(CGRectMake(buyBtn.left-wid, 4, wid, 38), kFontWithSmallSize, KTextWhiteColor, [UIImage imageNamed:@"shopbut001"], @"加入购物车");
        cartBtn.adjustsImageWhenHighlighted=NO;
        [self addSubview:cartBtn];
        cartBtn.tag = 1;
        [buyBtn addTarget:self action:@selector(buyGoods:) forControlEvents:UIControlEventTouchUpInside];
        [cartBtn addTarget:self action:@selector(buyGoods:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setGoodsModel:(ShopGoodsModel *)goodsModel {
    _goodsModel = goodsModel;
    if (goodsModel.is_collection) {
        UIButton *btn = [self viewWithTag:102];
        btn.selected = YES;
    }
}

- (void)buttonAction:(UIButton *)btn {
    if (btn.tag == 102) {// 收藏
        WaittingMBProgressHUD(KKeyWindow, @"");
           weakify(self);
           [kRJHTTPClient collectionGoods:self.goodsModel.goods_id type:!self.goodsModel.is_collection completion:^(WebResponse *response) {
               if (response.code == WebResponseCodeSuccess) {
                   weakSelf.goodsModel.is_collection = !weakSelf.goodsModel.is_collection;
                   btn.selected = weakSelf.goodsModel.is_collection;
                   FinishMBProgressHUD(KKeyWindow);
               } else {
                   FailedMBProgressHUD(KKeyWindow, response.message);
               }
           }];
    } else if (btn.tag == 101 ){
        if (self.serviceChatBlock) {
            self.serviceChatBlock();
        }
    } else if (btn.tag == 100) {
        makePhoneCall(self.goodsModel.parts_phone);
    }
   
}

- (void)buyGoods:(UIButton *)btn {
    if (self.buyGoodsBlock) {
        self.buyGoodsBlock(btn.tag);
    }
}

@end
