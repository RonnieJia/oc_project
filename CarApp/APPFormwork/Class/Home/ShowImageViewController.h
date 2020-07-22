//
#import "BaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShowImageViewController : BaseTableViewController
@property (nonatomic, strong) NSArray *imgs;
@property(nonatomic, copy)void(^changeImagesBlock)(NSArray *arr);
@end

NS_ASSUME_NONNULL_END
