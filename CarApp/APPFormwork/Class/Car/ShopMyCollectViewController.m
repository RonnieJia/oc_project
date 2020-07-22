
#import "ShopMyCollectViewController.h"
#import "ShopMyCollectCell.h"
#import "ShopGoodsModel.h"
#import "ShopGoodsDetailViewController.h"

@interface ShopMyCollectViewController ()

@end

@implementation ShopMyCollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的收藏";
    [self setBackButton];
    [self createMainView];
    [self fetchData];
}

- (void)fetchData {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient fetchCollctionList:self.page completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            if (weakSelf.page == kPageStartIndex) {
                [weakSelf.dataArray removeAllObjects];
            }
            NSArray *temp = [ShopGoodsModel listWithJSONArray:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"list")];
            [weakSelf.dataArray addObjectsFromArray:temp];
            [weakSelf.tableView reloadData];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)createMainView {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 130;
    self.tableView.backgroundColor = kViewControllerBgColor;
    [self.view addSubview:self.tableView];
}

#pragma mark - tableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShopMyCollectCell *cell = [ShopMyCollectCell cellWithTableView:tableView];
    cell.goodsModel=self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ShopGoodsDetailViewController *detail = [ShopGoodsDetailViewController new];
    ShopGoodsModel *model = self.dataArray[indexPath.row];
    detail.goods_id = model.goods_id;
    [self.navigationController pushViewController:detail animated:YES];
}

@end
