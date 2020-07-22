
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TBKSuccessTypeCopy,// 复制邀请码
    TBKSuccessTypeShare,//分享
    TBKSuccessTypeCopyTKL,// 淘口令
    TBKSuccessTypeBand,// 绑定支付宝
    TBKSuccessTypeComment,//评论
    TBKSuccessTypeSaveImg,// 保存二维码
} TBKSuccessType;

@interface TBKSuccessView : UIView

+ (instancetype)sharedInstance;
- (void)showWithType:(TBKSuccessType)type;
- (void)showWithTitle:(NSString *)title content:(NSString *)content;
@end
