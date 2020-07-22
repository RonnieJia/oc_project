//

#import "CityListViewController.h"
#import "CityListModel.h"
#import "RJBaseTableViewCell.h"
#import "UserLocation.h"
#import "AppEntrance.h"

@interface CityListViewController ()<UITextFieldDelegate>
@property(nonatomic, strong)NSMutableArray *letterArray;
@property(nonatomic, strong)NSIndexPath *selectIndexPath;
@property(nonatomic, weak)UIView *serachView;
@property(nonatomic, strong)UIView *flagView;
@property(nonatomic, weak)UITextField *textField;
@property(nonatomic, weak)UIButton *cancelBtn;
@property(nonatomic, weak)UIButton *locationBtn;
@property(nonatomic, strong)NSMutableArray *sortArray;
@property(nonatomic, strong)UITableView *sortTableView;
@property(nonatomic, strong)NSMutableArray *citysArray;
@end

@implementation CityListViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择城市";
    [self setBackButton];
    weakify(self);
//    self.cityModel = [CurrentUserInfo sharedInstance].cityModel;
    if (!self.cityModel) {
        self.cityModel = [CityListModel new];
        self.cityModel.city_name = @"请选择";
    }
    [self setNavBarBtnWithType:NavBarTypeRight title:@"确定" action:^{
        strongify(weakSelf);
        if (!IsStringEmptyOrNull(strongSelf.cityModel.city_id)) {
            
        }
        if (strongSelf.isLogin) {
            if (!IsStringEmptyOrNull(strongSelf.cityModel.city_id)) {
//                [CurrentUserInfo sharedInstance].cityModel = strongSelf.cityModel;
                // 本地保存用户位置信息
                SaveUserCity(strongSelf.cityModel.city_name, strongSelf.cityModel.city_id);
                [AppEntrance setTabBarRoot];
            } else {
                ShowAutoHideMBProgressHUD(weakSelf.view, @"请选择当前城市");
            }
        } else {
//            if ([[CurrentUserInfo sharedInstance].cityModel.city_id isEqualToString:strongSelf.cityModel.city_id]) {
//                
//            } else {
//                [CurrentUserInfo sharedInstance].cityModel = strongSelf.cityModel;
//                // 本地保存用户位置信息
//                SaveUserCity(strongSelf.cityModel.city_name, strongSelf.cityModel.city_id);
//                if (strongSelf.cityChanged) {
//                    strongSelf.cityChanged();
//                }
//            }
            [strongSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
    self.tableView.frame = CGRectMake(0, 45, KScreenWidth, KViewNavHeight-45);
    [self.view addSubview:self.tableView];
    [self createSearchView];
    [self.view addSubview:self.flagView];
    [self.view addSubview:self.sortTableView];
    self.tableView.rowHeight = 44;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    [self fetchData];
}

- (void)fetchData {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    /*
    self.clientDataTask = [kRJHTTPClient fetchCityListWithCompletion:^(WebResponse *response) {
        strongify(weakSelf);
        if (response.code == WebResponseCodeSuccess) {
            NSDictionary *city_list = ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"city_list");
            [strongSelf.dataArray removeAllObjects];
            [strongSelf.letterArray removeAllObjects];
            [strongSelf.citysArray removeAllObjects];
            
            CityListModel *nowCity = [CityListModel new];
            nowCity.city_name = strongSelf.cityModel.city_name;
            nowCity.city_id = strongSelf.cityModel.city_id;
            [strongSelf.dataArray addObject:@[nowCity]];
            [strongSelf.letterArray addObject:@"#"];
            if (city_list && [city_list isKindOfClass:[NSDictionary class]]) {
                for (int i = 'A'; i<='Z'; i++) {
                    NSString *key = [NSString stringWithUTF8String:(char *)&i];
                    if ([city_list.allKeys containsObject:key]) {
                        NSArray *letterArr = [CityListModel listWithJSONArray:ObjForKeyInUnserializedJSONDic(city_list, key)];
                        if (letterArr.count>0) {
                            [strongSelf.letterArray addObject:key];
                            [strongSelf.dataArray addObject:letterArr];
                            [strongSelf.citysArray addObjectsFromArray:letterArr];
                        }
                    }
                }
            }
            [strongSelf.tableView reloadData];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
     */
}

- (CityListModel *)searchCityFromList:(NSString *)name {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"city_name CONTAINS %@",name];
    NSArray *filterArr = [self.citysArray filteredArrayUsingPredicate:predicate];
    if (filterArr.count>0) {
        return filterArr.firstObject;
    }
    return nil;
}

#pragma mark - tableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.sortTableView) {
        return 1;
    }
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.sortTableView) {
        return self.sortArray.count;
    }
    NSArray *arr = self.dataArray[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RJBaseTableViewCell *cell = [RJBaseTableViewCell cellWithTableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.textColor = KTextBlackColor;
    cell.textLabel.font = kFontWithSmallSize;
    CityListModel *model;
    if (tableView == self.sortTableView) {
        model = self.sortArray[indexPath.row];
    } else {
        model = self.dataArray[indexPath.section][indexPath.row];
    }
    cell.textLabel.text = model.city_name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.sortTableView) {
        self.cityModel = self.sortArray[indexPath.row];
    } else {
        self.cityModel = self.dataArray[indexPath.section][indexPath.row];
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.sortTableView) {
        return nil;
    }
    UIView *view = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 30), [UIColor colorWithHex:@"#F2F2F2"]);
    NSString *firstLetter = section==0?@"当前城市":self.letterArray[section];
    UILabel *titleL = RJCreateDefaultLable(CGRectMake(self.tableView.separatorInset.left, 0, KScreenWidth-30, 30), kFont(13), KTextBlackColor, firstLetter);
    [view addSubview:titleL];
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.sortTableView) {
        return 0;
    }
    return 30;
}

