//
#import "SkuChooseView.h"
#import "ShopGoodsModel.h"
#import "NSString+Code.h"

@interface SkuButton : UIButton
@property(nonatomic, strong)SkuModel *sku;
@end
@implementation SkuButton

+ (SkuButton *)buttonWithFrame:(CGRect)frame sku:(SkuModel *)sku {
    SkuButton *btn = [SkuButton buttonWithType:UIButtonTypeCustom];
    btn.sku = sku;
    btn.frame = frame;
    btn.layer.borderColor = kTextBlueColor.CGColor;
    btn.layer.cornerRadius = 5;
    btn.clipsToBounds = YES;
    btn.adjustsImageWhenHighlighted=NO;
    [btn setTitle:sku.sku_name forState:UIControlStateNormal];
    [btn setTitleColor:KTextBlackColor forState:UIControlStateNormal];
    if (sku.stock<=0) {
        [btn setTitleColor:KTextGrayColor forState:UIControlStateNormal];
    }
    [btn setTitleColor:kTextBlueColor forState:UIControlStateSelected];
    [btn setBackgroundImage:createImageWithColor(KSepLineColor) forState:UIControlStateNormal];
    [btn setBackgroundImage:createImageWithColor(KTextWhiteColor) forState:UIControlStateSelected];
    btn.titleLabel.font = kFontWithSmallSize;
    [btn sizeToFit];
    btn.width = btn.width+20;
    btn.height = 28;
    
    return btn;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.layer.borderWidth = 1;
    } else {
        self.layer.borderWidth = 0;
    }
}

@end




@interface SkuChooseView ()
@property(nonatomic, weak)UIView *contentView;
@property(nonatomic, strong)ShopGoodsModel *model;
@property(nonatomic, weak)UIImageView *iconImgView;
@property(nonatomic, weak)UILabel *priceLabel;
@property(nonatomic, weak)UILabel *stockLabel;
@property(nonatomic, weak)UIScrollView *skuScrollView;
@property(nonatomic, weak)UIView *skuContentView;
@property(nonatomic, weak)UIView *bottomView;
@property(nonatomic, weak)UITextField *numLabel;
@property(nonatomic, weak)SkuButton *selectSkuBtn;
@property(nonatomic, weak)UIButton *reduceBtn;

@property(nonatomic, assign)NSInteger num;

@end

@implementation SkuChooseView
+ (instancetype)sharedInstance {
    static SkuChooseView *view = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        view = [[SkuChooseView alloc] init];
    });
    return view;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [KTextBlackColor colorWithAlphaComponent:0.3];
        self.num=1;
        [self createMainView];
        //注册键盘出现的通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardWillShowNotification object:nil];
        //注册键盘消失的通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)tapgestureAction {
    if ([self.numLabel isFirstResponder]) {
        [self.numLabel resignFirstResponder];
    } else {
        [self closeSkuView];
    }
}

- (void)closeSkuView {
    [self removeFromSuperview];
}

- (void)skuButtonClick:(SkuButton *)btn {
    if (btn.selected) {
        return;
    }
    SkuModel *model = btn.sku;
    if (model.stock<=0) {
        ShowAutoHideMBProgressHUD(self, @"库存不足");
        return;
    }
    if (self.block) {
        self.block(model.sku_name);
    }
    self.stockLabel.text = [NSString stringWithFormat:@"库存%zd件",model.stock];
    if (self.selectSkuBtn) {
        self.selectSkuBtn.selected = NO;     }
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@",[model.sale_price priceNum]];
    btn.selected = YES;
    self.selectSkuBtn = btn;
}

- (void)sureAddCart {
    if (self.chooseType) {
        self.chooseType = NO;
        [self closeSkuView];
        return;
    }
    if (self.model.sku.count > 0 && !self.selectSkuBtn) {
        ShowAutoHideMBProgressHUD(self, @"请选择规格");
        return;
    }
    SkuModel *sku = self.selectSkuBtn.sku;
    if (self.buyNow) {
        [self closeSkuView];
        if (self.buyNowCompletion) {
            self.buyNowCompletion(self.model, self.num, sku);
        }
        return;
    }
    WaittingMBProgressHUD(self, @"");
    weakify(self);
    [kRJHTTPClient addCart:self.model.goods_id sku:sku.sku_id num:self.num completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            SuccessMBProgressHUD(weakSelf, response.message);
            if (weakSelf.addCartCompletion) {
                weakSelf.addCartCompletion(weakSelf.model, weakSelf.num);
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf closeSkuView];
            });
        } else {
            FailedMBProgressHUD(weakSelf, response.message);
        }
    }];
}

- (void)numBtnClick:(UIButton *)btn {
    if (btn.tag == 1) {
        self.num++;
    } else {
        if (self.num == 1) {
            btn.enabled = NO;
            return;
        }
        self.num--;
    }
    self.reduceBtn.enabled = self.num>1;
    self.numLabel.text = [NSString stringWithFormat:@"%zd",self.num];
}

