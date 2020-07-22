//

#import "RescueNotesViewController.h"
#import "NotesChangeView.h"
#import "NotesTableViewCell.h"
#import "RescueOrderViewController.h"
#import "RescueModel.h"
#import "RescueInfoViewController.h"
#import "MapLocationViewController.h"
#import "SceneView.h"

@interface RescueNotesViewController ()
@property(nonatomic, strong)NotesChangeView *changeView;
@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic, strong)UISwitch *sw;
@property(nonatomic, strong)SceneView *sceneView;
@end

@implementation RescueNotesViewController
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"救援记录";
    if (self.needBack) {
        [self setPopBackLeft];
    }
    for (int i = 0; i<4; i++) {
        ListModelManager *man = [[ListModelManager alloc] init];
        [self.dataArray addObject:man];
    }
    [self setBackButton];
    [self createMainView];
    if (self.state>0 && self.state<4) {
        [self.scrollView setContentOffset:CGPointMake(self.state*KScreenWidth, 0)];
        self.changeView.selectIndex = self.state;
        [self fetchData:YES scroll:YES index:self.state];
    } else {
        [self fetchData:YES scroll:YES index:0];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rescueOffer) name:kRescueOffer object:nil];
}

- (void)rescueOffer {
    UITableView *tableView = [self.scrollView viewWithTag:101];
    [tableView reloadData];
}

- (void)refreshCount {
    weakify(self);
    [kRJHTTPClient fetchRescue:0 page:kPageStartIndex completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            NSDictionary *result = ObjForKeyInUnserializedJSONDic(response.responseObject, @"result");
            weakSelf.sw.on = IntForKeyInUnserializedJSONDic(result, @"is_receipt")==1;
            for (int i = 0; i<4; i++) {
                [weakSelf.changeView count:IntForKeyInUnserializedJSONDic(result, [NSString stringWithFormat:@"count%d",i+1]) changeAtIndex:i];
            }
        }
    }];
}

