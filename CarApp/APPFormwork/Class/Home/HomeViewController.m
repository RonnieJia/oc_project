#import "HomeViewController.h"
#import "HomeTableViewCell.h"
#import "HomeHeaderView.h"
#import "MessageViewController.h"
#import "ChatViewController.h"
#import "HomeCompleteInfoView.h"
#import "ShopInfoViewController.h"

@interface HomeViewController ()
@property(nonatomic, strong)UIButton *cityBtn;
@property(nonatomic, strong)HomeHeaderView *header;
@property(nonatomic, assign)__block BOOL notFirstTime;
@property(nonatomic, strong)HomeCompleteInfoView *compleView;
@property(nonatomic, assign)NSInteger index;
@property(nonatomic, strong)NSString *support_phone;
@end

@implementation HomeViewController
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fetchShopInfo];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"瞪羚康达";
    [self createMainView];
}

- (void)fetchShopInfo {
    weakify(self);
    if (!self.notFirstTime && self.index>0) {
        WaittingMBProgressHUD(KKeyWindow, @"");
    }
    self.index = 1;
    [kRJHTTPClient fetchShopInfoCompletion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            NSDictionary *result = ObjForKeyInUnserializedJSONDic(response.responseObject, @"result");
            NSArray *bannerList = ObjForKeyInUnserializedJSONDic(result, @"banner_list");
            if (bannerList && [bannerList isKindOfClass:[NSArray class]] && bannerList.count>0) {
                [weakSelf.dataArray removeAllObjects];
                for (NSDictionary *picItem in bannerList) {
                    [weakSelf.dataArray addObject:StringForKeyInUnserializedJSONDic(picItem, @"pcture")];
                }
                [weakSelf.tableView reloadData];
            }
            NSDictionary *info = ObjForKeyInUnserializedJSONDic(result, @"info");
            weakSelf.support_phone = StringForKeyInUnserializedJSONDic(info, @"support_phone");
            [weakSelf.header refreshCount:info];
            [CurrentUserInfo sharedInstance].alipay_name = StringForKeyInUnserializedJSONDic(info, @"alipay_name");
            [CurrentUserInfo sharedInstance].alipay_number = StringForKeyInUnserializedJSONDic(info, @"alipay_number");
            NSInteger state = IntForKeyInUnserializedJSONDic(info, @"state");
            if (state != 2) {
                ClearUser();
                [self showCompleteView];
            } else {
                self.notFirstTime = YES;
            }
            
        }
        FinishMBProgressHUD(KKeyWindow);
    }];
}


- (void)showCompleteView {
    UIView *view = [KKeyWindow viewWithTag:9999];
    if (view) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showCompleteView];
        });
        return;
    }
    weakify(self);
    [self.compleView show:^{
        strongify(weakSelf);
        ShopInfoViewController *info = [[ShopInfoViewController alloc] init];
        info.first = YES;
        [strongSelf.navigationController pushViewController:info animated:YES];
    }];
}

- (void)createMainView {
    self.view.backgroundColor = KTextWhiteColor;
    [self setScrollViewAdjustsScrollViewInsets:self.tableView];
    self.tableView.bounces=NO;
    self.tableView.rowHeight = (KScreenWidth-20) * 14.0 / 49.0 + 10;
    self.tableView.tableHeaderView = self.header;
    [self.view addSubview:self.tableView];
    weakify(self);
    self.header.headerItemClick = ^(NSInteger index, NSString * _Nonnull cla) {
        strongify(weakSelf);
        if (index==6) {
            [JMSGConversation createSingleConversationWithUsername:kPlatformWord appKey:kPlatformAppKey completionHandler:^(id resultObject, NSError *error) {
                if (!error && resultObject && [resultObject isKindOfClass:JMSGConversation.class]) {
                    ChatViewController *chat = [[ChatViewController alloc] init];
                    chat.conversation=resultObject;
                    [strongSelf.navigationController pushViewController:chat animated:YES];
                } else {
                    
                }
            }];
            return ;
        }
        if (index == 7) {
            makePhoneCall(strongSelf.support_phone);
            return;
        }
        if (cla) {
            UIViewController *vc = [NSClassFromString(cla) new];
            if (vc && [vc isKindOfClass:[UIViewController class]]) {
                [strongSelf.navigationController pushViewController:vc animated:YES];
            }
        }
    };
}

#pragma mark - tableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeTableViewCell *cell = [HomeTableViewCell cellWithTableView:tableView];
    [cell.iconImgView rj_setImageWithPath:self.dataArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (UIButton *)cityBtn {
    if (!_cityBtn) {
        _cityBtn = RJCreateButton(CGRectMake(0, 0, 90, 30), kFontWithSmallestSize, KTextWhiteColor, nil, nil, [UIImage imageNamed:@""], @"济南");
    }
    return _cityBtn;
}

- (HomeHeaderView *)header {
    if (!_header) {
        _header = [[HomeHeaderView alloc] init];
    }
    return _header;
}

- (HomeCompleteInfoView *)compleView {
    if (!_compleView) {
        _compleView = [[HomeCompleteInfoView alloc] init];
    }
    return _compleView;
}

@end
