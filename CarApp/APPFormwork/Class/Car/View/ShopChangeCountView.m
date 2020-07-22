
#import "ShopChangeCountView.h"
#import "Masonry.h"


@implementation ShopChangeCountView
- (void)awakeFromNib {
    [super awakeFromNib];
    [self createMainView];
}

- (void)createMainView {
    self.backgroundColor = [UIColor clearColor];
    if (!self.reduceBtn) {
        self.reduceBtn = RJCreateImageButton(CGRectZero, nil, nil);
        [self.reduceBtn setBackgroundImage:[UIImage imageNamed:@"reducenum001"] forState:UIControlStateNormal];
        [self.reduceBtn setBackgroundImage:[UIImage imageNamed:@"reducenum002"] forState:UIControlStateDisabled];
        [self addSubview:self.reduceBtn];
        self.reduceBtn.enabled = NO;
        [self.reduceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.width.and.height.mas_equalTo(22);
        }];
    }
    
    if (!self.addBtn) {
        self.addBtn = RJCreateImageButton(CGRectZero, nil, nil);
        [self.addBtn setBackgroundImage:[UIImage imageNamed:@"addnum"] forState:UIControlStateNormal];
        [self addSubview:self.addBtn];
        [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right);
            make.top.mas_equalTo(0);
            make.width.and.height.mas_equalTo(22);
        }];
    }
    
    if (!self.countTF) {
        self.countTF = RJCreateTextField(CGRectZero, kFontWithSmallestSize, KTextBlackColor, nil, nil, nil, nil, NO, nil, @"1");
        [self addSubview:self.countTF];
        self.countTF.textAlignment = NSTextAlignmentCenter;
        self.countTF.keyboardType = UIKeyboardTypeNumberPad;
        [self.countTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.reduceBtn.mas_right).offset(2);
            make.right.equalTo(self.addBtn.mas_left).offset(-2);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(22);
        }];
    }
}

- (void)setNum:(NSInteger)num {
    _num = num;
    self.countTF.text = [NSString stringWithFormat:@"%zd",num];
    if (num == 0) {
        _num = 1;
        self.countTF.text = @"1";
        self.reduceBtn.enabled=NO;
    } else if (num>999) {
        _num = 999;
        self.countTF.text = @"999";
        self.reduceBtn.enabled=YES;
    } else if (num == 1) {
        self.reduceBtn.enabled = NO;
    } else {
        self.reduceBtn.enabled = YES;
    }
}
@end
