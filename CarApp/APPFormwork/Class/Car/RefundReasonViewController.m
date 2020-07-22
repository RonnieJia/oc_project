//

#import "RefundReasonViewController.h"
#import "RefundReasonCell.h"

@interface RefundReasonViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *reasonTableView;
@property (nonatomic, assign)NSInteger selectIndex;
@property(nonatomic, weak)UITextView *textView;
@property(nonatomic, weak)UILabel *placeLabel;
@end

@implementation RefundReasonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.type!=0) {
        self.title = @"取消订单原因";
    } else {
        self.title = @"申请退款原因";
    }
    self.selectIndex=-1;
    self.reasonTableView.estimatedRowHeight = 65;
    self.reasonTableView.tableFooterView=[UIView new];
    self.reasonTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self fetchReason];
}

- (void)fetchReason {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient fetchRefundReason:self.type==0?2:1 completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [weakSelf.dataArray addObjectsFromArray:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"list")];
            [weakSelf.reasonTableView reloadData];
            [weakSelf tableViewFooterView];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

#pragma mark - tableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RefundReasonCell *cell = [RefundReasonCell cellWithTableView:tableView];
    cell.reasonLabel.text = StringForKeyInUnserializedJSONDic(self.dataArray[indexPath.row], @"title");
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    if (self.selectIndex != indexPath.row) {
        if (self.selectIndex>=0 && self.selectIndex < self.dataArray.count) {
            RefundReasonCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectIndex inSection:0]];
            cell.selectBtn.selected = NO;
        }
        self.selectIndex = indexPath.row;
        RefundReasonCell *cell2 = [tableView cellForRowAtIndexPath:indexPath];
        cell2.selectBtn.selected=YES;
    } else {
        
    }
}

- (IBAction)commitRefund:(id)sender {
    if (self.selectIndex<0) {
        if (self.type==1) {
            ShowAutoHideMBProgressHUD(self.view, @"请选择取消原因");
        } else {
            ShowAutoHideMBProgressHUD(self.view, @"请选择退款原因");
        }
        
        return;
    }
    if (self.textView.text.length==0) {
        ShowAutoHideMBProgressHUD(self.view, self.placeLabel.text);
        return;
    }
    NSString *title = StringForKeyInUnserializedJSONDic(self.dataArray[self.selectIndex], @"title");
    
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    if (self.type==1) {// 取消订单
        [kRJHTTPClient cancelRepairOrder:self.order_id type:self.cancelType title:title content:self.textView.text completion:^(WebResponse *response) {
            if (response.code == WebResponseCodeSuccess) {
                [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.cancelType==0?kFixOrderCancel:kRepairCancel object:weakSelf.obj];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
        }];
    } else {
        [kRJHTTPClient orderRefundMoney:self.order_id title:title content:self.textView.text completion:^(WebResponse *response) {
            if (response.code == WebResponseCodeSuccess) {
                if (self.refuseMoneySuccess) {
                    self.refuseMoneySuccess();
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
        }];
    }
}


- (void)tableViewFooterView {
    UIView *footer = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, 120), KTextWhiteColor);
    UIView *inputView = RJCreateSimpleView(CGRectMake(15, 20, KScreenWidth-30, 80), KTextWhiteColor);
    inputView.layer.borderColor = KSepLineColor.CGColor;
    inputView.layer.borderWidth = 1;
    [footer addSubview:inputView];
    
    UILabel *placeL = RJCreateDefaultLable(CGRectMake(3, 8, inputView.width-6, 16), kFontWithSmallSize, KTextGrayColor, self.type==0?@"简要描述你申请退货的原因":@"简要描述你取消订单的原因");
    [inputView addSubview:placeL];
    self.placeLabel = placeL;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, inputView.width, 80)];
    textView.font = kFontWithSmallSize;
    textView.backgroundColor = [UIColor clearColor];
    [inputView addSubview:textView];
    textView.delegate = self;
    textView.returnKeyType = UIReturnKeyDone;
    self.textView = textView;
    self.reasonTableView.tableFooterView = footer;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView {
    self.placeLabel.hidden = textView.text.length>0;
}

@end
