// 到达现场的视图

#import <UIKit/UIKit.h>

typedef void(^SceneCallBack)(NSInteger index);

NS_ASSUME_NONNULL_BEGIN


@interface SceneView : UIView
- (void)showWithCallback:(SceneCallBack)callback;
@property(nonatomic, copy)SceneCallBack block;
@end

NS_ASSUME_NONNULL_END
