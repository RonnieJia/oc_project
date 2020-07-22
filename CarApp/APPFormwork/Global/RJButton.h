

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    RJButtonTypeTitleBottom,
    RJButtonTypeTitleLeft,
    RJButtonTypeTitleRight,
    RJButtonTypeCustomMargin,
    RJButtonTypeTitleBottomSize,
    RJButtonTypeTwoCap,
} RJButtonType;

@interface RJButton : UIButton
@property (nonatomic, assign)CGFloat margin;
@property (nonatomic, assign)RJButtonType type;
@property (nonatomic, assign)CGSize imageViewSize;

@property (nonatomic, strong) NSString *cla;

@end
