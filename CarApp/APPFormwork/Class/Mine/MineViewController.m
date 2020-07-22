
#import "MineViewController.h"
#import "MineCell.h"
#import "MessageViewController.h"
#import "ChatViewController.h"
#import "MessageModel.h"

@interface MineViewController ()<UITableViewDelegate,UITableViewDataSource,JMessageDelegate>
@property(nonatomic, assign)BOOL getConversation;
@property(nonatomic, assign)NSInteger systemMsgCount;
@property(nonatomic, strong)MessageModel *systemMsg;
@end

@implementation MineViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        [JMessage addDelegate:self withConversation:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"msgShowBadge" object:@(NO)];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getAllConversationList];
    [self fetchSystemMsg];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"消息记录";
    [self createMainView];
}

- (void)fetchSystemMsg {
    weakify(self);
    [kRJHTTPClient fetchSystemMsgInfoCompletion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            NSDictionary *result = ObjForKeyInUnserializedJSONDic(response.responseObject, @"result");
            weakSelf.systemMsg=[MessageModel modelWithJSONDict:ObjForKeyInUnserializedJSONDic(result, @"info")];
            weakSelf.systemMsgCount = IntForKeyInUnserializedJSONDic(result, @"count");
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        }
    }];
}

- (void)createMainView {
    self.tableView.rowHeight = 65;
    self.tableView.backgroundColor = KSepLineColor;
    self.tableView.height = KViewTabNavHeight;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    [self.view addSubview:self.tableView];
    
}

- (void)getAllConversationList {
    if (self.getConversation) {
        return;
    }
    self.getConversation = YES;
    [JMSGConversation allConversations:^(id resultObject, NSError *error) {
       if (!error) {
           NSArray *conversationList = (NSArray *)resultObject;
           [self.dataArray removeAllObjects];
           self.dataArray = [NSMutableArray arrayWithArray:conversationList];
           [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
       }
        self.getConversation = NO;
    }];
}

/// 会话发生变化
- (void)onConversationChanged:(JMSGConversation *)conversation {
    [self getAllConversationList];
}

- (void)onReceiveMessage:(JMSGMessage *)message error:(NSError *)error {
    
    [self getAllConversationList];
}

#pragma mark - tableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MineCell *cell = [MineCell cellWithTableView:tableView];
    if (indexPath.section == 1) {
        JMSGConversation *conversation = self.dataArray[indexPath.row];
        cell.conversation = conversation;
    } else {
        cell.nameLabel.text = @"系统消息";
        cell.iconImgView.image = [UIImage imageNamed:@"note001"];
        if (self.systemMsg) {
            cell.msgLabel.text = self.systemMsg.m_title;
            cell.dateLabel.text = self.systemMsg.m_time;
        }
        cell.countLabel.text = [NSString stringWithFormat:@"%zd",self.systemMsgCount];
        cell.countLabel.hidden = (self.systemMsgCount==0);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MessageViewController *msgVC = [[MessageViewController alloc] init];
        [self.navigationController pushViewController:msgVC animated:YES];
    } else {
        if (indexPath.row < self.dataArray.count) {
            JMSGConversation *conversation = self.dataArray[indexPath.row];
            ChatViewController *chat = [[ChatViewController alloc] init];
            chat.conversation = conversation;
            /// 清除未读消息数
            [conversation clearUnreadCount];
            MineCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.countLabel.hidden = YES;
            [self.navigationController pushViewController:chat animated:YES];
        }
        
    }
    
}

@end
