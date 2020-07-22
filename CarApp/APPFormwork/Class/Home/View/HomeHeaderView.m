

#import "HomeHeaderView.h"
#import "SDCycleScrollView.h"
#import "SDPhotoBrowser.h"

@interface RJ_HomeItem : UIView
@property(nonatomic, strong)NSString *cla;
@property(nonatomic, strong)NSString *title;
@property(nonatomic, assign)NSInteger count;
@property(nonatomic, weak)UILabel *countLabel;
@property(nonatomic, copy)HomeItemCallBack callBack;
@end

@implementation RJ_HomeItem
- (instancetype)initWithFrame:(CGRect)frame info:(NSDictionary *)info {
    self = [super initWithFrame:frame];
    if (self) {
        self.title = StringForKeyInUnserializedJSONDic(info, @"title");
        self.cla = StringForKeyInUnserializedJSONDic(info, @"cls");
        
        CGFloat margin = 8;
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:StringForKeyInUnserializedJSONDic(info, @"img")]];
        imgView.size = CGSizeMake(43, 43);
        [self addSubview:imgView];
        imgView.centerX = self.width/2.0;
        imgView.top = (self.height - 43 - margin - 16)/2.0;
        
        UILabel *countL = RJCreateLable(CGRectMake(imgView.right-8, imgView.top-8, 16, 16), kFont(10), KTextWhiteColor, NSTextAlignmentCenter, nil);
        countL.clipsToBounds=YES;
        countL.layer.cornerRadius = 8;
        countL.backgroundColor = [UIColor colorWithHex:@"#F54B31"];
        [self addSubview:countL];
        self.countLabel = countL;
        countL.hidden=YES;
        
        UILabel *titleL = RJCreateLable(CGRectMake(0, imgView.bottom+margin, self.width, 16), kFontWithSmallSize, KTextBlackColor, NSTextAlignmentCenter, self.title);
        [self addSubview:titleL];
        
        UIButton *btn = RJCreateButton(self.bounds, nil, nil, nil, nil, nil, nil);
        [self addSubview:btn];
        [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)buttonAction:(UIButton *)btn {
    if (self.callBack) {
        self.callBack(self.tag, self.cla);
    }
}

- (void)setCount:(NSInteger)count {
    _count = count;
    self.countLabel.hidden = count==0;
    self.countLabel.text = [NSString stringWithFormat:@"%zd",count];
}
@end




@interface HomeHeaderView ()<SDCycleScrollViewDelegate,SDPhotoBrowserDelegate>
@property(nonatomic, weak)UILabel *nameLabel;
@property(nonatomic, weak)UILabel *vipLabel;
@property(nonatomic, weak)UIImageView *iconImgView;
@property(nonatomic, weak)UIButton *addressbtn;
@property(nonatomic, weak)UIView *infoView;
@end