#pragma mark---tableView索引相关设置----
//添加索引栏标题数组
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.sortTableView) {
        return nil;
    }
    return self.letterArray;
}
//点击索引栏标题时执行
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([title isEqualToString:@"#"]) {
        [tableView setContentOffset:CGPointZero animated:NO];//tabview移至顶部
        return NSNotFound;
    } else {
        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
    }
}

- (void)createSearchView {
    UIView *view = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 45), KTextWhiteColor);
    [self.view addSubview:view];
    self.serachView = view;
    
    RJButton *locationBtn = [RJButton buttonWithFrame:CGRectMake(KScreenWidth-40, 0, 40, 45) title:@"定位" titleColor:KTextDarkColor titleFont:kFont(10) image:[UIImage imageNamed:@"position001"] selectImage:nil target:self selector:@selector(locationUserCity:)];
    locationBtn.margin = 2.5;
    locationBtn.type = RJButtonTypeTitleBottom;
    [view addSubview:locationBtn];
    self.locationBtn = locationBtn;
    
    UIButton *cancelBtn = RJCreateTextButton(CGRectMake(KScreenWidth-10-50, 0, 40, 45), kFontWithSmallSize, kTextBlueColor, nil, @"取消");
    self.cancelBtn = cancelBtn;
    cancelBtn.hidden=YES;
    [view addSubview:self.cancelBtn];
    [cancelBtn addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *leftSearchIcon = RJCreateSimpleImageView(CGRectMake(0, 0, 40, 29), [UIImage imageNamed:@"find"]);
    leftSearchIcon.contentMode = UIViewContentModeCenter;
    UITextField *textField = RJCreateTextField(CGRectMake(13, 8, locationBtn.left-13, 29), kFontWithSmallSize, KTextDarkColor, [UIColor colorWithHex:@"#999999"], [UIColor colorWithHex:@"#f2f2f2"], leftSearchIcon, nil, NO, @"搜索城市", nil);
    textField.returnKeyType = UIReturnKeySearch;
    textField.delegate = self;
    [textField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    textField.layer.cornerRadius = 5;
    textField.clipsToBounds=YES;
    self.textField = textField;
    [view addSubview:textField];
}

- (void)locationUserCity:(UIButton *)btn {
    if ([[UserLocation sharedInstance] canLocation]) {
        WaittingMBProgressHUD(self.view, @"正在定位中");
        weakify(self);
        [[UserLocation sharedInstance] useUserLocationInfoWithBlock:^{
            // 确保在main线程
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf userLocationCityCompletion];
            });
        }];
    } else {
        ShowAutoHideMBProgressHUD(self.view, @"请在设置中允许访问您的位置信息");
    }
    
}

