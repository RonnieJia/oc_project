

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RepairModel : BaseModel
@property (nonatomic, strong) NSString *re_id;
@property (nonatomic, assign) NSInteger is_trailer_confirm;//挂车厂是否确认 1已认可 2不认可
@property (nonatomic, strong) NSString *o_id;//车主id
@property (nonatomic, assign) NSInteger is_offer;//是否报价0未报价（等待接单） 1已报价
@property (nonatomic, strong) NSString *create_time;//创建时间
/// 默认状态0 1车主取消 2维修点取消
@property (nonatomic, assign) NSInteger cancel_state;
@property (nonatomic, strong) NSString *complete_time;//完成时间
@property (nonatomic, strong) NSString *cancel_time;//取消时间
@property (nonatomic, strong) NSString *no_approval_time1;//不认可时间
/// 维修状态默认状态0挂车厂认可后改为1 1待维修 2维修中 3已完成 4已取消 5不认可
@property (nonatomic, assign) NSInteger re_repair_state;
/// 维修点是否认可 当挂车厂认可后维修点不需要点击认可 0 未操作 1已认可 2不认可
@property (nonatomic, assign) NSInteger is_repair_confirm;
@property (nonatomic, strong) NSString *o_nickname;//车主名称
@property (nonatomic, strong) NSString *v_name;//车辆名称
/// 1合作过 0没合作
@property (nonatomic, assign) NSInteger is_cooperation;
@property (nonatomic, strong) NSString *re_number;// 编号




@property (nonatomic, strong) NSString *re_price;//报价金额
@property (nonatomic, strong) NSString *parts_money;//配件金额
@property (nonatomic, strong) NSString *working_money;//工时金额
@property (nonatomic, strong) NSString *offer_time;//报价时间
@property (nonatomic, strong) NSString *pay_time;//支付时间
@property (nonatomic, strong) NSString *re_address;// 订单位置
@property (nonatomic, strong) NSString *re_describe;// 描述
@property (nonatomic, strong) NSString *re_pictures;// 图片每张图片逗号隔开
@property (nonatomic, strong) NSString *contact_phone;// 车主电话
@property (nonatomic, strong) NSString *t_name;// 挂车厂名称
@property (nonatomic, strong) NSString *t_address;//挂车厂地址
@property (nonatomic, strong) NSString *t_id;
@property (nonatomic, strong) NSString *type_title;// 取消原因
@property (nonatomic, strong) NSString *cancel_content;


@property (nonatomic, strong) NSString *o_portrait;//头像
@property (nonatomic, strong) NSString *v_id;//车辆id
@property (nonatomic, strong) NSString *no_approval_time2;//维修点不认可时间
@property (nonatomic, strong) NSString *no_approval_time3;//后台不认可时间


- (void)loadDetail:(NSDictionary *)dic;

@property (nonatomic, assign) RepairState repairState;

@end

NS_ASSUME_NONNULL_END
