
#import "ChatViewController.h"
#import "ChatCellManager.h"
#import "UIImage+Size.h"

@interface ChatViewController ()<UITableViewDelegate,UITableViewDataSource,JMessageDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UIView *mediaView;
@property (weak, nonatomic) IBOutlet UITextField *textFiele;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputBottomConstraint;

@end

@implementation ChatViewController
- (void)dealloc {
    [JMessage removeDelegate:self withConversation:self.conversation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self clearUnreadCount];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kViewControllerBgColor;
    self.title = self.conversation.title;
    [JMessage addDelegate:self withConversation:self.conversation];
    self.chatTableView.estimatedRowHeight = 59;
    [self getMessageByOffset];
}

/// 清除误读消息数
- (void)clearUnreadCount {
    [self.conversation clearUnreadCount];
}

- (void)getMessageByOffset {
    /// 获取最新的20条消息
    NSArray *messageList = [self.conversation messageArrayFromNewestWithOffset:nil limit:@(20)];
    if (messageList) {
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:[[messageList reverseObjectEnumerator] allObjects]];
        [self reloadTableView];
    }
}

#pragma mark - tableView DataSource
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [self.textFiele resignFirstResponder];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[ChatCellManager sharedInstance] tableView:tableView chatCellWithMessage:self.dataArray[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.textFiele resignFirstResponder];
}

- (IBAction)sendTextMessage:(id)sender {
    if (self.textFiele.text.length==0) {
        return;
    }
    JMSGUser *user = self.conversation.target;
    if (self.conversation.targetAppKey) {
        [JMSGMessage sendSingleTextMessage:self.textFiele.text toUser:user.username appKey:self.conversation.targetAppKey];
    } else {
        [JMSGMessage sendSingleTextMessage:self.textFiele.text toUser:user.username];
    }
    [self.textFiele resignFirstResponder];
    self.textFiele.text = nil;
}

- (IBAction)mediaButtonAction:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    if (sender.tag == 0) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else if (sender.tag == 1) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;//设置摄像头捕获类型
    }
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = [image compressWithMaxLength:1024*1024*4];
    
    JMSGUser *user = self.conversation.target;
    if (self.conversation.targetAppKey) {
        [JMSGMessage sendSingleImageMessage:imageData toUser:user.username appKey:self.conversation.targetAppKey];
    } else {
        [JMSGMessage sendSingleImageMessage:imageData toUser:user.username];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];

}

/// 发送消息结果回调
- (void)onSendMessageResponse:(JMSGMessage *)message error:(NSError *)error {
    if (!error && message) {
        [self.dataArray addObject:message];
        [self reloadTableView];
    }
}

/// 收到消息回调
- (void)onReceiveMessage:(JMSGMessage *)message error:(NSError *)error {
    if (!error && message) {
        [self.dataArray addObject:message];
        [self reloadTableView];
    }
}

#pragma mark - 键盘弹出及收起
- (void)keyboardWasShown:(NSNotification *)noti {
    CGFloat hei = FetchKeyBoardHeight(noti);
    self.inputBottomConstraint.constant = hei-kIPhoneXBH;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollViewScrollToBottom];
    });
}

- (void)keyboardWillBeHidden:(NSNotification *)noti {
    self.inputBottomConstraint.constant = 40;
}

- (void)reloadTableView {
    [self.chatTableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(400 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self scrollViewScrollToBottom];
    });
}

- (void)scrollViewScrollToBottom {
    if (self.dataArray.count>0) {
        NSInteger index = [self.chatTableView numberOfRowsInSection:0];
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

@end
