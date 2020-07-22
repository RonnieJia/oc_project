//
#import "AddressListViewController.h"
#import "AddressEditViewController.h"
#import "AddressListCell.h"
#import "AddressModel.h"

@interface AddressListViewController ()

@end

@implementation AddressListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"地址管理";
    [self setBackButton];
    weakify(self);
    [self setNavBarBtnWithType:NavBarTypeRight title:@"新增地址" action:^{
        strongify(weakSelf);
        AddressEditViewController *add = [[AddressEditViewController alloc] init];
        add.reloadAddressBlock = ^{
            [strongSelf fetchAddressList];
        };
        [strongSelf.navigationController pushViewController:add animated:YES];
    }];
    [self createMainView];
    [self fetchAddressList];
}

- (void)createMainView {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 80;
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KViewNavHeight);
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = kViewControllerBgColor;
    weakify(self);
    self.tableView.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
        [weakSelf fetchAddressList];
    }];
}

- (void)fetchAddressList {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    self.clientDataTask = [kRJHTTPClient fetchAddressListCompletion:^(WebResponse *response) {
        [weakSelf.tableView.mj_header endRefreshing];
        if (response.code == WebResponseCodeSuccess) {
            [weakSelf.dataArray removeAllObjects];
            [weakSelf.dataArray addObjectsFromArray:[AddressModel listWithJSONArray:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"list")]];
            [weakSelf.tableView reloadData];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)deleteAddress:(AddressModel *)address {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除该地址？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    weakify(self);
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        WaittingMBProgressHUD(self.view, @"");
        [kRJHTTPClient deleAddress:address.aid completion:^(WebResponse *response) {
            if (response.code == WebResponseCodeSuccess) {
                [weakSelf.dataArray removeObject:address];
                [weakSelf.tableView reloadData];
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
}

- (void)editAddress:(AddressModel *)address {
    AddressEditViewController *edit=[AddressEditViewController new];
    edit.model = address;
    weakify(self);
    edit.reloadAddressBlock = ^{
        strongify(weakSelf);
        [strongSelf fetchAddressList];
    };
    [self.navigationController pushViewController:edit animated:YES];
}

#pragma mark - tableView DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressListCell *cell = [AddressListCell cellWithTableView:tableView];
    cell.model = self.dataArray[indexPath.row];
    weakify(self);
    cell.editAddressBlock = ^(NSInteger tag, AddressModel * _Nonnull model) {
        if (tag == 100) {
            [weakSelf editAddress:model];
        } else if (tag == 101) {
            [weakSelf deleteAddress:model];
        }
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.chooseAddress) {
        if (self.addressBlock) {
            self.addressBlock(self.dataArray[indexPath.row]);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
