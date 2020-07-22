//

#import "MsgDetailViewController.h"
#import "MessageModel.h"

@interface MsgDetailViewController ()

@end

@implementation MsgDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"消息详情";
    [self fetchMessageDetail];
}
- (void)fetchMessageDetail {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient fetchMessageDetail:self.msgModel.m_id completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [weakSelf disPlay];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)disPlay {
    self.titleL.text = self.msgModel.m_title;
    self.contentL.text = self.msgModel.m_content;
    self.dateL.text = self.msgModel.m_time;
}
@end
