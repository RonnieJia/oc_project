
#import "LoginViews.h"

@implementation LoginViews


- (instancetype)init {
    self = [[NSBundle mainBundle] loadNibNamed:@"LoginViews" owner:nil options:nil].lastObject;
    if (self) {
        self.frame = CGRectMake(0, 0, KScreenWidth, KAUTOSIZE(210)+350+20);
        self.clipsToBounds = YES;
        self.loginBtn.layer.cornerRadius = 20;
        self.loginBtn.clipsToBounds = self.regisBtn.clipsToBounds = YES;
        self.userName.keyType = UIKeyboardTypeNumberPad;
    }
    return self;
}

//- (void)textFieldDidChanged:(UITextField *)tf {
//    
//}
- (IBAction)buttonAction:(UIButton *)sender {
    [self endEditing:YES];
    if (self.loginBlock) {
        self.loginBlock(sender.tag);
    }
}


@end
