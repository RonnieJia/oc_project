
#import "SHNRCInputView.h"
#import "Masonry.h"

@interface SHNRCInputView ()<UITextFieldDelegate>
@property(nonatomic, weak)UIImageView *iconImgView;
@property(nonatomic, assign)BOOL add;
@end

@implementation SHNRCInputView

- (void)awakeFromNib {
    [super awakeFromNib];
    if (!self.add) {
        self.backgroundColor = [UIColor colorWithHex:@"#f4f4f4"];
        self.layer.cornerRadius = 20;
        self.layer.borderColor = KSepLineColor.CGColor;
        self.layer.borderWidth = 1;
        /*
        self.layer.shadowColor = KTextDarkColor.CGColor;
        // 阴影偏移，默认(0, -3)
        self.layer.shadowOffset = CGSizeMake(0,3);
        // 阴影透明度，默认0
        self.layer.shadowOpacity = 0.3;
        // 阴影半径，默认3
        self.layer.shadowRadius = 2;
        */
        UIImageView *imgView = RJCreateSimpleImageView(CGRectZero, [UIImage imageNamed:self.image]);
        imgView.contentMode = UIViewContentModeCenter;
        [self addSubview:imgView];
        self.iconImgView = imgView;
        
        UIView *sepLine = RJCreateSimpleView(CGRectZero, KTextGrayColor);
        [self addSubview:sepLine];
        
        UITextField *textField = RJCreateTextField(CGRectZero, kFontWithSmallSize, KTextBlackColor, nil, nil, nil, nil, NO, self.placeholder, nil);
        textField.secureTextEntry = self.secure;
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
        self.textField = textField;
        [self addSubview:textField];
        
        if (self.haveCodeBtn) {
            UIView *rightView = RJCreateSimpleView(CGRectMake(0, 0, 85, 45), nil);
            UIButton *codeBtn = RJCreateButton(CGRectMake(5, 10, 75, 25), kFontWithSmallestSize, KTextWhiteColor, nil, nil, nil, @"获取验证码");
            [codeBtn addTarget:self action:@selector(codeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            codeBtn.layer.cornerRadius = 12.5;
            codeBtn.backgroundColor = KThemeColor;
//            codeBtn.layer.borderWidth = 1;
//            codeBtn.layer.borderColor = KThemeColor.CGColor;
            [rightView addSubview:codeBtn];
            textField.rightView = rightView;
            textField.rightViewMode = UITextFieldViewModeAlways;
            self.codeBtn = codeBtn;
        }
        
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(25);
        }];
        
        [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imgView.mas_right).offset(6);
            make.top.mas_equalTo(12);
            make.bottom.mas_equalTo(-12);
            make.width.mas_equalTo(1);
        }];
        
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(sepLine.mas_right).offset(6);
            make.top.bottom.mas_equalTo(0);
            make.right.mas_equalTo(-10);
        }];
        
        self.add = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)codeBtnClick:(UIButton *)btn {
    if (self.codeBtnActionBlock)
        self.codeBtnActionBlock(btn);
}

- (void)setKeyType:(UIKeyboardType)keyType {
    _keyType = keyType;
    self.textField.keyboardType = keyType;
}


- (NSString *)text {
    return self.textField.text;
}
@end
