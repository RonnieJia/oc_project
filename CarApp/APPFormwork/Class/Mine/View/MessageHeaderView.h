//
//  MessageHeaderView.h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageHeaderView : UIView

@property(nonatomic, copy)void(^msgHeaderCallBack)(NSInteger index);
@property (nonatomic, assign) NSInteger selectIndex;
@end

NS_ASSUME_NONNULL_END
