// 商城订单详情的一条信息记录<例如：订单编号>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShopOrderInfoItem : UIView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) NSDictionary *info;
@end

NS_ASSUME_NONNULL_END
