// 报修记录

#import "BaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RepairNotesViewController : BaseTableViewController
@property (nonatomic, assign)BOOL needAddBack;
@property (nonatomic, assign) NSInteger state;//1待维修 2维修中 3已完成 4已取消 5不认可

@end

NS_ASSUME_NONNULL_END
