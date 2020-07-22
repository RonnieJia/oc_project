#import "FixNotesViewController.h"
#import "NotesChangeView.h"
#import "NotesTableViewCell.h"
#import "MapLocationViewController.h"
#import "FixEditViewController.h"
#import "FixOrderInfoViewController.h"
#import "FixModel.h"
#import "RefundReasonViewController.h"

@interface FixNotesViewController ()
@property(nonatomic, strong)NotesChangeView *changeView;
@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic, assign)NSInteger cancelCount;
@end

@implementation FixNotesViewController
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"维修记录";
    if (self.needBack) {
        [self setPopBackLeft];
    }
    for (int i = 0; i<4; i++) {
        ListModelManager *man = [[ListModelManager alloc] init];
        [self.dataArray addObject:man];
    }
    [self createMainView];
    if (self.state>0 && self.state<5) {
        self.changeView.selectIndex = self.state-1;
        [self.scrollView setContentOffset:CGPointMake(KScreenWidth*(self.state-1), 0)];
        [self fetchData:YES scroll:NO index:self.state];
    } else {
        [self fetchData:YES scroll:NO index:1];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fixReportSuccess:) name:kFixReportSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fixCompleted) name:kFixCompleted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fixCancelOrder:) name:kFixOrderCancel object:nil];
}

- (void)fixCancelOrder:(NSNotification *)noti {
    FixModel *fixM = noti.object;
    ListModelManager *cancelMan = self.dataArray[3];
    cancelMan.page =kPageStartIndex;
    cancelMan.load = NO;
    cancelMan.noMoreData=NO;
    
    ListModelManager *waitMan = self.dataArray[0];
    if ([waitMan.listArray containsObject:fixM]) {
        [waitMan.listArray removeObject:fixM];
        UITableView *tableView = [self.scrollView viewWithTag:101];
        [tableView reloadData];
        return;
    }
    ListModelManager *acceptMan = self.dataArray[1];
    if ([acceptMan.listArray containsObject:fixM]) {
        [acceptMan.listArray removeObject:fixM];
        UITableView *tableView = [self.scrollView viewWithTag:102];
        [tableView reloadData];
    }
}

- (void)fixCompleted {
    UITableView *tableView = [self.scrollView viewWithTag:102];
    [tableView reloadData];
}

- (void)fixReportSuccess:(NSNotification *)noti {// 报价成功
    UITableView *tableView = [self.scrollView viewWithTag:101];
    [tableView reloadData];
}

- (void)refreshCount {
    weakify(self);
    [kRJHTTPClient fetchFixList:kPageStartIndex state:1 completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            NSDictionary *result = ObjForKeyInUnserializedJSONDic(response.responseObject, @"result");
            [weakSelf displayOrderNumber:result];
        }
    }];
}