@implementation HomeHeaderView
- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = KTextWhiteColor;
        UIImageView *headerBack = RJCreateSimpleImageView(CGRectMake(0, 0, KScreenWidth, KAUTOSIZE(190)+StatusBarHeight), [UIImage imageNamed:@"centerback002"]);
        headerBack.contentMode = UIViewContentModeScaleAspectFill;
        headerBack.userInteractionEnabled = YES;
        [self addSubview:headerBack];
        
        UIView *infoView = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 75), [UIColor clearColor]);
        infoView.centerY = headerBack.height/2.0f;
        [headerBack addSubview:infoView];
        self.infoView = infoView;
        
        UIImageView *iconView = RJCreateSimpleImageView(CGRectMake(13, 0, infoView.height, infoView.height), [UIImage imageNamed:@"face006"]);
        [infoView addSubview:iconView];
        iconView.contentMode = UIViewContentModeScaleAspectFill;
        iconView.layer.cornerRadius = 4;
        iconView.clipsToBounds=YES;
        self.iconImgView = iconView;
        iconView.userInteractionEnabled=YES;
        [iconView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:    @selector(showUserIcon)]];
        
        UIButton *setBtn = RJCreateImageButton(CGRectMake(KScreenWidth-40, 25, 25, 25), [UIImage imageNamed:@"install"], nil);
        [infoView addSubview:setBtn];
        [setBtn addTarget:self action:@selector(setButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *nameL = RJCreateDefaultLable(CGRectMake(iconView.right+10, 10, setBtn.left-iconView.right-20, 25), kFontWithBigSize, KTextWhiteColor, @"");
        [infoView addSubview:nameL];
        self.nameLabel = nameL;
        
        UILabel *vipL = RJCreateLable(CGRectMake(0, 0, 36, 16), kFontWithSmallestSize, KTextWhiteColor, NSTextAlignmentCenter, @"特约");
        [infoView addSubview:vipL];
        vipL.clipsToBounds=YES;
        vipL.layer.cornerRadius = 8;
        vipL.centerY = nameL.centerY;
        vipL.hidden = YES;
        vipL.backgroundColor = [UIColor orangeColor];
        self.vipLabel = vipL;
        
        UIButton *addressBtn = RJCreateButton(CGRectMake(nameL.left, nameL.bottom+5, nameL.width, nameL.height), kFontWithSmallSize, KTextWhiteColor, nil, nil, [UIImage imageNamed:@"position001"], @" ");
        [infoView addSubview:addressBtn];
        addressBtn.contentHorizontalAlignment=1;
        self.addressbtn = addressBtn;
        
        CGFloat wid = (KScreenWidth-10)/4.0f;
        NSArray *infoArr = @[@{@"title":@"店铺资料",
                               @"img":@"centericon301",
                               @"cls":@"ShopInfoViewController"},
                             @{@"title":@"我的钱包",
                               @"img":@"centericon302",
                               @"cls":@"MyWalletViewController"},
                             @{@"title":@"道路救援",
                               @"img":@"centericon201",
                               @"cls":@"RescueNotesViewController"},
                             @{@"title":@"提前预定",
                               @"img":@"centericon202",
                               @"cls":@"ReservationNotesViewController"},
                             @{@"title":@"维修订单",
                               @"img":@"centericon203",
                               @"cls":@"FixNotesViewController"},
                             @{@"title":@"报修记录",
                               @"img":@"centericon204",
                               @"cls":@"RepairNotesViewController"},
                             @{@"title":@"联系平台",
                               @"img":@"centericon205",
                               @"cls":@"ShopInfoViewController"},
                             @{@"title":@"技术支持",
                               @"img":@"centericon206",
                               @"cls":@"ShopInfoViewController"}];
        for (int i = 0; i<8; i++) {
            NSDictionary *dic = infoArr[i];
            RJ_HomeItem *item = [[RJ_HomeItem alloc] initWithFrame:CGRectMake((i%4)*wid+5, headerBack.bottom + 20 + (i/4)*90, wid, 80) info:dic];
            item.tag = i;
            weakify(self);
            item.callBack = ^(NSInteger index, NSString * _Nullable cla) {
                strongify(weakSelf);
                if (strongSelf.headerItemClick) {
                    strongSelf.headerItemClick(index, cla);
                }
            };
            [self addSubview:item];
        }
        self.size = CGSizeMake(KScreenWidth, headerBack.bottom+190);
    }
    return self;
}

- (void)showUserIcon {
    SDPhotoBrowser *photo = [[SDPhotoBrowser alloc] init];
    photo.delegate = self;
    photo.imageCount = 1;
    photo.currentImageIndex = 0;
    photo.sourceImagesContainerView = self.infoView;
    [photo show];
}

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    return self.iconImgView.image;
}

- (void)refreshCount:(NSDictionary *)dic {
    NSInteger rescueNum = IntForKeyInUnserializedJSONDic(dic, @"rescue_sum");// 道路救援
    NSInteger repair = IntForKeyInUnserializedJSONDic(dic, @"repair_sum");//维修订单
    NSInteger book = IntForKeyInUnserializedJSONDic(dic, @"booking_sum");//提前预定
    NSInteger one = IntForKeyInUnserializedJSONDic(dic, @"onerepair_sum");//报修
    NSArray *arr = @[@(rescueNum),@(book),@(repair),@(one)];
    for (int i = 2; i<6; i++) {
        RJ_HomeItem *item = [self viewWithTag:i];
        item.count = [arr[i-2] intValue];
    }
    
    self.nameLabel.width = KScreenWidth-40-self.nameLabel.left;
    self.nameLabel.text = StringForKeyInUnserializedJSONDic(dic, @"r_name");
    NSInteger isVip = IntForKeyInUnserializedJSONDic(dic, @"is_vip");
    if (isVip==1) {
        [self.nameLabel sizeToFit];
        self.nameLabel.height = 25;
        if (self.nameLabel.width>(KScreenWidth-self.nameLabel.left-40-46)) {
            self.nameLabel.width = KScreenWidth-self.nameLabel.left-40-46;
        }
        self.vipLabel.hidden=NO;
        self.vipLabel.left = self.nameLabel.right+10;
    } else {
        self.vipLabel.hidden = YES;
    }
    [self.addressbtn setTitle:[NSString stringWithFormat:@" %@",StringForKeyInUnserializedJSONDic(dic, @"r_address")] forState:UIControlStateNormal];
    [CurrentUserInfo sharedInstance].userIcon = StringForKeyInUnserializedJSONDic(dic, @"r_portrait");
    [self.iconImgView rj_setImageWithPath:StringForKeyInUnserializedJSONDic(dic, @"r_portrait") placeholderImage:KDefaultImg];
}

- (void)setButtonClick {
    if (self.headerItemClick) {
        self.headerItemClick(9, @"SettingViewController");
    }
}
- (void)dealloc {
    NSLog(@"a");
}
@end
