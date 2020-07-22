//

#import "ShowImageViewController.h"
#import "ImageCollectionViewCell.h"
#import "RJImagePickerManager.h"

@interface ShowImageViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, assign)__block BOOL changed;
@end

@implementation ShowImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.dataArray addObjectsFromArray:self.imgs];
    [self.view addSubview:self.collectionView];
    weakify(self);
    [self setNavBarBtnWithType:NavBarTypeRight title:@"确定" action:^{
        [weakSelf makeSureImages];
    }];
}

- (void)addImage {
    weakify(self);
    [[RJImagePickerManager sharedInstance] viewController:self showTitle:self.title callBack:^(UIImage *image) {
        weakSelf.changed = YES;
        [weakSelf.dataArray addObject:image];
        [weakSelf.collectionView reloadData];
    }];
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.dataArray.count) {
        [self addImage];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imgCell" forIndexPath:indexPath];
    if (indexPath.row==self.dataArray.count) {
        cell.closeBtn.hidden = YES;
        cell.imgView.image = [UIImage imageNamed:@"add002"];
    } else {
        id obj = self.dataArray[indexPath.row];
        if ([obj isKindOfClass:[UIImage class]]) {
            cell.imgView.image = obj;
        } else {
            [cell.imgView rj_setImageWithPath:obj placeholderImage:KDefaultImg];
        }
        weakify(self);
        cell.imageDeleteBlock = ^{
            weakSelf.changed = YES;
            [weakSelf.dataArray removeObjectAtIndex:indexPath.row];
            [weakSelf.collectionView reloadData];
        };
        cell.closeBtn.hidden = NO;
    }
    return cell;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(75, 75);
        layout.minimumLineSpacing=5;
        layout.minimumInteritemSpacing=5;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, KViewNavHeight) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.contentInset = UIEdgeInsetsMake(10, 13, 0, 13);
        [_collectionView registerNib:[UINib nibWithNibName:@"ImageCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"imgCell"];
        _collectionView.backgroundColor = kViewControllerBgColor;
    }
    return _collectionView;
}

- (void)makeSureImages {
    if (self.changed && self.changeImagesBlock) {
        self.changeImagesBlock(self.dataArray);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
