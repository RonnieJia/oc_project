#import "IssueInputView.h"
//#import "RJDatePicker.h"

static CGFloat const kSelfHeight = 45.0f;

@interface IssueInputView()<UITextFieldDelegate>
@property(nonatomic,weak)UIView *sepLine;
@end

@implementation IssueInputView

- (instancetype)initWithY:(CGFloat)y title:(NSString *)title placeholder:(NSString *)place rightText:(NSString *)text {
    self = [super initWithFrame:CGRectMake(0, y, KScreenWidth, kSelfHeight)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setup:title place:place text:text];
    }
    return self;
}

- (void)setup:(NSString *)title place:(NSString *)place text:(NSString *)text {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15, (self.height - 30)/2.0f, self.width-30, 30)];
    textField.font = kFontWithSmallSize;
    textField.textColor = kRGBColor(81, 81, 81);
    textField.placeholder = place;
//    [textField setValue:kRGBColor(138, 138, 138) forKeyPath:@"_placeholderLabel.textColor"];
//    [textField setValue:kFontWithSmallSize forKeyPath:@"_placeholderLabel.font"];
    self.textField = textField;
    [self addSubview:textField];
    
    if (!IsStringEmptyOrNull(title)) {
        if ([title isEqualToString:@"联系电话"] || [title isEqualToString:@"验证码"] || [title isEqualToString:@"手机号"] || [title isEqualToString:@"旧手机"] || [title isEqualToString:@"新手机"] || [title isEqualToString:@"邮编"]) {
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.tag = ([title isEqualToString:@"验证码"] || [title isEqualToString:@"邮编"])?100:101;
            [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        } else if ([title isEqualToString:@"薪资"] || [title isEqualToString:@"控制价"] || [title isEqualToString:@"置顶费用"]) {
            textField.keyboardType = UIKeyboardTypeDecimalPad;
            textField.tag = 102;
            [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        }
        NSString *showTitle = [NSString stringWithFormat:@"%@",title];
        if ([title isEqualToString:@"包年时长"] || [title isEqualToString:@"总金额    "]) {
            showTitle = [NSString stringWithFormat:@"%@    ",title];
        }
        UIView *leftView = RJCreateSimpleView(CGRectMake(0, 0, 80, textField.height), nil);
        
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(0, 0, 100, textField.height) textColor:KTextBlackColor font:kFontWithSmallSize text:showTitle];
        [titleLabel sizeToFit];
        if (titleLabel.width>80) {
            leftView.width = titleLabel.width;
        }
        titleLabel.height = textField.height;
//        titleLabel.width = titleLabel.width + 10;
        [leftView addSubview:titleLabel];
        textField.leftView = leftView;
        textField.leftViewMode = UITextFieldViewModeAlways;
    }
    
    if (text) {
        UILabel *textLabel = [UILabel labelWithFrame:CGRectMake(0, 0, 100, 25) textColor:kRGBColor(81, 81, 81) font:kFontWithSmallSize text:text];
        [textLabel sizeToFit];
        textLabel.height = textField.height;
        textField.rightView = textLabel;
        textField.rightViewMode = UITextFieldViewModeAlways;
    }
    
    UIView *sepLine = [UIView lineWithX:10 Y:self.height-1.0 width:self.width-10];
    sepLine.height = 0.8;
    sepLine.backgroundColor = KSepLineColor;
    self.sepLine = sepLine;
    [self addSubview:sepLine];
    
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.tag == 101) {// 联系电话
        if (textField.text.length > 11) {
            textField.text = [textField.text substringToIndex:11];
        }
    } else if(textField.tag == 100) {
        if (textField.text.length > 6) {
            textField.text = [textField.text substringToIndex:6];
        }
    } else if (textField.tag == 102) {
        NSRange range = [textField.text rangeOfString:@"."];
        if (range.location != NSNotFound) {// 限制小数点后只能输入两位
            if (textField.text.length > (range.location + 3)) {
                textField.text = [textField.text substringToIndex:range.location + 3];
            }
        }
        
        if ([textField.text floatValue] > 99999999) {// 限制最大输入的数字是99999999
            if ([textField.text rangeOfString:@"."].location == NSNotFound) {
                textField.text = @"99999999";
            } else {
                textField.text = @"99999999.0";
            }
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title placeholder:(NSString *)place rightView:(UIView *)view {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setup:title place:place text:nil];
        self.layer.cornerRadius = 6.0f;
        if (view) {
            self.textField.rightView = view;
            self.textField.rightViewMode = UITextFieldViewModeAlways;
        }
    }
    return self;

}

- (instancetype)initWithY:(CGFloat)y title:(NSString *)title placeholder:(NSString *)place rightView:(UIView *)view {
    self = [super initWithFrame:CGRectMake(0, y, KScreenWidth, kSelfHeight)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setup:title place:place text:nil];
        if (view) {
            self.textField.rightView = view;
            self.textField.rightViewMode = UITextFieldViewModeAlways;
        }
    }
    return self;
}

@end
