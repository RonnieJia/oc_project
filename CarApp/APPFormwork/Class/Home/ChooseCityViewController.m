//
//  ChooseCityViewController.m
//  APPFormwork
#import "ChooseCityViewController.h"
#import "RJBaseTableViewCell.h"
#import "CityInfoModel.h"


@interface ChooseCityViewController ()

@end

@implementation ChooseCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self fetchCityList];
    self.title = @"选择城市";
}


- (void)fetchCityList {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    self.clientDataTask = [kRJHTTPClient fetchCityInfoCompletion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            NSArray *tmp = [CityInfoModel cityInfoList:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"list")];
            [weakSelf.dataArray addObjectsFromArray:tmp];
            [weakSelf.tableView reloadData];
            FinishMBProgressHUD(weakSelf.view);
        }else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

#pragma mark - tableView DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    CityInfoModel *model = self.dataArray[section];
    return model.firstLetter;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CityInfoModel *model = self.dataArray[section];
    return model.citys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RJBaseTableViewCell *cell = [RJBaseTableViewCell cellWithTableView:tableView];
    cell.textLabel.font = kFontWithSmallSize;
    cell.textLabel.textColor = KTextDarkColor;
    CityInfoModel *model = self.dataArray[indexPath.section];
    cell.textLabel.text = StringForKeyInUnserializedJSONDic(model.citys[indexPath.row], @"city");
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CityInfoModel *model = self.dataArray[indexPath.section];
    NSDictionary *dic = model.citys[indexPath.row];
    if (self.chooseCity) {
        self.chooseCity(StringForKeyInUnserializedJSONDic(dic, @"city"), StringForKeyInUnserializedJSONDic(dic, @"city_id"));
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
