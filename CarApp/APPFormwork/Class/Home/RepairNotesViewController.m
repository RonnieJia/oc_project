//

#import "RepairNotesViewController.h"
#import "NotesChangeView.h"
#import "NotesTableViewCell.h"
#import "RepairModel.h"
#import "RepairOrderInfoViewController.h"
#import "FixEditViewController.h"
#import "RepairRefundViewController.h"
#import "ChatViewController.h"

@interface RepairNotesViewController ()
@property(nonatomic, strong)NotesChangeView *changeView;
@property(nonatomic, strong)UIScrollView *scrollView;

@property(nonatomic, assign)NSInteger cancelCount;
@end

@implementation RepairNotesViewController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"报修记录";
    if (self.needAddBack) {
        [self setPopBackLeft];
    }
    for (int i = 0; i<5; i++) {
        ListModelManager *man = [[ListModelManager alloc] init];
        [self.dataArray addObject:man];
    }
    [self createMainView];
    if (self.state>0 && self.state<6) {
        self.changeView.selectIndex = self.state-1;
        [self.scrollView setContentOffset:CGPointMake((self.state-1)*KScreenWidth, 0)];
        [self fetchData:YES change:NO state:self.state];
    } else {
        [self fetchData:YES change:NO state:1];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repairOfferNoti:) name:kRepairOffer object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repairRefundNoti:) name:kRepairRefund object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repairCancelNoti:) name:kRepairCancel object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repairCompletedNoti:) name:kRepairCompleted object:nil];
}

- (void)repairCompletedNoti:(NSNotification *)noti {// 完成
    ListModelManager *cancelMan = self.dataArray[2];
    cancelMan.load=NO;
    cancelMan.page = kPageStartIndex;
    cancelMan.noMoreData=NO;
    RepairModel *model = noti.object;
    ListModelManager *acceptM = self.dataArray[1];
    if ([acceptM.listArray containsObject:model]) {
        [acceptM.listArray removeObject:model];
        UITableView *table = [self.scrollView viewWithTag:102];
        [table reloadData];
    }
}
- (void)repairCancelNoti:(NSNotification *)noti {// 取消订单
    ListModelManager *cancelMan = self.dataArray[3];
    cancelMan.load=NO;
    cancelMan.page = kPageStartIndex;
    cancelMan.noMoreData=NO;
    RepairModel *model = noti.object;
    ListModelManager *waitM = self.dataArray[0];
    if ([waitM.listArray containsObject:model]) {
        [waitM.listArray removeObject:model];
        UITableView *table = [self.scrollView viewWithTag:101];
        [table reloadData];
        return;
    }
    
    ListModelManager *acceptM = self.dataArray[1];
    if ([acceptM.listArray containsObject:model]) {
        [acceptM.listArray removeObject:model];
        UITableView *table = [self.scrollView viewWithTag:102];
        [table reloadData];
    }
}

- (void)repairOfferNoti:(NSNotification *)noti {// 报价成功
    UITableView *tableview = [self.scrollView viewWithTag:101];
    [tableview reloadData];
}

