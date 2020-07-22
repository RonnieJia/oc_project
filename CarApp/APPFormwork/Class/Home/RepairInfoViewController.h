//  报修信息
//  RepairInfoViewController.h
//  APPFormwork
//

#import "BaseTableViewController.h"
@class RepairModel;
@class FixModel;

NS_ASSUME_NONNULL_BEGIN

@interface RepairInfoViewController : BaseTableViewController
@property (nonatomic, strong) RepairModel *repairModel;
@property (nonatomic, strong) NSString *state;

@property (nonatomic, assign) BOOL isFix;
@property (nonatomic, strong) FixModel *fixModel;

@end

NS_ASSUME_NONNULL_END
