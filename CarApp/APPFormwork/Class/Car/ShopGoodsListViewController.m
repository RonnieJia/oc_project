#import "ShopGoodsListViewController.h"
#import "GoodsListSortView.h"
#import "GoodsListCateView.h"
#import "GoodsListTableCell.h"
#import "ShopGoodsModel.h"
#import "ShopGoodsDetailViewController.h"

@interface ShopGoodsListViewController ()
@property(nonatomic, strong)GoodsListSortView *sortView;
@property(nonatomic, strong)GoodsListCateView *cateView;
@property(nonatomic, assign)NSInteger sort;
@property(nonatomic, assign)BOOL all;
@end

@implementation ShopGoodsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"商品列表";
    [self setBackButton];
    [self createMainView];
    [self fetchGoodsList:NO];
}

- (void)fetchGoodsList:(BOOL)all {
    self.cateView.dataArray = self.cateArray;
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    self.clientDataTask = [kRJHTTPClient fetchGoodsList:self.page cate:self.cate_id all:all sort:self.sort goodsName:@"" completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            if (weakSelf.page == kPageStartIndex) {
                [weakSelf.dataArray removeAllObjects];
            }
            NSArray *temp = [ShopGoodsModel listWithJSONArray:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"list")];
            if (temp.count<kPageSize) {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [weakSelf.tableView.mj_footer endRefreshing];
            }
            [weakSelf.dataArray addObjectsFromArray:temp];
            [weakSelf.tableView reloadData];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            if (weakSelf.page>kPageStartIndex) {
                weakSelf.page--;
            }
            [weakSelf.tableView.mj_footer endRefreshing];
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

#pragma mark - tableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GoodsListTableCell *cell = [GoodsListTableCell cellWithTableView:tableView];
    cell.goodsModel = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ShopGoodsModel *model = self.dataArray[indexPath.row];
    ShopGoodsDetailViewController *detail = [[ShopGoodsDetailViewController alloc] init];
    detail.goods_id = model.goods_id;
    [self.navigationController pushViewController:detail animated:YES];
}
- (void)createMainView {
    self.view.backgroundColor = KTextWhiteColor;
    self.tableView.backgroundColor = KTextWhiteColor;
    self.tableView.top = 45;
    self.tableView.height = KViewNavHeight-45;
    self.tableView.rowHeight = 110;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.cateView];
    [self.view addSubview:self.sortView];
    weakify(self);
    self.tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
}

- (void)loadMoreData {
    self.page++;
    [self fetchGoodsList:self.all];
}

- (GoodsListSortView *)sortView {
    if (!_sortView) {
        _sortView = [[GoodsListSortView alloc] init];
        weakify(self);
        _sortView.goodsListSortBlock = ^(NSInteger index) {
            strongify(weakSelf);
            if (index == 0) {
                strongSelf.cateView.hidden = !strongSelf.cateView.hidden;
            } else {
                strongSelf.cateView.hidden=YES;
                if (index==1) {
                    if (strongSelf.sort!=0) {
                        strongSelf.sort=0;
                        strongSelf.page = kPageStartIndex;
                        [strongSelf fetchGoodsList:strongSelf.all];
                    }
                } else if (index==2) {
                    if (strongSelf.sort==1) {
                        strongSelf.sort = 2;
                    } else {
                        strongSelf.sort = 1;
                    }
                    strongSelf.page = kPageStartIndex;
                    [strongSelf fetchGoodsList:strongSelf.all];
                }
            }
        };
    }
    return _sortView;
}
-(GoodsListCateView *)cateView {
    if (!_cateView) {
        _cateView = [[GoodsListCateView alloc] init];
        _cateView.hidden=YES;
        weakify(self);
        _cateView.goodsCateBlock = ^(NSString * _Nonnull cate_id, BOOL all) {
            if (![weakSelf.cate_id isEqualToString:cate_id]) {
                weakSelf.cate_id = cate_id;
                weakSelf.page = kPageStartIndex;
                weakSelf.all = all;
                [weakSelf fetchGoodsList:all];
            }
        };
    }
    return _cateView;
}
@end
