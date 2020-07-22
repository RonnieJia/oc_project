

#import <UIKit/UIKit.h>
#import "CityDataManager.h"

@interface CityInputView : UIView
@property(nonatomic, copy)void(^areaBlock)(ProvinceModel *p, CityModel *c);
@property(nonatomic, copy)void(^areaResignBlock)();
@end
