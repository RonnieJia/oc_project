//
//  AddressModel.h

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddressModel : BaseModel
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *consigner;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSString *aid;
@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, assign) BOOL is_default;

@end

NS_ASSUME_NONNULL_END
