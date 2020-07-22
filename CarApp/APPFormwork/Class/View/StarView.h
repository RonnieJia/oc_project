

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StarView : UIView
@property (nonatomic,assign, getter=isEdited) IBInspectable BOOL edited;
@property (nonatomic, assign) CGFloat starValue;

@end

NS_ASSUME_NONNULL_END
