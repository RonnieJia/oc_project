
#import "MoneyInfoViewController.h"
#import "IncomeInfoCell.h"
#import "CashInfoCell.h"
#import "MoneyInfoModel.h"

@interface MoneyInfoViewController ()
@property(nonatomic, weak)UIButton *selectedBtn;
@property(nonatomic, weak)UIView *changeView;
@property(nonatomic, weak)UIScrollView *scrollView;
@property(nonatomic, strong)UITableView *incomeTableView;
@property(nonatomic, strong)UITableView *cashTableView;
@property(nonatomic, strong)NSMutableArray *incomeDataSources;
@property(nonatomic, strong)NSMutableArray *cashDataSources;
@property(nonatomic, assign)BOOL fetchCashData;
@property(nonatomic, assign)NSInteger cashPage;

@end

@implementation MoneyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"资金明细";
    [self setBackButton];
    [self createChangeView];
    [self createMainView];
    self.page = self.cashPage = kPageStartIndex;
    [self fetchData:2];
}

- (void)fetchData:(NSInteger)type {//1提现明细 2收入明细
    WaittingMBProgressHUD(self.view, @"");
    NSInteger page = (type==1?self.cashPage:self.page);
    weakify(self);
    [kRJHTTPClient fetchMoneyDetails:type page:page completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            if (type==1) {
                weakSelf.fetchCashData=YES;
            }
            NSArray *tmp = [MoneyInfoModel listWithJSONArray:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"list")];
            if (type==2) {
                if (page==kPageStartIndex) {
                    [weakSelf.incomeDataSources removeAllObjects];
                }
                if (tmp.count<kPageSize) {
                    [weakSelf.incomeTableView.mj_footer endRefreshingWithNoMoreData];
                } else {
                    [weakSelf.incomeTableView.mj_footer endRefreshing];
                }
                [weakSelf.incomeDataSources addObjectsFromArray:tmp];
                [weakSelf.incomeTableView reloadData];
            } else {
                if (page==kPageStartIndex) {
                    [weakSelf.cashDataSources removeAllObjects];
                }
                if (tmp.count<kPageSize) {
                    [weakSelf.cashTableView.mj_footer endRefreshingWithNoMoreData];
                } else {
                    [weakSelf.cashTableView.mj_footer endRefreshing];
                }
                [weakSelf.cashDataSources addObjectsFromArray:tmp];
                [weakSelf.cashTableView reloadData];
            }
            FinishMBProgressHUD(weakSelf.view);
        } else {
            if (type==2) {
                [weakSelf.incomeTableView.mj_footer endRefreshing];
                if (weakSelf.page>kPageStartIndex) {
                    weakSelf.page--;
                }
            } else {
                [weakSelf.cashTableView.mj_footer endRefreshing];
                if (weakSelf.cashPage>kPageStartIndex) {
                    weakSelf.cashPage--;
                }
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
        if (type==2) {
            [weakSelf tableView:weakSelf.incomeTableView footerCount:weakSelf.incomeDataSources.count height:KViewNavHeight-43-kIPhoneXBH];
        } else {
            [weakSelf tableView:weakSelf.cashTableView footerCount:weakSelf.cashDataSources.count height:KViewNavHeight-43-kIPhoneXBH];
        }
    }];
}
#pragma mark - tableView DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.cashTableView) {
        MoneyInfoModel *model = self.cashDataSources[indexPath.row];
        if (model.state == 2) {
            return 115;
        }
        return 75;
    }
    
    return 85;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.cashTableView) {
        return self.cashDataSources.count;
    }
    return self.incomeDataSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.incomeTableView) {
        IncomeInfoCell *cell = [IncomeInfoCell cellWithTableView:tableView];
        cell.model = self.incomeDataSources[indexPath.row];
        return cell;
    }
    CashInfoCell *cell = [CashInfoCell cellWithTableView:tableView];
    cell.infoModel = self.cashDataSources[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate && scrollView.tag == 900) {
        [self scrollDidEndMoving:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.tag == 900) {
        [self scrollDidEndMoving:scrollView];
    }
}

- (void)scrollDidEndMoving:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x > (KScreenWidth/2.0)?1:0;
    if (index==1 && !self.fetchCashData) {
        [self fetchData:1];
    }
    UIButton *btn = [self.changeView viewWithTag:100+index];
    [self changeButtonAction:btn];
}

