// 购物车

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShopCartHeaderView : UIView
@property (nonatomic, assign) BOOL allChoose;
@property (nonatomic, weak) UIButton *chooseBtn;
@property(nonatomic, copy)void(^shopCartAllChooseBlcok)(BOOL allChoose);
@end

NS_ASSUME_NONNULL_END
