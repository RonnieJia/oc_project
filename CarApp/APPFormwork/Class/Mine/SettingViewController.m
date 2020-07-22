

#import "SettingViewController.h"
#import "RJBaseTableViewCell.h"
#import "AppEntrance.h"

@interface SettingViewController ()
@property(nonatomic, strong)CurrentUserInfo *info;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    [self setBackButton];
    [self.dataArray addObjectsFromArray:@[@[@"修改密码", @"修改手机号"], @[@"关于我们", @"常见问题", @"意见反馈"]]];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = kViewControllerBgColor;
    self.tableView.rowHeight = 50;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.tableView.sectionFooterHeight=10;
    [self setFooterView];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.dataArray[section];
    return arr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RJBaseTableViewCell *cell = [RJBaseTableViewCell cellWithTableView:tableView];
    cell.textLabel.textColor=KTextDarkColor;
    cell.textLabel.font = kFontWithSmallSize;
    cell.accessoryView = RJCreateSimpleImageView(CGRectMake(0, 0, 10, 12), [UIImage imageNamed:@"come002"]);
    cell.textLabel.text = self.dataArray[indexPath.section][indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 10), kViewControllerBgColor);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self.navigationController pushViewController:[NSClassFromString(@"ChangePWDViewController") new] animated:YES];
        } else if (indexPath.row == 1) {
            [self.navigationController pushViewController:[NSClassFromString(@"ChangeMobileViewController") new] animated:YES];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row== 0) {
            [self.navigationController pushViewController:[NSClassFromString(@"AboutViewController") new] animated:YES];
        } else if (indexPath.row == 1) {
            [self.navigationController pushViewController:[NSClassFromString(@"QuestionViewController") new] animated:YES];
        } else if (indexPath.row == 2) {
            [self.navigationController pushViewController:[NSClassFromString(@"SuggestViewController") new] animated:YES];
        }
    }
}

- (void)setFooterView {
    UIView *view = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 50), [UIColor whiteColor]);
    self.tableView.tableFooterView = view;
    
    UIButton *logoutBtn = RJCreateTextButton(view.bounds, kFontWithSmallSize, kTextRedColor, nil, @"退出登录");
    [logoutBtn addTarget:self action:@selector(logoutApp) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:logoutBtn];
}

- (void)logoutApp {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定退出登录？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [CurrentUserInfo userLogout];
        [AppEntrance setLoginForRoot];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

- (void)keyboardWasShown:(NSNotification *)noti {
    CGFloat hei = FetchKeyBoardHeight(noti);
    [UIView animateWithDuration:0.35 animations:^{
        self.tableView.height = KViewNavHeight-hei;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification *)noti {
    [UIView animateWithDuration:0.35 animations:^{
        self.tableView.height = KViewNavHeight;
    }];
    
}
@end
