#import "RegisContentView.h"

@interface RegisContentView()

@end

@implementation RegisContentView

- (instancetype)init {
    self = [[NSBundle mainBundle] loadNibNamed:@"RegisContentView" owner:nil options:nil].lastObject;
    if (self) {
        self.frame = CGRectMake(0, 0, KScreenWidth, KAUTOSIZE(210)+370);
        self.clipsToBounds = YES;
        self.regisBtn.layer.cornerRadius = 20;
        self.mobile.keyType = UIKeyboardTypeNumberPad;
        self.code.keyType = UIKeyboardTypeNumberPad;
    }
    return self;
}

- (IBAction)buttonAction:(UIButton *)sender {
    if (sender.tag == 5) {
        sender.selected = !sender.isSelected;
        return;
    }
    if (self.regisBlock) {
        self.regisBlock(sender.tag);
    }
}

@end
