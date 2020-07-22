
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoodsListSortView : UIView
@property (nonatomic, copy) void(^goodsListSortBlock)(NSInteger index);

@end

NS_ASSUME_NONNULL_END
