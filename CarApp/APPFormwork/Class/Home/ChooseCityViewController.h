//
//  ChooseCityViewController.h
//  APPFormwork

#import "BaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChooseCityViewController : BaseTableViewController
@property(nonatomic, copy)void(^chooseCity)(NSString *city, NSString *cityId);
@end

NS_ASSUME_NONNULL_END
