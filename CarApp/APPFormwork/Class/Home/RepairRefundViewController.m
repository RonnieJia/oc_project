//
//  RepairRefundViewController.m
//  APPFormwork
#import "RepairRefundViewController.h"
#import "RepairModel.h"

@interface RepairRefundViewController ()<UITextViewDelegate>

@end

@implementation RepairRefundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"不认可原因";
    self.textView.returnKeyType = UIReturnKeyDone;
    self.contentView.layer.borderColor=KSepLineColor.CGColor;
    self.contentView.layer.borderWidth=1;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
- (void)textViewDidChange:(UITextView *)textView {
    self.placeLabel.hidden = textView.text.length>0;
}

#pragma mark - 键盘弹出及收起
- (void)keyboardWasShown:(NSNotification *)noti {
    CGFloat hei = FetchKeyBoardHeight(noti);
    self.bottomConstraint.constant = hei;
}

- (void)keyboardWillBeHidden:(NSNotification *)noti {
    self.bottomConstraint.constant = 0;
}
- (IBAction)commitReason:(id)sender {
    if (self.textView.text.length==0) {
        return;
    }
    [self.view endEditing:YES];
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient repairRefund:self.repairModel.re_id reason:self.textView.text completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRepairRefund object:weakSelf.repairModel];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }
        FailedMBProgressHUD(weakSelf.view, response.message);
    }];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
@end
