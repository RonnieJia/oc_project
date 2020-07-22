
#import "ShopCategoryViewController.h"
#import "GoodsCateCollectionCell.h"
#import "GoodsCateTableCell.h"
#import "GoodsSearchViewController.h"
#import "ShopGoodsListViewController.h"
#import <objc/runtime.h>
@interface ShopCategoryViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, strong)UIImageView *adImgView;
@end
@implementation ShopCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavBar];
    [self createMainView];
    [self fetchGoodsCate];
}

- (void)fetchGoodsCate {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    self.clientDataTask = [kRJHTTPClient fetchGoodsCategoryCompletion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            NSDictionary *result = ObjForKeyInUnserializedJSONDic(response.responseObject, @"result");
            NSArray *list = ObjForKeyInUnserializedJSONDic(result, @"list");
            [weakSelf.dataArray removeAllObjects];
            [weakSelf.dataArray addObjectsFromArray:list];
            [weakSelf.tableView reloadData];
            [weakSelf.collectionView reloadData];
            [weakSelf reloadAtIndex:0];
            [weakSelf.adImgView rj_setImageWithPath:StringForKeyInUnserializedJSONDic(result, @"adv_name")];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)reloadAtIndex:(NSInteger)index {
    if (self.dataArray.count>index) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark - tableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GoodsCateTableCell *cell = [GoodsCateTableCell cellWithTableView:tableView];
    cell.titleLabel.text = StringForKeyInUnserializedJSONDic(self.dataArray[indexPath.row], @"category_name");
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *list = ObjForKeyInUnserializedJSONDic(self.dataArray[indexPath.row], @"last_list");
    if (list && list.count > 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataArray.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *list = ObjForKeyInUnserializedJSONDic(self.dataArray[section], @"last_list");
    if (list && [list isKindOfClass:[NSArray class]]) {
        return list.count;
    }
    return 0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GoodsCateCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"categoryCollectionCell" forIndexPath:indexPath];
    NSArray *list = ObjForKeyInUnserializedJSONDic(self.dataArray[indexPath.section], @"last_list");
    if (list && [list isKindOfClass:[NSArray class]]) {
        cell.titleLabel.text = StringForKeyInUnserializedJSONDic(list[indexPath.item], @"last_name");
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeMake(KScreenWidth-110, 50);
    } else {
        return CGSizeMake(KScreenWidth-110, 50+21);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"collectionHeader" forIndexPath:indexPath];
        UIView *sepLine = [view viewWithTag:998];
        UILabel *label = [view viewWithTag:999];
        if (!label) {
            label = RJCreateDefaultLable(CGRectMake(0, 0, KScreenWidth-120, 50), kFontWithSmallSize, KTextBlackColor, @"分类名字");
            [view addSubview:label];
            label.tag = 999;
        }
        label.text = StringForKeyInUnserializedJSONDic(self.dataArray[indexPath.section], @"category_name");
        label.bottom = view.height;
        if (indexPath.section == 0) {
            if (sepLine) {
                [sepLine removeFromSuperview];
            }
        } else {
            if (!sepLine) {
                sepLine = RJCreateSimpleView(CGRectMake(0, 20, KScreenWidth-110, 1), KSepLineColor);
                sepLine.tag = 998;
                [view addSubview:sepLine];
            }
        }
        return view;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ShopGoodsListViewController *goodsList = [ShopGoodsListViewController new];
    NSArray *list = ObjForKeyInUnserializedJSONDic(self.dataArray[indexPath.section], @"last_list");
    if (list && [list isKindOfClass:[NSArray class]]) {
        goodsList.cate_id = StringForKeyInUnserializedJSONDic(list[indexPath.row], @"last_id");
    }
    goodsList.cateArray = self.dataArray;
    [self.navigationController pushViewController:goodsList animated:YES];
}

- (void)createMainView {
    self.view.backgroundColor = KTextWhiteColor;
    self.tableView.frame = CGRectMake(0, KNavBarHeight, 93, KViewNavHeight);
    self.tableView.backgroundColor = kViewControllerBgColor;
    self.tableView.rowHeight = 54;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.collectionView];
}

- (void)createNavBar {
    UIImageView *imgView = RJCreateSimpleImageView(CGRectMake(0, 0, KScreenWidth, KNavBarHeight), [UIImage imageNamed:@"picketback_hx"]);
    imgView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imgView];
    imgView.userInteractionEnabled=YES;
    
    UIButton *back = RJCreateImageButton(CGRectMake(0, StatusBarHeight, 35, 44), [UIImage imageNamed:@"back001"], nil);
    [imgView addSubview:back];
    [back addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *searchBtn = RJCreateButton(CGRectMake(35, 7+StatusBarHeight, KScreenWidth-48, 30), kFontWithSmallSize, KTextDarkColor, KTextWhiteColor, nil, [UIImage imageNamed:@"search002"], @"  请输入关键词进行搜索");
    searchBtn.contentHorizontalAlignment = 1;
    searchBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [imgView addSubview:searchBtn];
    searchBtn.layer.cornerRadius = 15;
    searchBtn.clipsToBounds = YES;
    [searchBtn addTarget:self action:@selector(push2SearchVC) forControlEvents:UIControlEventTouchUpInside];
}

- (void)push2SearchVC {
    GoodsSearchViewController *search = [GoodsSearchViewController new];
    [self.navigationController pushViewController:search animated:YES];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 8;
        layout.minimumInteritemSpacing = 6;
        CGFloat wid = (KScreenWidth - 110 - 12)/3.0;
        layout.itemSize = CGSizeMake(wid, wid*0.6);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(100, KNavBarHeight, KScreenWidth-110, KViewNavHeight) collectionViewLayout:layout];
        _collectionView.backgroundColor = KTextWhiteColor;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[GoodsCateCollectionCell class] forCellWithReuseIdentifier:@"categoryCollectionCell"];
        _collectionView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0);
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionHeader"];
        _collectionView.showsVerticalScrollIndicator=NO;
        UIImageView *adImgView = RJCreateSimpleImageView(CGRectMake(0, -100, KScreenWidth-110, 100), nil);
        self.adImgView = adImgView;
        [_collectionView addSubview:adImgView];
        
    }
    return _collectionView;
}

@end
