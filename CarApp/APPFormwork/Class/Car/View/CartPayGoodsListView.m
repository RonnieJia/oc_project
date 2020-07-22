//

#import "CartPayGoodsListView.h"
#import "Masonry.h"
#import "CartPayGoodsCell.h"
#import "ShopGoodsModel.h"

@interface CartPayGoodsListView ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, assign)BOOL loadMain;

@property(nonatomic, strong)SkuModel *sku;
@property(nonatomic, strong)ShopGoodsModel *goods;
@property(nonatomic, assign)NSInteger num;
@end

@implementation CartPayGoodsListView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self createMainView];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [self createMainView];
}
- (void)createMainView {
    if(self.loadMain) return;
    self.loadMain=YES;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    [self addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(5, 0, 5, 0));
    }];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 80;
    self.tableView = tableView;
    tableView.bounces=NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    [self.tableView reloadData];
}
- (void)buy:(ShopGoodsModel *)goods sku:(SkuModel *)sku num:(NSInteger)num {
    self.buyNow = YES;
    self.goods = goods;
    self.sku = sku;
    self.num = num;
    [self.tableView reloadData];
}
#pragma mark - tableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.buyNow) {
        return 1;
    }
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CartPayGoodsCell *cell = [CartPayGoodsCell cellWithTableView:tableView];
    if (self.buyNow) {
        weakify(self);
        cell.payChangeNumBlock = ^(NSInteger num) {
            weakSelf.num = num;
            if (weakSelf.changeNumBlock) {
                weakSelf.changeNumBlock(num);
            }
        };
        if (self.goods) {
            [cell displsyBuy:self.goods sku:self.sku num:self.num];
        }
    } else {
        cell.model = self.dataArray[indexPath.row];
        weakify(self);
        cell.payChangeNumBlock = ^(NSInteger num) {
            if (weakSelf.changeNumBlock) {
                weakSelf.changeNumBlock(num);
            }
        };
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
