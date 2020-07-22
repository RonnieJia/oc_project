

#import "ShopOrderViewController.h"
#import "ShopOrderHeaderView.h"
#import "ShopOderCell.h"
#import "ShopOrderDetailViewController.h"
#import "ShopOrderListModel.h"
#import "RefundReasonViewController.h"

@interface ShopOrderViewController ()
@property(nonatomic, strong)ShopOrderHeaderView *header;
@property(nonatomic, strong)UIScrollView *scrollView;
@end

@implementation ShopOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"商城订单";
    for (int i = 0; i<5; i++) {
        ShopOrderListModel *listModel = [[ShopOrderListModel alloc] init];
        listModel.type = i+1;
        [self.dataArray addObject:listModel];
    }
    [self setBackButton];
    [self createMainView];
    
    [self fetchData:1 refresh:YES];
}

- (void)fetchData:(NSInteger)type refresh:(BOOL)refresh {
    ShopOrderListModel *listModel = self.dataArray[type-1];
    if (refresh) {
        listModel.page = kPageStartIndex;
    } else {
        if (listModel.page == kPageStartIndex && listModel.hadLoad) {
            return;
        }
    }
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient fetchShopOrderList:type page:listModel.page completion:^(WebResponse *response) {
        UITableView *tableView = [weakSelf.scrollView viewWithTag:100+type];
        [tableView.mj_header endRefreshing];
        if (response.code == WebResponseCodeSuccess) {
            listModel.hadLoad=YES;
            NSArray *tmp = [ShopOrderModel listWithJSONArray:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"list")];
            if (listModel.page == kPageStartIndex) {
                [listModel.shopOrderArray removeAllObjects];
            }
            if (tmp.count<kPageSize) {
                listModel.noMore = YES;
                [tableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [tableView.mj_footer endRefreshing];
            }
            [listModel.shopOrderArray addObjectsFromArray:tmp];
            [tableView reloadData];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)applyRefund:(ShopOrderModel *)model state:(NSInteger)state {
    RefundReasonViewController *reason = [[RefundReasonViewController alloc] init];
    reason.order_id = model.order_id;
    weakify(self);
    reason.refuseMoneySuccess = ^{// 退款成功
        [weakSelf fetchData:state refresh:YES];
        [weakSelf needLoadIndex:4];
    };
    [self.navigationController pushViewController:reason animated:YES];
}

- (void)needLoadIndex:(NSInteger)index {
    ShopOrderListModel *rM = [self.dataArray objectAtIndex:index];
    rM.hadLoad = NO;
    rM.page = kPageStartIndex;
}

- (void)sureReceive:(ShopOrderModel *)model state:(NSInteger)state {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient orderReceived:model.order_id completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [weakSelf fetchData:state refresh:YES];
            [weakSelf needLoadIndex:3];
        }
        FailedMBProgressHUD(weakSelf.view, response.message);
    }];
}

#pragma mark - tableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ShopOrderListModel *listM = self.dataArray[tableView.tag-101];
    return listM.shopOrderArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShopOderCell *cell = [ShopOderCell cellWithTableView:tableView];
    ShopOrderListModel *listM = self.dataArray[tableView.tag-101];
    ShopOrderModel *model = listM.shopOrderArray[indexPath.row];
    model.orderStates = listM.type;
    cell.orderModel = model;
    weakify(self);
    cell.shopOrderCellBlock = ^(NSInteger type, ShopOrderState state, ShopOrderModel * _Nonnull model) {
        if (type == 0) {// 申请退款
            [weakSelf applyRefund:model state:state];
        } else if (type==1) {// 确认收货
            [weakSelf sureReceive:model state:state];
        }
        
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ShopOrderDetailViewController *detail = [ShopOrderDetailViewController new];
    NSInteger state = tableView.tag-100;
    ShopOrderListModel *listM = self.dataArray[tableView.tag-101];
    ShopOrderModel *orderModel = listM.shopOrderArray[indexPath.row];
    orderModel.orderStates = state;
    detail.orderModel = orderModel;
    weakify(self);
    detail.orderRefuseComplete = ^{
        [weakSelf fetchData:state refresh:YES];
        [weakSelf needLoadIndex:4];
    };
    if (tableView.tag == 103) {// 配送中
        detail.orderReceiveComplete = ^{// 确认收货
            [weakSelf fetchData:2 refresh:YES];
            [weakSelf needLoadIndex:3];
        };
    }
    
    if (tableView.tag == 101) {
        detail.orderPaySuccess = ^{
            [weakSelf fetchData:1 refresh:YES];
            [weakSelf needLoadIndex:1];
        };
    }
    [self.navigationController pushViewController:detail animated:YES];
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 101 || tableView.tag == 104) {
        return YES;
    }
    return NO;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ShopOrderListModel *manager = self.dataArray[tableView.tag-101];
        ShopOrderModel *orderModel  = manager.shopOrderArray[indexPath.row];
        WaittingMBProgressHUD(self.view, @"");
        weakify(self);
        self.clientDataTask = [kRJHTTPClient deleteShopOrder:orderModel.order_id completion:^(WebResponse *response) {
           if (response.code == WebResponseCodeSuccess) {
               [manager.shopOrderArray removeObject:orderModel];
               [tableView reloadData];
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
        }];
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self scrollViewDidEndMoving:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndMoving:scrollView];
}

- (void)scrollViewDidEndMoving:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        NSInteger index = (NSInteger)((scrollView.contentOffset.x + KScreenWidth/2.0)/KScreenWidth);
        self.header.selectIndex = index;
        [self fetchData:index+1 refresh:NO];
    }
}

- (void)createMainView {
    [self.view addSubview:self.header];
    [self.view addSubview:self.scrollView];
    for (int i = 0; i<5; i++) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(i*KScreenWidth, 0, KScreenWidth, self.scrollView.height)];
        [self.scrollView addSubview:tableView];
        tableView.tag = 101+i;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tableFooterView = [UIView new];
        tableView.tableHeaderView = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 10), kViewControllerBgColor);
        tableView.backgroundColor = kViewControllerBgColor;
        tableView.separatorStyle=UITableViewCellSelectionStyleNone;
        weakify(self);
        tableView.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
            [weakSelf fetchData:i+1 refresh:YES];
        }];
        tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
            ListModelManager *model = weakSelf.dataArray[i];
            model.page++;
            [weakSelf fetchData:i+1 refresh:NO];
        }];
    }
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 42, KScreenWidth, KViewNavHeight-42)];
        _scrollView.contentSize = CGSizeMake(KScreenWidth*5, KViewNavHeight-43);
        _scrollView.backgroundColor = kViewControllerBgColor;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollEnabled = NO;
    }
    return _scrollView;
}

- (ShopOrderHeaderView *)header {
    if (!_header) {
        _header = [[ShopOrderHeaderView alloc] init];
        weakify(self);
        _header.shopOrderCallBack = ^(NSInteger index) {
            strongify(weakSelf);
            [strongSelf.scrollView setContentOffset:CGPointMake(index * KScreenWidth, 0) animated:NO];
            [strongSelf fetchData:index+1 refresh:NO];
        };
    }
    return _header;
}

@end
