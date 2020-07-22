//
#import "ShopOrderAddressView.h"
#import "AddressModel.h"

@interface ShopOrderAddressView ()
@property(nonatomic, assign)BOOL loadMainView;
@property(nonatomic, weak)UILabel *nameL;
@property(nonatomic, weak)UILabel *phoneL;
@property(nonatomic, weak)UILabel *addressL;
@property(nonatomic, weak)UILabel *addL;
@end

@implementation ShopOrderAddressView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self createMainView];
}

- (void)setAddressModel:(AddressModel *)addressModel {
    _addressModel = addressModel;
    if (addressModel) {
        self.nameL.text = addressModel.consigner;
        self.phoneL.text = addressModel.mobile;
        self.addressL.text = addressModel.address;
        self.addL.hidden = YES;
    } else {
        self.addL.hidden = NO;
        self.nameL.text = self.phoneL.text = self.addressL.text = nil;
    }
}

- (void)createMainView {
    if (self.loadMainView) {
        return;
    }
    self.loadMainView = YES;
    self.size=CGSizeMake(KScreenWidth, 70);
    self.backgroundColor = KTextWhiteColor;
    
    UIImageView *come = RJCreateSimpleImageView(CGRectMake(KScreenWidth-17, 25, 7, 12), [UIImage imageNamed:@"come001"]);
    [self addSubview:come];
    
    UILabel *phoneL = RJCreateLable(CGRectMake(come.left-10-90, 15, 90, 16), kFont(13), KTextDarkColor, NSTextAlignmentRight, @"");
    self.phoneL = phoneL;
    [self addSubview:phoneL];
    
    UILabel *titleL=RJCreateDefaultLable(CGRectMake(10, 14, phoneL.left-20, 17), kFontWithSmallSize, KTextDarkColor, @"");
    [self addSubview:titleL];
    self.nameL = titleL;
    
    UILabel *infoL=RJCreateDefaultLable(CGRectMake(10, 2+titleL.bottom, come.left-20, 15), kFontWithSmallestSize, KTextGrayColor, @"");
    [self addSubview:infoL];
    self.addressL = infoL;
    UIImageView *imgView = RJCreateSimpleImageView(CGRectMake(0, 62, KScreenWidth, 8), [UIImage imageNamed:@"sepLine"]);
    imgView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:imgView];
    
    UILabel *addL=RJCreateLable(CGRectMake(10, 10, KScreenWidth-30, 42), kFontWithDefaultSize, KTextDarkColor, NSTextAlignmentCenter, @"请添加地址");
    [self addSubview:addL];
    self.addL = addL;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, KScreenWidth, 62);
    [self addSubview:btn];
    [btn addTarget:self action:@selector(pushToAddressList) forControlEvents:UIControlEventTouchUpInside];
}



- (void)pushToAddressList {
    if (self.addressListBlock) {
        self.addressListBlock();
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self createMainView];
    }
    return self;
}

@end
