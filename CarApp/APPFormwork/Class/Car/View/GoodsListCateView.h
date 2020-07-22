// 
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoodsListCateView : UIView
@property (nonatomic, strong) NSArray *dataArray;
@property(nonatomic, copy)void(^goodsCateBlock)(NSString *cate_id, BOOL all);
@end

NS_ASSUME_NONNULL_END
