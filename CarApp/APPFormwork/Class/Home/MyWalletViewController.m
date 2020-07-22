
#import "MyWalletViewController.h"
#import "NSString+Code.h"

@interface MyWalletViewController ()
@property (weak, nonatomic) IBOutlet UIButton *profitBtn;
@property (weak, nonatomic) IBOutlet UIButton *moneyBtn;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;

@end

@implementation MyWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的钱包";
    [self setBackButton];
    [self createMainView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fetchWallet];
}

- (void)fetchWallet {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    self.clientDataTask = [kRJHTTPClient fetchMyWalletCompletion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            NSString *balance = [StringForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"balance") priceNum];
            NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥ %@",balance]];
            [att addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20] range:NSMakeRange(0, 1)];
            weakSelf.moneyLabel.attributedText = att;
            [CurrentUserInfo sharedInstance].balance = balance;
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)createMainView {
    self.view.backgroundColor = KTextWhiteColor;
    [self setButtonShadow:self.profitBtn];
    [self setButtonShadow:self.moneyBtn];
}

- (void)setButtonShadow:(UIButton *)btn {
    btn.layer.cornerRadius = 6;
    btn.layer.shadowColor = KTextDarkColor.CGColor;
    // 阴影偏移，默认(0, -3)
    btn.layer.shadowOffset = CGSizeMake(0,3);
    // 阴影透明度，默认0
    btn.layer.shadowOpacity = 0.3;
    // 阴影半径，默认3
    btn.layer.shadowRadius = 2;
}
- (IBAction)buttonClick:(UIButton *)sender {
    if (sender.tag == 1) {//  资金明细
        [self.navigationController pushViewController:[NSClassFromString(@"MoneyInfoViewController") new] animated:YES];
    } else {
        [self.navigationController pushViewController:[NSClassFromString(@"WithdrawCashViewController") new] animated:YES];
    }
}
- (IBAction)backClick:(id)sender {
    [self backBtnAction];
}
@end
