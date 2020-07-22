//
//  MoneyInfoModel.h
//  APPFormwork

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MoneyInfoModel : BaseModel
@property (nonatomic, strong) NSString *money;
@property (nonatomic, strong) NSString *picturs;
@property (nonatomic, strong) NSString *name;//挂车厂名称
@property (nonatomic, strong) NSString *content;//不通过原因
@property (nonatomic, strong) NSString *create_time;
@property (nonatomic, assign) NSInteger state;// 0提现申请中 1审核通过 2审核不通过
@property (nonatomic, assign) NSInteger sign;
@property (nonatomic, strong) NSString *describe;
@property (nonatomic, assign) NSInteger pay_type;



@end

NS_ASSUME_NONNULL_END
