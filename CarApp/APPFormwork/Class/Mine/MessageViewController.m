//
#import "MessageViewController.h"
#import "MessageCell.h"
#import "MessageModel.h"
#import "MessageHeaderView.h"
#import "MsgDetailViewController.h"

@interface MessageViewController ()
@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic, strong)MessageHeaderView *headerView;
@end

@implementation MessageViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息";
    for (int i = 0; i<3; i++) {
        MessageManager *manager = [[MessageManager alloc] init];
        manager.type=i;
        [self.dataArray addObject:manager];
    }
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.scrollView];
    [self fetchMessage:0 refresh:YES scroll:NO];
}

- (void)fetchMessage:(NSInteger)type refresh:(BOOL)refresh scroll:(BOOL)scroll {
    MessageManager *manager = self.dataArray[type];
    if (refresh) {
        manager.page = kPageStartIndex;
    }
    if (scroll && manager.load) {
        return;
    }
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient fetchSystemMessage:self.page state:type completion:^(WebResponse *response) {
        UITableView *tableView = [weakSelf.scrollView viewWithTag:100+type];
        if (response.code == WebResponseCodeSuccess) {
            manager.load = YES;
            NSArray *tmp = [MessageModel listWithJSONArray:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"list")];
            if (tmp.count<kPageSize) {
                manager.noMore=YES;
            }
            if (manager.page == kPageStartIndex) {
                [manager.listArray removeAllObjects];
            }
            [manager.listArray addObjectsFromArray:tmp];
            [tableView reloadData];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
        [weakSelf tableView:tableView footerView:manager.listArray.count==0 height:KViewNavHeight-kIPhoneXBH-42];
    }];
}

#pragma mark - tableView DataSource
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MessageManager *man = self.dataArray[tableView.tag-100];
        MessageModel *model = man.listArray[indexPath.row];
        WaittingMBProgressHUD(self.view, @"");
        weakify(self);
        [kRJHTTPClient deleteSystemMessage:model.m_id completion:^(WebResponse *response) {
            if (response.code == WebResponseCodeSuccess) {
                [man.listArray removeObject:model];
                [tableView reloadData];
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    MessageManager *man = self.dataArray[tableView.tag-100];
    return man.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCell *cell = [MessageCell cellWithTableView:tableView];
    MessageManager *man = self.dataArray[tableView.tag-100];
    cell.msgModel = man.listArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MsgDetailViewController *msgDetail = [[MsgDetailViewController alloc] init];
    MessageManager *man = self.dataArray[tableView.tag-100];
    MessageModel *msg = man.listArray[indexPath.row];
    msg.is_look = YES;
    MessageCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.flagView.hidden=YES;
    msgDetail.msgModel = man.listArray[indexPath.row];
    [self.navigationController pushViewController:msgDetail animated:YES];
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
        self.headerView.selectIndex = index;
        [self fetchMessage:index refresh:NO scroll:YES];
    }
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 42, KScreenWidth, KViewNavHeight-42)];
        _scrollView.delegate = self;
        _scrollView.scrollEnabled = NO;
        for (int i = 0; i<3; i++) {
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(KScreenWidth*i, 0, KScreenWidth, _scrollView.height)];
            tableView.tag = 100+i;
            tableView.rowHeight = 140;
            tableView.backgroundColor = kViewControllerBgColor;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.delegate = self;
            tableView.dataSource = self;
            [_scrollView addSubview:tableView];
            _scrollView.pagingEnabled = YES;
            _scrollView.contentSize = CGSizeMake(KScreenWidth*3, KViewNavHeight-43);
        }
    }
    return _scrollView;
}

- (MessageHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[MessageHeaderView alloc] init];
        weakify(self);
        _headerView.msgHeaderCallBack = ^(NSInteger index) {
            [weakSelf.scrollView setContentOffset:CGPointMake(index * KScreenWidth, 0) animated:NO];
            [weakSelf fetchMessage:index refresh:NO scroll:YES];
        };
    }
    return _headerView;
}
@end
