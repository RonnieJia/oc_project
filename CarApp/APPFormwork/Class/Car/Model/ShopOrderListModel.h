//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShopOrderListModel : NSObject
@property (nonatomic, strong) NSMutableArray *shopOrderArray;
@property (nonatomic, assign) BOOL hadLoad;
@property (nonatomic, assign) BOOL noMore;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger type;
@end


@interface ShopOrderModel : BaseModel
@property (nonatomic, strong) NSString *goods_picture;
@property (nonatomic, strong) NSString *goods_name;
@property (nonatomic, strong) NSString *order_id;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *sku_name;
@property (nonatomic, strong) NSString *total_price;
@property (nonatomic, assign) NSInteger num;
@property (nonatomic, assign) NSInteger refund_status;//退款状态 1已申请 2已处理(成功退款） 3拒绝退款


@property (nonatomic, assign) ShopOrderState orderStates;

@end
NS_ASSUME_NONNULL_END