- (void)repairRefundNoti:(NSNotification *)noti {// 不认可
    RepairModel *model = noti.object;
    ListModelManager *waitMan = self.dataArray[0];
    ListModelManager *refundMan = self.dataArray[4];
    refundMan.load = NO;
    refundMan.page = kPageStartIndex;
    refundMan.noMoreData=NO;
    if ([waitMan.listArray containsObject:model]) {
        [waitMan.listArray removeObject:model];
        UITableView *table = [self.scrollView viewWithTag:101];
        [table reloadData];
    }
}
- (void)refreshCount {
    weakify(self);
    [kRJHTTPClient fetchRepairList:kPageStartIndex state:1 completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            NSDictionary *result = ObjForKeyInUnserializedJSONDic(response.responseObject, @"result");
            for (int i = 0; i<5; i++) {
                [weakSelf.changeView count:IntForKeyInUnserializedJSONDic(result, [NSString stringWithFormat:@"count%d",i+1]) changeAtIndex:i];
            }
        }
    }];
}
- (void)fetchData:(BOOL)refresh change:(BOOL)change state:(NSInteger)state {
    ListModelManager *man = self.dataArray[state-1];
    if (!refresh) {
        if (change && man.load) {
            return;
        }
    } else {
        man.page = kPageStartIndex;
        man.noMoreData = NO;
    }
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    self.clientDataTask = [kRJHTTPClient fetchRepairList:man.page state:state completion:^(WebResponse *response) {
        UITableView *tableView = [weakSelf.scrollView viewWithTag:100+state];
        [tableView.mj_header endRefreshing];
        if (response.code == WebResponseCodeSuccess) {
            NSDictionary *result = ObjForKeyInUnserializedJSONDic(response.responseObject, @"result");
            for (int i = 0; i<5; i++) {
                if (i==4) {
                    weakSelf.cancelCount = IntForKeyInUnserializedJSONDic(result, [NSString stringWithFormat:@"count%d",i+1]);
                }
                [weakSelf.changeView count:IntForKeyInUnserializedJSONDic(result, [NSString stringWithFormat:@"count%d",i+1]) changeAtIndex:i];
            }
            man.load = YES;
            if (man.page == kPageStartIndex) {
                [man.listArray removeAllObjects];
            }
            NSArray *temp = [RepairModel listWithJSONArray:ObjForKeyInUnserializedJSONDic(result, @"list")];
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

#pragma mark - tableView DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag < 102) {
        return 135;
    }
    return 100;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ListModelManager *man = self.dataArray[tableView.tag-101];
    return man.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotesTableViewCell *cell = [NotesTableViewCell cellWithTableView:tableView];
    ListModelManager *man = self.dataArray[tableView.tag-101];
    if (man && man.listArray.count>indexPath.row) {
        cell.repairModel = man.listArray[indexPath.row];
    }
    weakify(self);
    cell.rightBtnBlock = ^(id  _Nonnull obj) {// 报价
        [weakSelf repairOffer:obj];
    };
    cell.leftBtnBlock = ^(id  _Nonnull obj) {
        [weakSelf repairRefund:obj];
    };
    cell.locationBlock = ^(id  _Nonnull obj) {
        [weakSelf repairLinkAction:obj];
    };
    cell.rescueAcceptBlock = ^(id  _Nonnull obj) {
        [weakSelf linkOwen:obj];
    };
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag >= 103) {
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
        RepairModel *repair = manager.listArray[indexPath.row];
        WaittingMBProgressHUD(self.view, @"");
        weakify(self);
        self.clientDataTask = [kRJHTTPClient deleteRepair:repair.re_id completion:^(WebResponse *response) {
           if (response.code == WebResponseCodeSuccess) {
               [weakSelf refreshCount];
               [manager.listArray removeObject:repair];
               [tableView reloadData];
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
        }];
    }
}

- (void)linkOwen:(RepairModel *)rm {
    [self linkWithType:0 rid:rm.o_id];
}

/// 联系平台
- (void)repairLinkAction:(RepairModel *)model {
    [self linkWithType:1 rid:nil];
}

- (void)linkWithType:(NSInteger)type rid:(NSString *)rid {
    NSString *userName, *appKey;
    if (type == 1) {
        userName = kPlatformWord;
        appKey = kPlatformAppKey;
    } else {
        userName = [NSString stringWithFormat:kCarOwnerWord,rid];
        appKey = kCarOwnerAppKey;
    }
    weakify(self);
    [JMSGConversation createSingleConversationWithUsername:userName appKey:appKey completionHandler:^(id resultObject, NSError *error) {
        if (!error && resultObject && [resultObject isKindOfClass:JMSGConversation.class]) {
            ChatViewController *chat = [[ChatViewController alloc] init];
            chat.conversation=resultObject;
            [weakSelf.navigationController pushViewController:chat animated:YES];
        } else {
            ShowAutoHideMBProgressHUD(self.view, @"请稍后再试~");
        }
    }];
}

- (void)repairRefund:(RepairModel *)model {// 不认可
    RepairRefundViewController *refund = [[RepairRefundViewController alloc] init];
    refund.repairModel = model;
    [self.navigationController pushViewController:refund animated:YES];
}
- (void)repairOffer:(RepairModel *)rmodel {// 报价
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient fetchRepairInfo:rmodel.re_id completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [rmodel loadDetail:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"info")];
            FixEditViewController *edit = [FixEditViewController new];
            edit.repair = YES;
            edit.repairModel = rmodel;
            [weakSelf.navigationController pushViewController:edit animated:YES];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ListModelManager *man = self.dataArray[tableView.tag-101];
    if (man && man.listArray.count>indexPath.row) {
        RepairOrderInfoViewController *info = [[RepairOrderInfoViewController alloc] init];
        info.repairModel = man.listArray[indexPath.row];
        [self.navigationController pushViewController:info animated:YES];
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
        self.changeView.selectIndex = index;
        [self fetchData:NO change:YES state:index+1];
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
        _scrollView.scrollEnabled = NO;
        _scrollView.contentSize=CGSizeMake(KScreenWidth*5, KViewNavHeight-51);
        for (int i = 0; i<5; i++) {
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(i*KScreenWidth, 0, KScreenWidth, self.scrollView.height)];
            [_scrollView addSubview:tableView];
            tableView.tag = 101+i;
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.rowHeight = 100;
            tableView.tableFooterView = [UIView new];
            tableView.tableHeaderView = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 10), KTextWhiteColor);
            tableView.backgroundColor = KTextWhiteColor;
            tableView.separatorStyle=UITableViewCellSelectionStyleNone;
            weakify(self);
            tableView.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
                [weakSelf fetchData:YES change:NO state:i+1];
            }];
            tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
                ListModelManager *man = weakSelf.dataArray[i];
                man.page++;
                [weakSelf fetchData:NO change:NO state:i+1];
            }];
        }
    }
    return _scrollView;
}
- (NotesChangeView *)changeView {
    if (!_changeView) {
        _changeView = [[NotesChangeView alloc] initWithItems:@[@"待维修",@"维修中",@"已完成",@"已取消",@"不认可"]];
        weakify(self);
        _changeView.notesCallBack = ^(NSInteger selectIndex) {
            strongify(weakSelf);
            [strongSelf.scrollView setContentOffset:CGPointMake(KScreenWidth*selectIndex, 0) animated:NO];
            [strongSelf fetchData:NO change:YES state:selectIndex+1];
        };
    }
    return _changeView;
}

@end
