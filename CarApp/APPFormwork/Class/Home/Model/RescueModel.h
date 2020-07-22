
#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RescueModel : BaseModel
@property (nonatomic, assign) NSInteger cooperation;// 是否合作过1-合作过
@property (nonatomic, strong) NSString *create_time; // 创建时间
@property (nonatomic, strong) NSString *o_portrait; // 车主头像
@property (nonatomic, strong) NSString *r_id; // 救援记录id
@property (nonatomic, strong) NSString *r_name; // 司机姓名
@property (nonatomic, strong) NSString *r_oid; // 车主id
@property (nonatomic, strong) NSString *r_rid; // 维修点店铺id
@property (nonatomic, strong) NSString *v_name;// 车辆名称
@property (nonatomic, assign) NSInteger repair_state;//维修状态0已接单 1维修中（同意维修） 2维修完成等待付款
@property (nonatomic, strong) NSString *vehicle_id;// 车辆id
@property (nonatomic, strong) NSString *o_nickname;// 车主姓名
@property (nonatomic, strong) NSString *o_number;//联系车主
@property (nonatomic, assign) NSInteger is_offer;//是否报价0未报价 1已报价
@property (nonatomic, strong) NSString *money;//报价钱数 钱数为0不显示
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *order_number;

@property (nonatomic, strong) NSString *working_money;
@property (nonatomic, strong) NSString *parts_money;
@property (nonatomic, strong) NSString *r_content;
@property (nonatomic, strong) NSString *offer_time;//报价时间
@property (nonatomic, strong) NSString *pay_time;
@property (nonatomic, strong) NSString *r_phone;
@property (nonatomic, strong) NSString *r_position;
@property (nonatomic, strong) NSString *receipt_time;
@property (nonatomic, strong) NSString *repair_time;
@property (nonatomic, assign) NSInteger payment;
@property (nonatomic, strong) NSString *refuse_time;
/*
info =         {
    "create_time"---------时间
    "is_offer"------------是否报价
    latitude = "";
    longitude = "";
    money-----------------报价总钱数
    "offer_time"----------报价时间
    "order_state"---------订单状态 0待接单 1已接单 2已完成 3已拒绝
    "parts_money"---------配件费
    "pay_time"------------支付时间
    payment---------------支付方式0未支付 1支付宝 2微信 3现金支付
    "r_content"-----------备注
    "r_name"--------------司机
    "r_phone"-------------车主手机号
    "r_position"----------具体位置
    "receipt_time"--------接单时间
    "repair_time"---------确认时间
    "v_name"--------------车辆名称
    "working_money"-------工时费
};
*/

@property (nonatomic, assign) NSInteger rescueState;// 订单状态 0待接单 1已接单 2已完成 3已拒绝

- (void)loadRescueDetail:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