- (void)createMainView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 42, KScreenWidth, KViewNavHeight-42)];
    scrollView.delegate = self;
    scrollView.tag = 900;
    [self.view addSubview:scrollView];
    scrollView.contentSize = CGSizeMake(KScreenWidth*2, scrollView.height-1);
    scrollView.pagingEnabled = YES;
    self.scrollView = scrollView;
    [scrollView addSubview:self.incomeTableView];
    [scrollView addSubview:self.cashTableView];
}

- (void)createChangeView {
    UIView *view = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 42), KTextWhiteColor);
    [self.view addSubview:view];
    self.changeView = view;
    
    UIButton *incomeBtn = RJCreateTextButton(CGRectMake(0, 5, KScreenWidth/2.0, 35), kFontWithDefaultSize, KTextDarkColor, createImageWithColor(KTextWhiteColor), @"资金明细");
    [incomeBtn setTitleColor:KTextWhiteColor forState:UIControlStateSelected];
    [incomeBtn setBackgroundImage:[UIImage imageNamed:@"menuback002"] forState:UIControlStateSelected];
    [view addSubview:incomeBtn];
    incomeBtn.selected=YES;
    self.selectedBtn = incomeBtn;
    incomeBtn.tag = 100;
    
    UIButton *cashBtn = RJCreateTextButton(CGRectMake(incomeBtn.right, 5, incomeBtn.width, incomeBtn.height), kFontWithDefaultSize, KTextDarkColor, createImageWithColor(KTextWhiteColor), @"提现明细");
    [cashBtn setTitleColor:KTextWhiteColor forState:UIControlStateSelected];
    [cashBtn setBackgroundImage:[UIImage imageNamed:@"menuback002"] forState:UIControlStateSelected];
    [view addSubview:cashBtn];
    cashBtn.tag = 101;
    [cashBtn addTarget:self action:@selector(cancelButtonHilighted:) forControlEvents:UIControlEventAllEvents];
    [incomeBtn addTarget:self action:@selector(cancelButtonHilighted:) forControlEvents:UIControlEventAllEvents];
    [incomeBtn addTarget:self action:@selector(changeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cashBtn addTarget:self action:@selector(changeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *sepLine = RJCreateSimpleView(CGRectMake(0, 40, KScreenWidth, 2), [UIColor colorWithHex:@"#437297"]);
    [view addSubview:sepLine];
}

- (void)changeButtonAction:(UIButton *)btn {
    if (btn.selected) {
        return;
    }
    self.selectedBtn.selected=NO;
    btn.selected=YES;
    self.selectedBtn = btn;
    [self.scrollView setContentOffset:CGPointMake((btn.tag-100)*KScreenWidth, 0) animated:NO];
    if (btn.tag == 101 && !self.fetchCashData) {// 请求提现明细数据
        [self fetchData:1];
    }
}

- (void)cancelButtonHilighted:(UIButton *)btn {
    btn.highlighted=NO;
}

- (NSMutableArray *)cashDataSources {
    if (!_cashDataSources) {
        _cashDataSources = [@[] mutableCopy];
    }
    return _cashDataSources;
}
- (NSMutableArray *)incomeDataSources {
    if (!_incomeDataSources) {
        _incomeDataSources = [@[] mutableCopy];
    }
    return _incomeDataSources;
}
- (UITableView *)incomeTableView {
    if (!_incomeTableView) {
        _incomeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, self.scrollView.height)];
        _incomeTableView.delegate = self;
        _incomeTableView.dataSource = self;
        _incomeTableView.tableFooterView=[UIView new];
        _incomeTableView.rowHeight = 85;
        _incomeTableView.backgroundColor = kViewControllerBgColor;
        _incomeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        weakify(self);
        _incomeTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
            weakSelf.page++;
            [weakSelf fetchData:2];
        }];
    }
    return _incomeTableView;
}
- (UITableView *)cashTableView {
    if (!_cashTableView) {
        _cashTableView = [[UITableView alloc] initWithFrame:CGRectMake(KScreenWidth, 0, KScreenWidth, self.scrollView.height)];
        _cashTableView.delegate = self;
        _cashTableView.dataSource = self;
        _cashTableView.tableFooterView=[UIView new];
        _cashTableView.backgroundColor = kViewControllerBgColor;
        _cashTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        weakify(self);
        _cashTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
            weakSelf.cashPage++;
            [weakSelf fetchData:1];
        }];
    }
    return _cashTableView;
}
@end
