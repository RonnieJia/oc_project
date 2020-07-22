// 维修订单

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FixModel : BaseModel
@property (nonatomic, strong) NSString *order_number;
@property (nonatomic, strong) NSString *create_time;//下单时间
@property (nonatomic, strong) NSString *cancel_time;//取消时间
@property (nonatomic, strong) NSString *lat;//
@property (nonatomic, strong) NSString *lng;//
@property (nonatomic, strong) NSString *order_rid;//订单id
@property (nonatomic, strong) NSString *owner_id;//
@property (nonatomic, strong) NSString *phone;//车主手机号
@property (nonatomic, strong) NSString *price;//总价格
@property (nonatomic, strong) NSString *r_name;//维修点名称
@property (nonatomic, strong) NSString *r_portrait;//维修点头像
@property (nonatomic, strong) NSString *repair_id;//
@property (nonatomic, strong) NSString *v_name;// 车辆名称
@property (nonatomic, assign) NSInteger cancel_state;//取消状态1 车主取消 2维修点取消
@property (nonatomic, assign) NSInteger is_cooperation;//1合作过 0未合作
@property (nonatomic, assign) NSInteger is_offer;//维修点是否报价 1已报价 2未报价
@property (nonatomic, assign) NSInteger order_state;//配件价格?
@property (nonatomic, assign) NSInteger pay_state;//支付状态0未支付 1已支付
@property (nonatomic, assign) NSInteger repair_state;//1-维修中  2-维修完成
@property (nonatomic, strong) NSString *cancel_content;//取消简述
@property (nonatomic, strong) NSString *cancel_title;//取消原因
@property (nonatomic, strong) NSString *hours_price;//工时费
@property (nonatomic, strong) NSString *o_nickname;//车主昵称
@property (nonatomic, strong) NSString *offer_time;// 报价时间
@property (nonatomic, strong) NSString *parts_price;// 配件价格
@property (nonatomic, strong) NSString *pay_time;// 支付时间
@property (nonatomic, assign) NSInteger payment_type;// 1-支付宝 2微信
@property (nonatomic, strong) NSString *repair_time;// 确认时间
@property (nonatomic, strong) NSString *vehicle_id;// 车辆id


- (void)loadDetail:(NSDictionary *)dic;

@property (nonatomic, assign) FixState  fixState;



@end

NS_ASSUME_NONNULL_END
