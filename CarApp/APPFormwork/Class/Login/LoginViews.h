
#import <UIKit/UIKit.h>
#import "SHNRCInputView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoginViews : UIView<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UIButton *regisBtn;
@property (weak, nonatomic) IBOutlet UIButton *lossPwdBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet SHNRCInputView *userName;
@property (weak, nonatomic) IBOutlet SHNRCInputView *pwd;

@property(nonatomic, copy)void(^loginBlock)(NSInteger index);
@end

NS_ASSUME_NONNULL_END
