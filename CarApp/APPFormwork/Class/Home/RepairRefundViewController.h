//
//  RepairRefundViewController.h
//  APPFormwork
//  报修订单不认可

#import "BaseTableViewController.h"
#import "RepairModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RepairRefundViewController : BaseTableViewController
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (nonatomic, strong) RepairModel *repairModel;

@end

NS_ASSUME_NONNULL_END