- (void)showGoods:(ShopGoodsModel *)model buy:(BOOL)buy {
    self.buyNow=buy;
    if (![self.model.goods_id isEqualToString:model.goods_id]) {// 再次显示不同的商品
        self.model = model;
        self.num=1;
        self.numLabel.text=@"1";
        self.selectSkuBtn = nil;
        [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",KImgBaseUrl,model.picture]] placeholderImage:KDefaultImg];
//        [self.iconImgView rj_setImageWithPath:model.picture placeholderImage:KDefaultImg];
        self.priceLabel.text = [NSString stringWithFormat:@"￥%@",[model.sale_price priceNum]];
        NSInteger totalStock = 0;
        for (SkuModel *sku in model.sku) {
            totalStock += sku.stock;
        }
        self.stockLabel.text = [NSString stringWithFormat:@"库存%zd件",totalStock];
        if (self.skuContentView) {
            [self.skuContentView removeFromSuperview];
            self.skuContentView = nil;
        }
        UIView *skuContentView = RJCreateSimpleView(self.skuScrollView.bounds, KTextWhiteColor);
        self.skuContentView = skuContentView;
        [self.skuScrollView addSubview:skuContentView];
        CGFloat left = 13;
        CGFloat top = 10;
        for (int i = 0; i<model.sku.count; i++) {
            SkuModel *sModel = model.sku[i];
            if (i==0) {
                UILabel *l = RJCreateDefaultLable(CGRectMake(13, top, KScreenWidth-30, 16), kFontWithSmallSize, KTextBlackColor, @"规格分类");
                [skuContentView addSubview:l];
                top = l.bottom+10;
            }
            SkuButton *btn = [SkuButton buttonWithFrame:CGRectMake(left, top, 100, 28) sku:sModel];
            [btn addTarget:self action:@selector(skuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [skuContentView addSubview:btn];
            if (btn.right>KScreenWidth-10) {
                btn.left = 13;
                top = btn.bottom+10;
                btn.top = top;
            }
            left = btn.right+10;
            skuContentView.height = btn.bottom+11;
        }
        
//        for (NSString *key in dict) {
//            NSArray *skuArr = dict[key];
//            for (int i = 0; i<skuArr.count; i++) {
//                SkuModel *sModel = skuArr[i];
//                if (i==0) {
//                    left = 13;
//                    UILabel *l = RJCreateDefaultLable(CGRectMake(13, top, KScreenWidth-30, 16), kFontWithSmallSize, KTextBlackColor, sModel.spec_name);
//                    [skuContentView addSubview:l];
//                    top = l.bottom+10;
//                }
//                SkuButton *btn = [SkuButton buttonWithFrame:CGRectMake(left, top, 100, 28) sku:sModel];
//                [btn addTarget:self action:@selector(skuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//                [skuContentView addSubview:btn];
//                if (btn.right>KScreenWidth-10) {
//                    btn.left = 13;
//                    top = btn.bottom+10;
//                    btn.top = top;
//                }
//                left = btn.right+10;
//                skuContentView.height = btn.bottom+11;
//                if (i == skuArr.count-1) {
//                    top = btn.bottom+15;
//                }
//            }
//        }
        
        if (skuContentView.height<KScreenHeight-340-StatusBarHeight-kIPhoneXBH) {
            self.skuScrollView.height = skuContentView.height;
        } else {
            self.skuScrollView.height = KScreenHeight-340-StatusBarHeight-kIPhoneXBH;
        }
        self.skuScrollView.contentSize = CGSizeMake(KScreenWidth, skuContentView.height);
        self.bottomView.top = self.skuScrollView.bottom;
        self.contentView.height = self.bottomView.bottom+kIPhoneXBH+20;
        self.contentView.bottom = KScreenHeight+10;
    }
    [KKeyWindow addSubview:self];
}

- (void)createMainView {
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapgestureAction)]];
    UIView *contentView = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 340+kIPhoneXBH+10), KTextWhiteColor);
    contentView.bottom = KScreenWidth+10;
    [contentView addGestureRecognizer:[UITapGestureRecognizer new]];
    contentView.layer.cornerRadius = 5;
    contentView.clipsToBounds = YES;
    [self addSubview:contentView];
    self.contentView = contentView;
    
    UIImageView *iconImgVIew = RJCreateImageView(CGRectMake(13, 12, 113, 113), KSepLineColor, nil, 4);
    iconImgVIew.clipsToBounds = YES;
    [contentView addSubview:iconImgVIew];
    self.iconImgView = iconImgVIew;
    
    UIButton *closeBtn = RJCreateImageButton(CGRectMake(KScreenWidth-13-17-13, 0, 17+26, 17+26), [UIImage imageNamed:@"close002"], nil);
    [contentView addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(closeSkuView) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *priceL = RJCreateDefaultLable(CGRectMake(iconImgVIew.right+10, iconImgVIew.top+10, closeBtn.left-15-iconImgVIew.right, 30), kFont(24), [UIColor colorWithHex:@"#e02e24"], nil);
    [contentView addSubview:priceL];
    self.priceLabel = priceL;
    
    UILabel *stockL = RJCreateDefaultLable(CGRectMake(priceL.left, priceL.bottom+10, KScreenWidth-13-priceL.left, 15), kFont(13), [UIColor colorWithHex:@"#999999"], nil);
    [contentView addSubview:stockL];
    self.stockLabel = stockL;
    
    UILabel *skuL = RJCreateDefaultLable(CGRectMake(stockL.left, stockL.bottom+15, stockL.width, 16), kFontWithSmallSize, KTextBlackColor, @"选择 规格");
    [contentView addSubview:skuL];
    
//    UILabel *skuCateL = RJCreateDefaultLable(CGRectMake(13, iconImgVIew.bottom+25, 100, 16), kFontWithSmallSize, KTextBlackColor, @"规格分类");
//    [contentView addSubview:skuCateL];
    
    UIScrollView *scroView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, iconImgVIew.bottom+10, KScreenWidth, 80)];
    [contentView addSubview:scroView];
    self.skuScrollView = scroView;
    
    UIView *bottomView = RJCreateSimpleView(CGRectMake(0, scroView.bottom, KScreenWidth, 115), KTextWhiteColor);
    [contentView addSubview:bottomView];
    self.bottomView = bottomView;
    
    [bottomView addSubview:RJCreateSimpleView(CGRectMake(13, 0, KScreenWidth-26, .8), KSepLineColor)];
    
    UILabel *numL = RJCreateDefaultLable(CGRectMake(13, 1, 100, 50), kFontWithSmallSize, KTextBlackColor, @"购买数量");
    [bottomView addSubview:numL];
    
    UIButton *addBtn = RJCreateImageButton(CGRectMake(KScreenWidth-13-18, 0, 18, 18), [UIImage imageNamed:@"addnum"], nil);
    [bottomView addSubview:addBtn];
    addBtn.centerY = numL.centerY;
    addBtn.tag = 1;
    [addBtn addTarget:self action:@selector(numBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UITextField *numTF = [[UITextField alloc] initWithFrame:CGRectMake(addBtn.left-30, addBtn.top, 25, addBtn.height)];
    [bottomView addSubview:numTF];
    numTF.font = kFontWithSmallSize;
    numTF.textAlignment = NSTextAlignmentCenter;
    numTF.textColor = KTextBlackColor;
    numTF.text=@"1";
    numTF.keyboardType = UIKeyboardTypeNumberPad;
    numTF.delegate = self;
    UILabel *numberLabel = RJCreateLable(CGRectMake(addBtn.left-30, addBtn.top, 25, addBtn.height), kFontWithSmallSize, KTextBlackColor, NSTextAlignmentCenter, @"1");
    numberLabel.adjustsFontSizeToFitWidth = YES;
//    [bottomView addSubview:numberLabel];
    self.numLabel = numTF;
    
    UIButton *reduceBtn = RJCreateImageButton(CGRectMake(numberLabel.left-5-18, addBtn.top, 18, 18), [UIImage imageNamed:@"reducenum001"], nil);
    [reduceBtn setImage:[UIImage imageNamed:@"reducenum002"] forState:UIControlStateDisabled];
    [bottomView addSubview:reduceBtn];
    [reduceBtn addTarget:self action:@selector(numBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.reduceBtn = reduceBtn;
    reduceBtn.enabled = NO;
    
    [bottomView addSubview:RJCreateSimpleView(CGRectMake(13, numL.bottom, KScreenWidth-26, 0.8), KSepLineColor)];
    
    UIButton *sureBtn = RJCreateButton(CGRectMake(13, numL.bottom+11, KScreenWidth-26, 43), kFontWithDefaultSize, KTextWhiteColor, KThemeColor, nil, nil, @"确定");
    sureBtn.adjustsImageWhenHighlighted=NO;
    [bottomView addSubview:sureBtn];
    [sureBtn addTarget:self action:@selector(sureAddCart) forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string && [string integerValue]>=0) {
        
    } else {
        return NO;
    }
    return YES;
}

- (void)textFieldChangedEditing:(UITextField *)textField {
    self.num = [textField.text integerValue];
    self.reduceBtn.enabled = self.num>1;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

#pragma mark - 键盘弹出及收起
- (void)keyboardWasShown:(NSNotification *)noti {
    CGFloat keyboardH = FetchKeyBoardHeight(noti);
    self.contentView.bottom=KScreenHeight-keyboardH+10;
}

- (void)keyboardWillBeHidden:(NSNotification *)noti {
    self.contentView.bottom = KScreenHeight+10;
}
@end
