
#import <UIKit/UIKit.h>
#import "SHNRCInputView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LossPasswordView : UIView
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet SHNRCInputView *mobile;
@property (weak, nonatomic) IBOutlet SHNRCInputView *code;
@property (weak, nonatomic) IBOutlet SHNRCInputView *pwd;
@property (weak, nonatomic) IBOutlet SHNRCInputView *pwd2;

@property(nonatomic,copy)void(^losspwdBlock)(NSInteger index);
@end

NS_ASSUME_NONNULL_END
