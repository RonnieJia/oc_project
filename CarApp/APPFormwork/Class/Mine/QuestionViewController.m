//
#import "QuestionViewController.h"
#import "RJBaseTableViewCell.h"
#import "QuestionDetailViewController.h"

@interface QuestionViewController ()

@end

@implementation QuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"常见问题";
    [self setBackButton];
    [self createMainView];
    [self fetchData];
}

- (void)fetchData {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    self.clientDataTask = [kRJHTTPClient fetchQuestionWithPage:self.page completion:^(WebResponse *response) {
        [weakSelf.tableView.mj_header endRefreshing];
        if (response.code == WebResponseCodeSuccess) {
            if (weakSelf.page == kPageStartIndex) {
                [weakSelf.dataArray removeAllObjects];
            }
            NSArray *tmp = ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"list");
            if (tmp && [tmp isKindOfClass:[NSArray class]]) {
                [weakSelf.dataArray addObjectsFromArray:tmp];
                if (tmp.count<kPageSize) {
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                } else {
                    [weakSelf.tableView.mj_footer endRefreshing];
                }
            } else {
                [weakSelf.tableView.mj_footer endRefreshing];
            }
            [weakSelf.tableView reloadData];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *he = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 35), kViewControllerBgColor);
    [he addSubview:RJCreateDefaultLable(CGRectMake(15, 0, 100, 35), kFont(13), KTextDarkColor, @"热门问题")];
    return he;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = self.dataArray[indexPath.row];
    QuestionDetailViewController *de =[QuestionDetailViewController new];
    de.dic = dic;
    [self.navigationController pushViewController:de animated:YES];
}

- (void)createMainView {
    self.tableView.backgroundColor = kViewControllerBgColor;
    self.tableView.sectionHeaderHeight = 35;
    [self.view addSubview:self.tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RJBaseTableViewCell *cell = [RJBaseTableViewCell cellWithTableView:tableView];
    cell.textLabel.font = kFontWithSmallSize;
    cell.textLabel.textColor = KTextDarkColor;
    NSDictionary *dic = self.dataArray[indexPath.row];
    cell.textLabel.text = StringForKeyInUnserializedJSONDic(dic, @"q_title");
    return cell;
}
@end
