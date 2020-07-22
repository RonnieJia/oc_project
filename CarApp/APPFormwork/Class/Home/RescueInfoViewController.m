//

#import "RescueInfoViewController.h"
#import "RescueModel.h"
#import "MapLocationViewController.h"

@interface RescueInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UILabel *carL;
@property (weak, nonatomic) IBOutlet UILabel *remarkL;
@property (weak, nonatomic) IBOutlet UILabel *driverL;
@property (weak, nonatomic) IBOutlet UILabel *phoneL;
@property (weak, nonatomic) IBOutlet UILabel *positionL;
@property (weak, nonatomic) IBOutlet UIButton *refuseBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end

@implementation RescueInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"救援详情";
    self.refuseBtn.layer.borderColor = KThemeColor.CGColor;
    self.refuseBtn.layer.borderWidth=1;
    [self setBackButton];
    if (self.detail) {
        [self fetchDetail];
    } else {
        [self displayInfo];
    }
}

- (void)fetchDetail {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    self.clientDataTask = [kRJHTTPClient fetchRescueDetail:self.rescueModel.r_id completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [weakSelf.rescueModel loadRescueDetail:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"info")];
            [weakSelf displayInfo];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)displayInfo {
    self.bottomView.hidden=(self.rescueModel.rescueState!=RescueStateWait);
    switch (self.rescueModel.rescueState) {
        case RescueStateWait:
            self.stateLabel.text = @"待接单";
            break;
        case RescueStateAccept:
            self.stateLabel.text = @"已接单";
            break;
        case RescueStateFinish:
            self.stateLabel.text = @"已完成";
            break;
        case RescueStateRefuse:
            self.stateLabel.text = @"已拒绝";
            break;
        default:
            break;
    }
    self.timeL.text = getStringFromTimeintervalString(self.rescueModel.create_time, @"yyyy-MM-dd HH:mm");
    self.carL.text = self.rescueModel.v_name;
    self.remarkL.text = self.rescueModel.r_content;
    self.driverL.text = self.rescueModel.r_name;
    self.phoneL.text = self.rescueModel.r_phone;
    self.positionL.text = self.rescueModel.r_position;
}
- (IBAction)acceptOrder:(id)sender {
    if (self.rescueModel && self.rescueModel.rescueState == RescueStateWait) {
        WaittingMBProgressHUD(self.view, @"");
        weakify(self);
        [kRJHTTPClient rescue:self.rescueModel.r_id receipt:YES completion:^(WebResponse *response) {
            if (response.code == WebResponseCodeSuccess) {
                if (weakSelf.rescueOrderStateChange) {
                    weakSelf.rescueOrderStateChange(YES, weakSelf.rescueModel);
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
        }];
    }
    
}
- (IBAction)refuseOrder:(id)sender {
    if (self.rescueModel && self.rescueModel.rescueState == RescueStateWait) {
        WaittingMBProgressHUD(self.view, @"");
        weakify(self);
        [kRJHTTPClient rescue:self.rescueModel.r_id receipt:NO completion:^(WebResponse *response) {
            if (response.code == WebResponseCodeSuccess) {
                if (weakSelf.rescueOrderStateChange) {
                    weakSelf.rescueOrderStateChange(YES, weakSelf.rescueModel);
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
        
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
        }];
    }
}
- (IBAction)makePhone:(id)sender {
    makePhoneCall(self.rescueModel.r_phone);
}
- (IBAction)location:(id)sender {
    MapLocationViewController *location = [MapLocationViewController new];
    location.lat = self.rescueModel.latitude;
    location.lon = self.rescueModel.longitude;
    location.address = self.rescueModel.r_position;
    location.oName = self.rescueModel.o_nickname;
    [self.navigationController pushViewController:location animated:YES];
}

@end
