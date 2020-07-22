#import "CarViewController.h"
#import "ShopHeaderView.h"
#import "ShopCollectionViewCell.h"
#import "ShopGoodsDetailViewController.h"
#import "ShopGoodsModel.h"
#import "ShopItemView.h"

@interface CarViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, strong)ShopHeaderView *headerView;
@property(nonatomic, strong)ShopItemView *itemView;
@property(nonatomic, assign)BOOL loadCollect;
@end

@implementation CarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"配件商城";
    self.page = kPageStartIndex;
    [self fetchData];
}

- (void)fetchData {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient fetchShop:self.page completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            if (weakSelf.page == kPageStartIndex) {
                [weakSelf.dataArray removeAllObjects];
            }
            NSDictionary *result = ObjForKeyInUnserializedJSONDic(response.responseObject, @"result");
            NSArray *temp = [ShopGoodsModel listWithJSONArray:ObjForKeyInUnserializedJSONDic(result, @"list")];
            [weakSelf.dataArray addObjectsFromArray:temp];
            [weakSelf createMainView:result];
            if (temp.count<kPageSize) {
                [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [weakSelf.collectionView.mj_footer endRefreshing];
            }
            FinishMBProgressHUD(weakSelf.view);
        } else {
            if (weakSelf.page>kPageStartIndex) {
                weakSelf.page--;
            }
            [weakSelf.collectionView.mj_footer endRefreshing];
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
        [weakSelf.collectionView.mj_header endRefreshing];
    }];
}

- (void)createMainView:(NSDictionary *)result {
    if (!self.loadCollect) {
        self.loadCollect = YES;
        [self.headerView display:result];
        [self.view addSubview:self.itemView];
        [self.view addSubview:self.collectionView];
        weakify(self);
        self.headerView.shopHeaderBannerBlock = ^(NSString * _Nullable goods_id) {
            ShopGoodsDetailViewController *detail = [ShopGoodsDetailViewController new];
            detail.goods_id = goods_id;
            [weakSelf.navigationController pushViewController:detail animated:YES];
        };
    }
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ShopGoodsDetailViewController *detail = [ShopGoodsDetailViewController new];
    ShopGoodsModel*goods = self.dataArray[indexPath.item];
    detail.goods_id = goods.goods_id;
    [self.navigationController pushViewController:detail animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"shopHeader" forIndexPath:indexPath];
        [self.headerView removeFromSuperview];
        [header addSubview:self.headerView];
        return header;
    }
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ShopCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"shopCell" forIndexPath:indexPath];
    cell.goodsModel = self.dataArray[indexPath.item];
    return cell;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.headerReferenceSize = CGSizeMake(KScreenWidth, self.headerView.height);
        layout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
        layout.itemSize = CGSizeMake((KScreenWidth-36)/2.0, (KScreenWidth-36)/2.0 + 90);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.itemView.height, KScreenWidth, KViewTabNavHeight-self.itemView.height) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"shopHeader"];
        [_collectionView registerNib:[UINib nibWithNibName:@"ShopCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"shopCell"];
        _collectionView.backgroundColor = kViewControllerBgColor;
        weakify(self);
        _collectionView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
            weakSelf.page++;
            [weakSelf fetchData];
        }];
        _collectionView.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
            weakSelf.page = kPageStartIndex;
            [weakSelf fetchData];
        }];
    }
    return _collectionView;
}
- (ShopHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[ShopHeaderView alloc] init];
        
    }
    return _headerView;
}

- (ShopItemView *)itemView {
    if (!_itemView) {
        _itemView = [[ShopItemView alloc] init];
        weakify(self);
        _itemView.shopHeaderCallBack = ^(NSInteger index, NSString * _Nullable cla) {
            strongify(weakSelf);
            if (cla) {
                UIViewController *vc = [NSClassFromString(cla) new];
                if (vc && [vc isKindOfClass:[UIViewController class]]) {
                    [strongSelf.navigationController pushViewController:vc animated:YES];
                }
            }
        };
    }
    return _itemView;
}
@end
