//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReservationModel : BaseModel
@property (nonatomic, strong) NSString *a_content;//备注
@property (nonatomic, strong) NSString *a_oid;//车主id
@property (nonatomic, strong) NSString *a_time;//预约时间
@property (nonatomic, strong) NSString *a_vid;//车辆id
@property (nonatomic, strong) NSString *create_time;//创建时间
@property (nonatomic, strong) NSString *o_nickname;//车主名
@property (nonatomic, strong) NSString *o_portrait;//车主头像
@property (nonatomic, strong) NSString *refuse_time;//拒绝时间
@property (nonatomic, strong) NSString *v_name;//车辆名称
@property (nonatomic, strong) NSString *r_id;//预约id
@property (nonatomic, assign) NSInteger is_cooperation;//1合作过 2没合作


@property (nonatomic, assign) ReservationState reservationState;


@end

NS_ASSUME_NONNULL_END
