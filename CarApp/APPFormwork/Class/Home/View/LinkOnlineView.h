//  在线联系
//  LinkOnlineView.h
//  APPFormwork

#import <UIKit/UIKit.h>

typedef void(^LinkOnlineBlock)(NSInteger index);

NS_ASSUME_NONNULL_BEGIN

@interface LinkOnlineView : UIView
+ (instancetype)sharedInstance;
- (void)showWithBlock:(LinkOnlineBlock)block;

@property (nonatomic, copy) LinkOnlineBlock block;

@end

NS_ASSUME_NONNULL_END
