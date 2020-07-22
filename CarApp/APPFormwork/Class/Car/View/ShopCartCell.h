// 购物车

#import "RJBaseTableViewCell.h"
@class CartModel;
@class ShopChangeCountView;

NS_ASSUME_NONNULL_BEGIN

@interface ShopCartCell : RJBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *chooseBtn;
@property (weak, nonatomic) IBOutlet ShopChangeCountView *cartNumView;

@property (nonatomic, strong) CartModel *cartModel;
@property (nonatomic, copy)void(^cartItemChooseBlock)(BOOL choose);
@property (nonatomic, copy)void(^cartNumChangeBlock)(BOOL choose);
@end

NS_ASSUME_NONNULL_END
