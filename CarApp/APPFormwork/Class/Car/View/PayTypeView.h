//
//  PayTypeView.h
//  APPFormwork

#import <UIKit/UIKit.h>

typedef void(^OrderPayBlock)(NSInteger type);

NS_ASSUME_NONNULL_BEGIN

@interface PayTypeView : UIView
- (void)showWithTypeBlock:(OrderPayBlock)payBlock;
@property (nonatomic, copy) OrderPayBlock block;

@end

NS_ASSUME_NONNULL_END
