//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CartPayModel : BaseModel
@property (nonatomic, strong) NSArray *cartGoodsArr;
@property (nonatomic, assign) CGFloat money;
@property (nonatomic, assign) CGFloat shinMoney;

@end

NS_ASSUME_NONNULL_END
