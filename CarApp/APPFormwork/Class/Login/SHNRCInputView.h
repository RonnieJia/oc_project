//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SHNRCInputView : UIView
@property (nonatomic, strong) IBInspectable NSString *placeholder;
@property (nonatomic, strong) IBInspectable NSString *image;
@property (nonatomic, assign) UIKeyboardType keyType;//UIKeyboardType
@property (nonatomic, assign) IBInspectable BOOL secure;
@property (nonatomic, assign) IBInspectable BOOL haveCodeBtn;

@property(nonatomic, weak)UITextField *textField;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, weak) UIButton *codeBtn;

@property(nonatomic, copy)void(^codeBtnActionBlock)(UIButton *);
@end

NS_ASSUME_NONNULL_END
