

#import "GoodsListCateView.h"
#import "GoodsCateTableCell.h"

@interface GoodsListCateView ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong)UITableView *leftTableView;
@property(nonatomic, strong)UITableView *rightTableView;
@property(nonatomic, assign)NSInteger selectIndex;
@end

@implementation GoodsListCateView

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 45, KScreenWidth, KViewNavHeight-45)];
    if (self) {
        self.backgroundColor = [KTextBlackColor colorWithAlphaComponent:0.35];
        [self addSubview:self.leftTableView];
        [self addSubview:self.rightTableView];
        UIView *bottomView = RJCreateSimpleView(CGRectMake(0, self.leftTableView.bottom, KScreenWidth, self.height-self.leftTableView.height), [UIColor clearColor]);
        [self addSubview:bottomView];
        [bottomView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSelf)]];
        
    }
    return self;
}
- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    if (dataArray.count>0) {
        self.selectIndex = 0;
        [self.leftTableView reloadData];
        [self.leftTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
        
    }
}
- (void)hideSelf {
    self.hidden=YES;
}

#pragma mark - tableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.leftTableView) {
        return 1;
    }
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.leftTableView) {
        if (self.dataArray && [self.dataArray isKindOfClass:[NSArray class]]) {
            return self.dataArray.count;
        }
    } else {
        if (section==0) {
            return 1;
        }
        NSArray *arr = ObjForKeyInUnserializedJSONDic(self.dataArray[self.selectIndex], @"last_list");
        if (arr && [arr isKindOfClass:[NSArray class]]) {
            return arr.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.leftTableView) {
        GoodsCateTableCell *cell = [GoodsCateTableCell cellWithTableView:tableView];
        cell.titleLabel.font = kFontWithSmallestSize;
        cell.titleLabel.textColor = KTextGrayColor;
        cell.titleLabel.text = StringForKeyInUnserializedJSONDic(self.dataArray[indexPath.row], @"category_name");
        return cell;
    }
    RJBaseTableViewCell *cell = [RJBaseTableViewCell cellWithTableView:tableView];
    cell.textLabel.font = kFontWithSmallSize;
    cell.textLabel.textColor = KTextDarkColor;
    if (indexPath.section==0) {
        cell.textLabel.text = @"全部";
    } else {
        NSArray *arr = ObjForKeyInUnserializedJSONDic(self.dataArray[self.selectIndex], @"last_list");
        cell.textLabel.text = StringForKeyInUnserializedJSONDic(arr[indexPath.row], @"last_name");
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.leftTableView) {
        if (self.selectIndex == indexPath.row) {
            return;
        }
        self.selectIndex = indexPath.row;
        [self.rightTableView reloadData];
    } else {
        if (indexPath.section==0) {
            if (self.goodsCateBlock) {
                self.goodsCateBlock(StringForKeyInUnserializedJSONDic(self.dataArray[indexPath.row], @"category_id"), YES);
            }
        } else {
            NSArray *arr = ObjForKeyInUnserializedJSONDic(self.dataArray[self.selectIndex], @"last_list");
            if (self.goodsCateBlock) {
                self.goodsCateBlock(StringForKeyInUnserializedJSONDic(arr[indexPath.row], @"last_id"), NO);
            }
        }
        self.hidden=YES;
    }
}

- (UITableView *)leftTableView {
    if (!_leftTableView) {
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 93, KAUTOSIZE(400))];
        _leftTableView.delegate = self;
        _leftTableView.dataSource = self;
        _leftTableView.rowHeight = 45;
        _leftTableView.tableFooterView = [UIView new];
        _leftTableView.separatorInset = UIEdgeInsetsZero;
    }
    return _leftTableView;
}

- (UITableView *)rightTableView {
    if (!_rightTableView) {
        _rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(93, 0, KScreenWidth-93, KAUTOSIZE(400))];
        _rightTableView.delegate = self;
        _rightTableView.dataSource = self;
        _rightTableView.rowHeight = 45;
        _rightTableView.tableFooterView = [UIView new];
    }
    return _rightTableView;
}

@end
