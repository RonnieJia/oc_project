

#import "ShopOrderInfoItem.h"
#import "Masonry.h"

@interface ShopOrderInfoItem ()
@property(nonatomic, assign)BOOL loadMainView;
@end

@implementation ShopOrderInfoItem


- (void)awakeFromNib {
    [super awakeFromNib];
    [self createMainView];
}

- (void)createMainView {
    if (self.loadMainView) {
        return;
    }
    self.loadMainView = YES;
    self.size=CGSizeMake(KScreenWidth, 30);
    self.backgroundColor = KTextWhiteColor;
    [self addSubview:self.titleLabel];
    [self addSubview:self.infoLabel];
    self.infoLabel.frame = CGRectMake(self.titleLabel.right+5, 7, KScreenWidth-15-self.titleLabel.right, 16);
}

- (void)setInfo:(NSDictionary *)info {
    _info = info;
    self.titleLabel.text = StringForKeyInUnserializedJSONDic(info, @"title");
    self.infoLabel.text = StringForKeyInUnserializedJSONDic(info, @"info");
    [self.infoLabel sizeToFit];
    self.infoLabel.width = KScreenWidth-15-self.titleLabel.right;
    if (self.infoLabel.height<16) {
        self.infoLabel.height = 16;
    }
    self.height = self.infoLabel.height+14;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self createMainView];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel=RJCreateDefaultLable(CGRectMake(10, 7, 100, 16), kFontWithSmallSize, KTextDarkColor, nil);
    }
    return _titleLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel=RJCreateDefaultLable(CGRectZero, kFontWithSmallSize, KTextDarkColor, nil);
        _infoLabel.textAlignment = NSTextAlignmentRight;
        _infoLabel.numberOfLines = 0;
    }
    return _infoLabel;
}

@end
