
#import "ReservationDetailController.h"
#import "ReservationModel.h"

@interface ReservationDetailController ()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *carLabel;
@property (weak, nonatomic) IBOutlet UILabel *remarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *refuseBtn;

@property(nonatomic, strong)NSString *phoneNum;

@end

@implementation ReservationDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"预约详情";
    [self setBackButton];
    self.refuseBtn.layer.borderColor = KThemeColor.CGColor;
    self.refuseBtn.layer.borderWidth = 1;
    [self fetchData];
}

- (void)fetchData {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    self.clientDataTask = [kRJHTTPClient fetchReservationDetail:self.reservationModel.r_id completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [weakSelf displayInfo:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"info")];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)displayInfo:(NSDictionary *)dic{
    self.contentView.hidden=NO;
    self.bottomView.hidden=self.reservationModel.reservationState != ReservationStateWait;
    switch (self.reservationModel.reservationState) {
        case ReservationStateWait:
            self.stateLabel.text = @"待接单";
            break;
        case ReservationStateAccept:
            self.stateLabel.text = @"已接单";
            break;
        case ReservationStateRefuse:
            self.stateLabel.text = @"已拒绝";
            break;
        default:
            break;
    }
    self.timeLabel.text = getStringFromTimeintervalString(StringForKeyInUnserializedJSONDic(dic, @"a_time"), @"yyyy-MM-dd");
    self.carLabel.text = StringForKeyInUnserializedJSONDic(dic, @"v_name");
    self.remarkLabel.text = StringForKeyInUnserializedJSONDic(dic, @"a_content");
    self.userLabel.text = StringForKeyInUnserializedJSONDic(dic, @"o_nickname");
    self.phoneNum=StringForKeyInUnserializedJSONDic(dic, @"a_phone");
    self.phoneLabel.text = StringForKeyInUnserializedJSONDic(dic, @"a_phone");
}
- (IBAction)buttonAction:(UIButton *)sender {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient reservation:self.reservationModel.r_id receipt:sender.tag==1 completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            });
        }
        FailedMBProgressHUD(weakSelf.view, response.message);
    }];
}
- (IBAction)makePhone:(UIButton *)sender {
    makePhoneCall(self.phoneNum);
}

@end
