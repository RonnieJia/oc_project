

#import <UIKit/UIKit.h>

typedef void(^HomeItemCallBack)(NSInteger index, NSString * _Nullable cla);

NS_ASSUME_NONNULL_BEGIN

@interface HomeHeaderView : UIView
@property(nonatomic, copy)HomeItemCallBack headerItemClick;
- (void)refreshCount:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