- (void)userLocationCityCompletion {
    CityListModel *model = [self searchCityFromList:[[UserLocation sharedInstance] userCity]];
    if (model) {
        self.cityModel = model;
        [self.dataArray replaceObjectAtIndex:0 withObject:@[model]];
        [self.tableView reloadData];
        FinishMBProgressHUD(self.view);
    } else {
        FailedMBProgressHUD(self.view, @"定位失败，请稍后再试");
    }
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidChanged:(UITextField *)textField {
    if (textField.text.length==0) {
        [self.sortArray removeAllObjects];
        if (!self.sortTableView.hidden) {
            self.tableView.hidden = NO;
            self.flagView.hidden=NO;
            self.sortTableView.hidden=YES;
        }
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"city_name CONTAINS %@ || pinyin CONTAINS %@", textField.text,textField.text.lowercaseString];
        NSArray *filter = [self.citysArray filteredArrayUsingPredicate:predicate];
        [self.sortArray removeAllObjects];
        [self.sortArray addObjectsFromArray:filter];
        
        self.tableView.hidden = self.sortArray.count>0;
        self.flagView.hidden=self.sortArray.count>0;
        self.sortTableView.hidden=self.sortArray.count==0;
    }
    [self.sortTableView reloadData];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.flagView.hidden=NO;
    self.cancelBtn.hidden=NO;
    self.locationBtn.hidden=YES;
    self.textField.width = self.cancelBtn.left-10-self.textField.left;
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason {
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0) {
        [textField resignFirstResponder];
    }
    return YES;
}
- (void)cancelSearch {
    self.textField.text = nil;
    [self.textField resignFirstResponder];
    self.flagView.hidden = YES;
    self.cancelBtn.hidden=YES;
    self.sortTableView.hidden=YES;
    self.locationBtn.hidden=NO;
    [self.sortArray removeAllObjects];
    [self.sortTableView reloadData];
    self.tableView.hidden=NO;
    self.textField.width = self.locationBtn.left-self.textField.left;
}

- (UIView *)flagView {
    if (!_flagView) {
        _flagView = RJCreateSimpleView(CGRectMake(0, 45, KScreenWidth, KViewNavHeight-45), [KTextBlackColor colorWithAlphaComponent:0.3]);
        [_flagView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSearch)]];
        _flagView.hidden = YES;
    }
    return _flagView;
}
- (UITableView *)sortTableView {
    if (!_sortTableView) {
        _sortTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, KScreenWidth, KViewTabNavHeight-45)];
        _sortTableView.delegate = self;
        _sortTableView.dataSource = self;
        _sortTableView.rowHeight = 44;
        _sortTableView.tableFooterView = [UIView new];
        _sortTableView.hidden=YES;
    }
    return _sortTableView;
}
- (NSMutableArray *)sortArray {
    if (!_sortArray) {
        _sortArray = [@[] mutableCopy];
    }
    return _sortArray;
}


- (NSMutableArray *)letterArray {
    if (!_letterArray) {
        _letterArray = [@[] mutableCopy];
    }
    return _letterArray;
}
- (NSMutableArray *)citysArray {
    if (!_citysArray) {
        _citysArray = [@[] mutableCopy];
    }
    return _citysArray;
}
@end
