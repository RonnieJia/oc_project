#import "GoodsSearchViewController.h"
#import "GoodsSearchHotView.h"
#import "ShopGoodsModel.h"
#import "GoodsListTableCell.h"
#import "ShopGoodsDetailViewController.h"

@interface GoodsSearchViewController ()<UITextFieldDelegate>
@property(nonatomic, strong)GoodsSearchHotView *hotView;
@property(nonatomic, strong)UITextField *searchTF;
@property(nonatomic, strong)NSString *keyword;
@property(nonatomic, strong)NSMutableArray *goodsArray;
@end

@implementation GoodsSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavBar];
    self.tableView.frame = CGRectMake(0, KNavBarHeight, KScreenWidth, KViewNavHeight);
    [self.view addSubview:self.tableView];
    self.tableView.rowHeight = 110;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.hidden=YES;
    [self.view addSubview:self.hotView];
}

- (void)searchGoods {
    self.hotView.hidden=YES;
    [self.view endEditing:YES];
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient fetchGoodsList:self.page cate:nil all:NO sort:0 goodsName:self.keyword completion:^(WebResponse *response) {
        weakSelf.tableView.hidden=NO;
      if (response.code == WebResponseCodeSuccess) {
            if (weakSelf.page == kPageStartIndex) {
                [weakSelf.goodsArray removeAllObjects];
            }
            NSArray *temp = [ShopGoodsModel listWithJSONArray:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"list")];
            if (temp.count<kPageSize) {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [weakSelf.tableView.mj_footer endRefreshing];
            }
            [weakSelf.goodsArray addObjectsFromArray:temp];
            [weakSelf.tableView reloadData];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            if (weakSelf.page>kPageStartIndex) {
                weakSelf.page--;
            }
            [weakSelf.tableView.mj_footer endRefreshing];
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

#pragma mark - tableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.goodsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GoodsListTableCell *cell = [GoodsListTableCell cellWithTableView:tableView];
    cell.goodsModel = self.goodsArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ShopGoodsModel *model = self.goodsArray[indexPath.row];
    ShopGoodsDetailViewController *detail = [[ShopGoodsDetailViewController alloc] init];
    detail.goods_id = model.goods_id;
    [self.navigationController pushViewController:detail animated:YES];
}
- (void)createNavBar {
    UIImageView *imgView = RJCreateSimpleImageView(CGRectMake(0, 0, KScreenWidth, KNavBarHeight), [UIImage imageNamed:@"picketback_hx"]);
    imgView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imgView];
    imgView.userInteractionEnabled=YES;
    
    UIButton *back = RJCreateImageButton(CGRectMake(0, StatusBarHeight, 35, 44), [UIImage imageNamed:@"back001"], nil);
    [imgView addSubview:back];
    [back addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *leftView = RJCreateSimpleView(CGRectMake(0, 0, 30, 30), KTextWhiteColor);
    UIImageView *imgViewL = RJCreateImageView(CGRectMake(0, 0, 30, 30), nil, [UIImage imageNamed:@"search002"], 0);
    imgViewL.contentMode = UIViewContentModeCenter;
    [leftView addSubview:imgViewL];
    imgViewL.center = CGPointMake(15, 15);
    UITextField *searchTF = RJCreateTextField(CGRectMake(35, 7+StatusBarHeight, KScreenWidth-48, 30), kFontWithSmallSize, KTextDarkColor, nil, KTextWhiteColor, leftView, nil, NO, @"请输入关键词进行搜索~", nil);
    [imgView addSubview:searchTF];
    searchTF.layer.cornerRadius = 15;
    searchTF.clipsToBounds = YES;
    searchTF.delegate = self;
    searchTF.returnKeyType = UIReturnKeySearch;
    self.searchTF = searchTF;
    
    
    
    UIView *right = RJCreateSimpleView(CGRectMake(0, 0, 60, 20), KTextWhiteColor);
    UIButton *searchBtn = RJCreateTextButton(CGRectMake(0, 0, 50, 20), kFontWithSmallSize, KTextWhiteColor, createImageWithColor(KThemeColor), @"搜索");
    searchBtn.layer.cornerRadius = 4;
    searchBtn.clipsToBounds = YES;
    [right addSubview:searchBtn];
    searchTF.rightView = right;
    searchTF.rightViewMode = UITextFieldViewModeAlways;
    [searchBtn addTarget:self action:@selector(seachbtnAction:) forControlEvents:UIControlEventTouchUpInside];
}
- (GoodsSearchHotView *)hotView {
    if (!_hotView) {
        _hotView = [[GoodsSearchHotView alloc] init];
        weakify(self);
        _hotView.GoodsSearchHot = ^(NSString * _Nonnull hot) {
            strongify(weakSelf);
            if (strongSelf.keyword && [strongSelf.keyword isEqualToString:hot]) {
                strongSelf.searchTF.text = hot;
            } else {
                strongSelf.searchTF.text = hot;
                strongSelf.keyword = hot;
                [strongSelf searchGoods];
            }
        };
    }
    return _hotView;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.hotView.hidden=NO;
    self.tableView.hidden=YES;
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.searchTF resignFirstResponder];
    if (self.keyword && [self.keyword isEqualToString:textField.text]) {
        
    } else {
        self.keyword = self.searchTF.text;
        [self searchGoods];
    }
    return YES;
}
- (void)resignInput {
    [self.view endEditing:YES];
}

- (void)seachbtnAction:(UIButton *)btn {
    if (IsStringEmptyOrNull(self.searchTF.text)) {
        ShowAutoHideMBProgressHUD(self.view, @"请输入搜索内容");
        return;
    }
    [self.searchTF resignFirstResponder];
    if (self.keyword && [self.keyword isEqualToString:self.searchTF.text]) {
        return;
    }
    self.keyword = self.searchTF.text;
    [self searchGoods];
}
- (NSMutableArray *)goodsArray {
    if (!_goodsArray) {
        _goodsArray = [NSMutableArray array];
    }
    return _goodsArray;
}
@end
