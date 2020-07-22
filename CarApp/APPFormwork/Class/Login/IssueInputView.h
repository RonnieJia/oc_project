#import <UIKit/UIKit.h>

@interface IssueInputView : UIView
- (instancetype)initWithY:(CGFloat)y title:(NSString *)title placeholder:(NSString *)place rightText:(NSString *)text;
- (instancetype)initWithY:(CGFloat)y title:(NSString *)title placeholder:(NSString *)place rightView:(UIView *)view;
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title placeholder:(NSString *)place rightView:(UIView *)view;

@property(nonatomic, weak)UITextField *textField;
@property(nonatomic, weak)UITextField *endDateField;// 期限类型的
@end