- (void)fetchData:(BOOL)refresh scroll:(BOOL)scroll index:(NSInteger)index {
    ListModelManager *manager = self.dataArray[index];
    if (!refresh) {
        if (scroll && manager.load) {
            return;
        }
    } else {
        manager.page = kPageStartIndex;
        manager.noMoreData=NO;
    }
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    self.clientDataTask = [kRJHTTPClient fetchRescue:index page:manager.page completion:^(WebResponse *response) {
        UITableView *tableView = [weakSelf.scrollView viewWithTag:100+index];
        [tableView.mj_header endRefreshing];
        if (response.code == WebResponseCodeSuccess) {
            manager.load = YES;
            NSDictionary *result = ObjForKeyInUnserializedJSONDic(response.responseObject, @"result");
            weakSelf.sw.on = IntForKeyInUnserializedJSONDic(result, @"is_receipt")==1;
            for (int i = 0; i<4; i++) {
                [weakSelf.changeView count:IntForKeyInUnserializedJSONDic(result, [NSString stringWithFormat:@"count%d",i+1]) changeAtIndex:i];
            }
            if (manager.page == kPageStartIndex) {
                [manager.listArray removeAllObjects];
            }
            NSArray *temp = [RescueModel listWithJSONArray:ObjForKeyInUnserializedJSONDic(result, @"list")];
            if (temp.count<kPageSize) {
                manager.noMoreData=YES;
                [tableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [tableView.mj_footer endRefreshing];
            }
            [manager.listArray addObjectsFromArray:temp];
            [tableView reloadData];
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
    if (tableView.tag < 102) {
        return 135;
    }
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotesTableViewCell *cell = [NotesTableViewCell cellWithTableView:tableView];
    ListModelManager *man = self.dataArray[tableView.tag-100];
    if (man && man.listArray.count>indexPath.row) {
        RescueModel *model = man.listArray[indexPath.row];
        model.rescueState = tableView.tag-100;
        cell.rescueModel = model;
    }
    weakify(self);
    cell.locationBlock = ^(id  _Nonnull obj) {
        RescueModel *rM = obj;
        MapLocationViewController *location = [MapLocationViewController new];
        location.oName = rM.o_nickname;
        location.lat = rM.latitude;
        location.lon = rM.longitude;
        location.address = rM.r_position;
        [weakSelf.navigationController pushViewController:location animated:YES];
    };
    cell.rescueRefuseBlock = ^(id  _Nonnull obj) {// 待接单的拒绝
        [weakSelf waitRescueOrder:obj stateChange:NO];
    };
    cell.rescueAcceptBlock = ^(id  _Nonnull obj) {// 待接单接单
        [weakSelf waitRescueOrder:obj stateChange:YES];
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
        RescueModel *repair = manager.listArray[indexPath.row];
        WaittingMBProgressHUD(self.view, @"");
        weakify(self);
        self.clientDataTask = [kRJHTTPClient deleteRescue:repair.r_id completion:^(WebResponse *response) {
           if (response.code == WebResponseCodeSuccess) {
               [weakSelf refreshCount];
               [manager.listArray removeObject:repair];
               [tableView reloadData];
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
        }];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ListModelManager *man = self.dataArray[tableView.tag-100];
    if (tableView.tag == 100) {
        RescueInfoViewController *info = [RescueInfoViewController new];
        info.detail = YES;
        weakify(self);
        info.rescueOrderStateChange = ^(BOOL accept, RescueModel * _Nonnull model) {
            [weakSelf waitRescueOrder:model stateChange:accept];
        };
        info.rescueModel = man.listArray[indexPath.row];
        [self.navigationController pushViewController:info animated:YES];
    } else {
        weakify(self);
        RescueOrderViewController *rescueOrder = [RescueOrderViewController new];
        rescueOrder.rescueRepairComplete = ^{
            [weakSelf rescueOffer];
        };
        rescueOrder.rescueRepairRefuse = ^(RescueModel * _Nonnull model, BOOL complete) {
            ListModelManager *refuseMan = weakSelf.dataArray[complete?2:3];
            refuseMan.load=NO;
            refuseMan.noMoreData=NO;
            refuseMan.page = kPageStartIndex;
            [weakSelf fetchData:YES scroll:NO index:1];
        };
        rescueOrder.rescueModel = man.listArray[indexPath.row];
        [self.navigationController pushViewController:rescueOrder animated:YES];
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
        [self fetchData:NO scroll:YES index:index];
    }
}

/// 待接单状态订单接单、拒绝
- (void)waitRescueOrder:(RescueModel *)model stateChange:(BOOL)accept {
    if (accept) {
        ListModelManager *acceptMan = self.dataArray[1];
        acceptMan.load=NO;
        acceptMan.noMoreData=NO;
        acceptMan.page = kPageStartIndex;
    } else {
        ListModelManager *refuseMan = self.dataArray[3];
        refuseMan.load=NO;
        refuseMan.noMoreData=NO;
        refuseMan.page = kPageStartIndex;
    }
    [self fetchData:YES scroll:NO index:0];
}

- (void)createMainView {
    self.view.backgroundColor = KTextWhiteColor;
    UIView *authView = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 45), KTextWhiteColor);
    [self.view addSubview:authView];
    [authView addSubview:RJCreateDefaultLable(CGRectMake(12, 10, 100, 25), kFontWithSmallSize, KTextBlackColor, @"是否接单")];
    UISwitch *sw = [[UISwitch alloc] init];
    self.sw = sw;
    sw.centerY = authView.height/2.0;
    sw.right = KScreenWidth-13;
    sw.onTintColor = [UIColor colorWithHex:@"#00A3DE"];
    sw.tintColor = [UIColor colorWithHex:@"#00A3DE"];
    [authView addSubview:sw];
    [sw addTarget:self action:@selector(changeRescueReceiptState:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.changeView];
    [self.view addSubview:self.scrollView];
}

/// 是否开启接单
- (void)changeRescueReceiptState:(UISwitch *)sw {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient openRescue:sw.isOn completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            
        } else {
        }
        FailedMBProgressHUD(weakSelf.view, response.message);
    }];
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 95, KScreenWidth, KViewNavHeight-95)];
        _scrollView.delegate=self;
        _scrollView.pagingEnabled=YES;
        _scrollView.scrollEnabled = NO;
        _scrollView.contentSize=CGSizeMake(KScreenWidth*4, KViewNavHeight-96);
        for (int i = 0; i<4; i++) {
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(i*KScreenWidth, 0, KScreenWidth, self.scrollView.height)];
            [_scrollView addSubview:tableView];
            tableView.tag = 100+i;
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.estimatedRowHeight = 90;
            tableView.tableFooterView = [UIView new];
            tableView.tableHeaderView = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 10), KTextWhiteColor);
            tableView.backgroundColor = KTextWhiteColor;
            tableView.separatorStyle=UITableViewCellSelectionStyleNone;
            weakify(self);
            tableView.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
                [weakSelf fetchData:YES scroll:NO index:i];
            }];
            tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
                ListModelManager *man = weakSelf.dataArray[i];
                man.page++;
                [weakSelf fetchData:NO scroll:NO index:i];
            }];
        }
    }
    return _scrollView;
}
- (NotesChangeView *)changeView {
    if (!_changeView) {
        _changeView = [[NotesChangeView alloc] initWithItems:@[@"待接单",@"已接单",@"已完成",@"已拒绝"]];
        _changeView.top = 45;
        weakify(self);
        _changeView.notesCallBack = ^(NSInteger selectIndex) {
            strongify(weakSelf);
            [strongSelf.scrollView setContentOffset:CGPointMake(KScreenWidth*selectIndex, 0) animated:NO];
            [weakSelf fetchData:NO scroll:YES index:selectIndex];
        };
    }
    return _changeView;
}
- (SceneView *)sceneView {
    if (!_sceneView) {
        _sceneView = [[SceneView alloc] init];
    }
    return _sceneView;
}
@end
