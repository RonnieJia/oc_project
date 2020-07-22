//

#import "ReservationNotesViewController.h"
#import "NotesChangeView.h"
#import "NotesTableViewCell.h"
#import "ReservationModel.h"
#import "ReservationDetailController.h"

@interface ReservationNotesViewController ()
@property(nonatomic, strong)NotesChangeView *changeView;
@property(nonatomic, strong)UIScrollView *scrollView;
@end

@implementation ReservationNotesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"预约记录";
    if (self.needBack) {
        [self setPopBackLeft];
    }
    for (int i = 0; i<3; i++) {
        ListModelManager *man = [[ListModelManager alloc] init];
        [self.dataArray addObject:man];
    }
    [self createMainView];
    [self fetchData:NO refresh:YES index:0];
    
}
- (void)refreshCount {
    weakify(self);
    [kRJHTTPClient fetchReservationList:kPageStartIndex state:0 completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            NSDictionary *result = ObjForKeyInUnserializedJSONDic(response.responseObject, @"result");
            for (int i = 0; i<3; i++) {
                [weakSelf.changeView count:IntForKeyInUnserializedJSONDic(result, [NSString stringWithFormat:@"count%d",i+1]) changeAtIndex:i];
            }
        }
    }];
}
- (void)fetchData:(BOOL)check refresh:(BOOL)refresh index:(NSInteger)index {
    ListModelManager *manager = self.dataArray[index];
    if (!refresh) {
        if (check && manager.load) {
            return;
        }
    } else {
        manager.page = kPageStartIndex;
        manager.noMoreData=NO;
    }
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient fetchReservationList:manager.page state:index completion:^(WebResponse *response) {
        UITableView *tableView = [weakSelf.scrollView viewWithTag:100+index];
        [tableView.mj_header endRefreshing];
        if (response.code == WebResponseCodeSuccess) {
            NSDictionary *result = ObjForKeyInUnserializedJSONDic(response.responseObject, @"result");
            for (int i = 0; i<3; i++) {
                [weakSelf.changeView count:IntForKeyInUnserializedJSONDic(result, [NSString stringWithFormat:@"count%d",i+1]) changeAtIndex:i];
            }
            manager.load=YES;
            if (manager.page == kPageStartIndex) {
                [manager.listArray removeAllObjects];
            }
            NSArray *temp = [ReservationModel listWithJSONArray:ObjForKeyInUnserializedJSONDic(result, @"list")];
            [manager.listArray addObjectsFromArray:temp];
            [tableView reloadData];
            if (temp.count<kPageSize) {
                manager.noMoreData=YES;
                [tableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [tableView.mj_footer endRefreshing];
            }
            FinishMBProgressHUD(weakSelf.view);
        } else {
            [tableView.mj_footer endRefreshing];
            if (manager.page>kPageStartIndex) {
                manager.page--;
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

#pragma mark - tableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ListModelManager *man = self.dataArray[tableView.tag-100];
    return man.listArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 100) {
        return 135;
    }
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotesTableViewCell *cell = [NotesTableViewCell cellWithTableView:tableView];
    ListModelManager *man = self.dataArray[tableView.tag-100];
    ReservationModel *model = man.listArray[indexPath.row];
    model.reservationState = tableView.tag-100;
    cell.reservationModel = model;
    weakify(self);
    cell.rescueAcceptBlock = ^(id  _Nonnull obj) {
        [weakSelf waitOrder:obj accept:YES];
    };
    cell.rescueRefuseBlock = ^(id  _Nonnull obj) {
        [weakSelf waitOrder:obj accept:NO];
    };
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag >= 102) {
        return YES;
    }
    return NO;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ListModelManager *manager = self.dataArray[tableView.tag-100];
        ReservationModel *repair = manager.listArray[indexPath.row];
        WaittingMBProgressHUD(self.view, @"");
        weakify(self);
        self.clientDataTask = [kRJHTTPClient deleteReservation:repair.r_id completion:^(WebResponse *response) {
           if (response.code == WebResponseCodeSuccess) {
               [weakSelf refreshCount];
               [manager.listArray removeObject:repair];
               [tableView reloadData];
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
        }];
    }
}


- (void)waitOrder:(ReservationModel *)model accept:(BOOL)accept {
    ListModelManager *waitMan = self.dataArray[0];
    if (accept) {
        ListModelManager *acceptMan = self.dataArray[1];
        acceptMan.load = NO;
        acceptMan.noMoreData = NO;
        acceptMan.page = kPageStartIndex;
    } else {
        ListModelManager *cancelMan = self.dataArray[2];
        cancelMan.load = NO;
        cancelMan.noMoreData = NO;
        cancelMan.page = kPageStartIndex;
    }
    if ([waitMan.listArray containsObject:model]) {
        [waitMan.listArray removeObject:model];
        UITableView *tab = [self.scrollView viewWithTag:100];
        [tab reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ReservationDetailController *detail=[ReservationDetailController new];
    ListModelManager *man = self.dataArray[tableView.tag-100];
    if (man && man.listArray.count>indexPath.row) {
        ReservationModel *model = man.listArray[indexPath.row];
        detail.reservationModel = model;
    }
    [self.navigationController pushViewController:detail animated:YES];
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
        [self fetchData:YES refresh:NO index:index];
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
        _scrollView.scrollEnabled=NO;
        _scrollView.contentSize=CGSizeMake(KScreenWidth*3, KViewNavHeight-51);
        for (int i = 0; i<3; i++) {
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(i*KScreenWidth, 0, KScreenWidth, self.scrollView.height)];
            [_scrollView addSubview:tableView];
            tableView.tag = 100+i;
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.estimatedRowHeight = 95;
            tableView.tableFooterView = [UIView new];
            tableView.tableHeaderView = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 10), KTextWhiteColor);
            tableView.backgroundColor = KTextWhiteColor;
            tableView.separatorStyle=UITableViewCellSelectionStyleNone;
            weakify(self);
            tableView.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
                [weakSelf fetchData:NO refresh:YES index:i];
            }];
            tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
                ListModelManager *man = weakSelf.dataArray[i];
                man.page++;
                [weakSelf fetchData:NO refresh:NO index:i];
            }];
        }
    }
    return _scrollView;
}
- (NotesChangeView *)changeView {
    if (!_changeView) {
        _changeView = [[NotesChangeView alloc] initWithItems:@[@"待接单",@"已接单",@"已拒绝"]];
        weakify(self);
        _changeView.notesCallBack = ^(NSInteger selectIndex) {
            strongify(weakSelf);
            [strongSelf.scrollView setContentOffset:CGPointMake(KScreenWidth*selectIndex, 0) animated:NO];
            [strongSelf fetchData:YES refresh:NO index:selectIndex];
        };
    }
    return _changeView;
}
@end
