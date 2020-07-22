#import "RJBaseViewController.h"
#import <MJRefresh/MJRefresh.h>

@interface BaseTableViewController : RJBaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL table_header;
@property (nonatomic, assign) BOOL table_footer;
- (void)tableViewHeaderRefresh;
- (void)tableViewFooterLoadmore;
@end
