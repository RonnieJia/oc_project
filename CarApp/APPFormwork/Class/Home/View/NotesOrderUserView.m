

#import "NotesOrderUserView.h"
@interface NotesOrderUserView ()
@property(nonatomic, assign)BOOL loadMainView;
@property (nonatomic, weak) UILabel *detailLabel;
@property (nonatomic, weak) UIButton *actionBtn;
@property(nonatomic, weak)UIImageView *comeImgView;
@end
@implementation NotesOrderUserView
- (void)awakeFromNib {
    [super awakeFromNib];
    [self createMainView];
}

- (void)createMainView {
    if (self.loadMainView) {
        return;
    }
    self.loadMainView = YES;
    self.size=CGSizeMake(KScreenWidth, 70);
    self.backgroundColor = KTextWhiteColor;
    
    UIImageView *come = RJCreateSimpleImageView(CGRectMake(KScreenWidth-17, 25, 7, 12), [UIImage imageNamed:@"come001"]);
    self.comeImgView = come;
    [self addSubview:come];
    UILabel *label = RJCreateLable(CGRectMake(come.left-100, 20, 90, 22), kFontWithSmallSize, KTextDarkColor, NSTextAlignmentRight, @"查看车辆详情");
    [self addSubview:label];
    self.detailLabel = label;
    
    UILabel *titleL=RJCreateDefaultLable(CGRectMake(10, 14, label.left-20, 17), kFontWithSmallSize, KTextDarkColor, @"");
    self.nameLabel = titleL;
    [self addSubview:titleL];
    
    UILabel *infoL=RJCreateDefaultLable(CGRectMake(10, 2+titleL.bottom, label.left-20, 15), kFontWithSmallestSize, KTextGrayColor, @"");
    self.infoLabel = infoL;
    [self addSubview:infoL];
    UIImageView *imgView = RJCreateSimpleImageView(CGRectMake(0, 62, KScreenWidth, 8), [UIImage imageNamed:@"sepLine"]);
    imgView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:imgView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(0, 0, KScreenWidth, 62);
    [self addSubview:btn];
    [btn addTarget:self action:@selector(carDetailBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.actionBtn = btn;
}

- (void)setHiddenDetail:(BOOL)hiddenDetail {
    _hiddenDetail  = hiddenDetail;
    if (hiddenDetail) {
        self.actionBtn.hidden=YES;
        self.detailLabel.hidden = YES;
        self.nameLabel.width = self.infoLabel.width = KScreenWidth-20;
        self.comeImgView.hidden=YES;
    }
}

- (void)carDetailBtnClick {
    if (self.pushCarInfoBlock) {
        self.pushCarInfoBlock();
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