- (void)fetchData:(BOOL)refresh scroll:(BOOL)scroll index:(NSInteger)index {
    ListModelManager *man = self.dataArray[index-1];
    if (!refresh) {
        if (scroll && man.load) {
            return;
        }
    } else {
        man.page = kPageStartIndex;
        man.noMoreData=NO;
    }
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient fetchFixList:man.page state:index completion:^(WebResponse *response) {
        UITableView *tableView = [weakSelf.scrollView viewWithTag:100+index];
        [tableView.mj_header endRefreshing];
        if (response.code == WebResponseCodeSuccess) {
            NSDictionary *result = ObjForKeyInUnserializedJSONDic(response.responseObject, @"result");
            [weakSelf displayOrderNumber:result];
            man.load=YES;
            if (man.page == kPageStartIndex) {
                [man.listArray removeAllObjects];
            }
            NSArray *temp = [FixModel listWithJSONArray:ObjForKeyInUnserializedJSONDic(result, @"list")];
            [man.listArray addObjectsFromArray:temp];
            [tableView reloadData];
            if (temp.count<kPageSize) {
                man.noMoreData=YES;
                [tableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [tableView.mj_footer endRefreshing];
            }
            FinishMBProgressHUD(weakSelf.view);
        } else {
            [tableView.mj_footer endRefreshing];
            if (man.page>kPageStartIndex) {
                man.page--;
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)displayOrderNumber:(NSDictionary *)dic {
    NSArray *keys = @[@"wait_count",@"repair_count",@"complete_count",@"cancel_count"];
    for (int i = 0; i<4; i++) {
        if (i==3) {
            self.cancelCount = IntForKeyInUnserializedJSONDic(dic, keys[i]);
        }
        [self.changeView count:IntForKeyInUnserializedJSONDic(dic, keys[i]) changeAtIndex:i];
    }
}

#pragma mark - tableView DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag < 102) {
        return 135;
    }
    return 100;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ListModelManager *manager = self.dataArray[tableView.tag-101];
    return manager.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotesTableViewCell *cell = [NotesTableViewCell cellWithTableView:tableView];
    ListModelManager *manager = self.dataArray[tableView.tag-101];
    cell.fixModel = manager.listArray[indexPath.row];
    weakify(self);
    cell.locationBlock = ^(id  _Nonnull obj) {
        FixModel *fixM = obj;
        MapLocationViewController *map = [MapLocationViewController new];
        map.lat = fixM.lat;
        map.lon = fixM.lng;
        map.oName = fixM.v_name;
        [weakSelf.navigationController pushViewController:map animated:YES];
    };
    cell.leftBtnBlock = ^(id  _Nonnull obj) {
        [weakSelf cancelOrder:obj];
    };
    cell.rightBtnBlock = ^(id  _Nonnull obj) {// 待接单的报价
        [weakSelf commitPriceOrder:obj];
    };
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag >= 104) {
        return YES;
    }
    return NO;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
       ListModelManager *manager = self.dataArray[tableView.tag-101];
       FixModel *fixModel = manager.listArray[indexPath.row];
        WaittingMBProgressHUD(self.view, @"");
        weakify(self);
        [kRJHTTPClient deleteFixOrder:fixModel.order_rid completion:^(WebResponse *response) {
            if (response.code == WebResponseCodeSuccess) {
                [weakSelf refreshCount];
                [manager.listArray removeObject:fixModel];
                [tableView reloadData];
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
            
        }];
    }
}

/// 取消订单
- (void)cancelOrder:(FixModel *)model {
    RefundReasonViewController *cancel = [RefundReasonViewController new];
    cancel.type = 1;
    cancel.cancelType = 0;
    cancel.order_id = model.order_rid;
    cancel.obj = model;
    [self.navigationController pushViewController:cancel animated:YES];
}
/// 报价
- (void)commitPriceOrder:(FixModel *)model {
    if (IsStringEmptyOrNull(model.vehicle_id)) {
        WaittingMBProgressHUD(self.view, @"");
        weakify(self);
        [kRJHTTPClient fetchFixInfo:model.order_rid completion:^(WebResponse *response) {
            if (response.code == WebResponseCodeSuccess) {
                [model loadDetail:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"info")];
                FixEditViewController *edit = [FixEditViewController new];
                edit.fixModel = model;
                [weakSelf.navigationController pushViewController:edit animated:YES];
                FinishMBProgressHUD(weakSelf.view);
            } else {
                FailedMBProgressHUD(weakSelf.view, response.message);
            }
        }];
    } else {
        FixEditViewController *edit = [FixEditViewController new];
        edit.fixModel = model;
        [self.navigationController pushViewController:edit animated:YES];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ListModelManager *manager = self.dataArray[tableView.tag-101];
    FixOrderInfoViewController *info = [FixOrderInfoViewController new];
    info.fixModel = manager.listArray[indexPath.row];
    [self.navigationController pushViewController:info animated:YES];
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
        self.changeView.selectIndex = index;
        [self fetchData:NO scroll:YES index:index+1];
    }
}

- (void)createMainView {
    self.view.backgroundColor = KTextWhiteColor;
    [self.view addSubview:self.changeView];
    [self.view addSubview:self.scrollView];
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, KScreenWidth, KViewNavHeight-50)];
        _scrollView.delegate=self;
        _scrollView.pagingEnabled=YES;
        _scrollView.bounces=NO;
        _scrollView.contentSize=CGSizeMake(KScreenWidth*4, KViewNavHeight-51);
        _scrollView.scrollEnabled = NO;
        for (int i = 0; i<4; i++) {
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(i*KScreenWidth, 0, KScreenWidth, self.scrollView.height)];
            [_scrollView addSubview:tableView];
            tableView.tag = 101+i;
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.rowHeight = 135;
            tableView.tableFooterView = [UIView new];
            tableView.tableHeaderView = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 10), KTextWhiteColor);
            tableView.backgroundColor = KTextWhiteColor;
            tableView.separatorStyle=UITableViewCellSelectionStyleNone;
            weakify(self);
            tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
                ListModelManager *m = weakSelf.dataArray[i];
                m.page++;
                [weakSelf fetchData:NO scroll:NO index:i+1];
            }];
            tableView.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
                [weakSelf fetchData:YES scroll:NO index:i+1];
            }];
        }
    }
    return _scrollView;
}
- (NotesChangeView *)changeView {
    if (!_changeView) {
        _changeView = [[NotesChangeView alloc] initWithItems:@[@"待维修",@"维修中",@"已完成",@"已取消"]];
        weakify(self);
        _changeView.notesCallBack = ^(NSInteger selectIndex) {
            strongify(weakSelf);
            [strongSelf.scrollView setContentOffset:CGPointMake(KScreenWidth*selectIndex, 0) animated:NO];
            [strongSelf fetchData:NO scroll:YES index:selectIndex+1];
        };
    }
    return _changeView;
}
@end
