
#import "GoodsSearchHotView.h"
#import "Masonry.h"
#import "NSString+Code.h"

@interface GoodsSearch_CollectionCell : UICollectionViewCell
@property(nonatomic, strong)UILabel *nameLabel;
@end

@implementation GoodsSearch_CollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kViewControllerBgColor;
        UIView *containerView = RJCreateSimpleView(CGRectZero, [UIColor colorWithHex:@"#BCBCBC"]);
        [self.contentView addSubview:containerView];
        containerView.layer.cornerRadius=self.height/2.0;
        containerView.clipsToBounds=YES;
        [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
        UILabel *label = RJCreateLable(CGRectZero, kFontWithSmallSize, KTextWhiteColor, NSTextAlignmentCenter, nil);
        [containerView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(9);
            make.right.mas_equalTo(-9);
            make.top.and.bottom.mas_equalTo(0);
        }];
        self.nameLabel = label;
        
    }
    return self;
}

@end



@interface GoodsSearchHotView ()<UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>
@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, strong)NSArray *hotsArray;
@end

@implementation GoodsSearchHotView

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, KNavBarHeight, KScreenWidth, KViewNavHeight)];
    if (self) {
        self.backgroundColor = kViewControllerBgColor;
        UILabel *label = RJCreateDefaultLable(CGRectMake(10, 30, 30, 25), kFontWithSmallSize, KTextGrayColor, @"热门");
        [label sizeToFit];
        label.height = 25;
        [self addSubview:label];
        
        self.collectionView.left = label.right+10;
        self.collectionView.width = KScreenWidth-label.right-20;
        [self addSubview:self.collectionView];
        [self fetchHotData];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UICollectionView class]] || [touch.view isKindOfClass:[self class]]) {
        return YES;
    }
    return NO;
}

- (void)tapAction {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (void)fetchHotData {
    WaittingMBProgressHUD(self, @"");
    weakify(self);
    [kRJHTTPClient fetchSearchHotCompletion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            NSString *keyword = StringForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"goods_keyword");
            if (keyword && [keyword isKindOfClass:[NSString class]]) {
                NSArray *arr;
                if ([keyword containsString:@","]) {
                   arr = [keyword componentsSeparatedByString:@","];
                } else {
                    if([keyword containsString:@"，"]) {
                        arr = [keyword componentsSeparatedByString:@"，"];
                    }
                }
                if (arr) {
                    weakSelf.hotsArray = arr;
                    [weakSelf.collectionView reloadData];
                }
            }
            FinishMBProgressHUD(weakSelf);
        } else {
            FailedMBProgressHUD(weakSelf, response.message);
        }
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.hotsArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *str = self.hotsArray[indexPath.item];
    return CGSizeMake([str widthWithMaxWid:collectionView.width font:14]+20, 25);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GoodsSearch_CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.nameLabel.text = self.hotsArray[indexPath.item];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.GoodsSearchHot) {
        NSString *hot = [NSString stringWithFormat:@"%@",self.hotsArray[indexPath.item]];
        if (hot.length>0) {
            self.GoodsSearchHot(hot);
        }
        
    }
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(100, 30, KScreenWidth-110, KViewNavHeight) collectionViewLayout:layout];
        _collectionView.backgroundColor = kViewControllerBgColor;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
//        _collectionView.contentInset = UIEdgeInsetsMake(30, 0, 0, 0);
        _collectionView.showsVerticalScrollIndicator=NO;
        [_collectionView registerClass:[GoodsSearch_CollectionCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}
@end
