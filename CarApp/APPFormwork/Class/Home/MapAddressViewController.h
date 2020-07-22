//
//  MapAddressViewController.h
//  APPFormwork

#import "BaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MapAddressViewController : BaseTableViewController
@property(nonatomic, copy)void(^chooseMapAddress)(NSString *str, CGFloat lat, CGFloat lon);
@end

NS_ASSUME_NONNULL_END
