
#import "LossPasswordView.h"

@implementation LossPasswordView


- (instancetype)init {
    self = [[NSBundle mainBundle] loadNibNamed:@"LossPasswordView" owner:nil options:nil].lastObject;
    if (self) {
        self.frame = CGRectMake(0, 0, KScreenWidth, KAUTOSIZE(210)+405);
        self.clipsToBounds = YES;
        self.mobile.keyType = UIKeyboardTypeNumberPad;
        self.code.keyType = UIKeyboardTypeNumberPad;
        self.sureBtn.layer.cornerRadius = 20;
        
    }
    return self;
}

- (void)textFieldDidChanged:(UITextField *)tf {
   
}
- (IBAction)buttonAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (self.losspwdBlock) {
        self.losspwdBlock(btn.tag);
    }
}

@end
