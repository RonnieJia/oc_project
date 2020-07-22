#import <UIKit/UIKit.h>
#import "SHNRCInputView.h"

@interface RegisContentView : UIView

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UIButton *regisBtn;

@property (weak, nonatomic) IBOutlet SHNRCInputView *mobile;
@property (weak, nonatomic) IBOutlet SHNRCInputView *code;
@property (weak, nonatomic) IBOutlet SHNRCInputView *pwd;
@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;
@property (weak, nonatomic) IBOutlet UIButton *agreementBtn;


@property(nonatomic, copy)void(^regisBlock)(NSInteger index);
@end
