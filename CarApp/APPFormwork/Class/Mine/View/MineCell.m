
#import "MineCell.h"

@implementation MineCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *cellIndentifier = @"MineCell";
    MineCell *cell = (MineCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(nil == cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIndentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
- (void)setConversation:(JMSGConversation *)conversation {
    _conversation = conversation;
    self.nameLabel.text = conversation.title;
    JMSGMessage *lastMsg = conversation.latestMessage;
    self.countLabel.text = [NSString stringWithFormat:@"%@",conversation.unreadCount];
    self.countLabel.hidden = [conversation.unreadCount integerValue]==0;
    if (conversation.latestMsgTime) {
        self.dateLabel.text = getStringFromTimeintervalString([NSString stringWithFormat:@"%@",conversation.latestMsgTime], @"yyyy/MM/dd");
    }
    self.iconImgView.image = KDefaultImg;
    JMSGUser *user = conversation.target;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [user thumbAvatarData:^(NSData *data, NSString *objectId, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (data && !error) {
                    UIImage *image = [UIImage imageWithData:data];
                    self.iconImgView.image = image;
                }
            });
            
        }];
    });
    if (lastMsg) {
        if (lastMsg.contentType == kJMSGContentTypeImage) {
            self.msgLabel.text=@"[图片]";
        } else {
            if (lastMsg.contentType == kJMSGContentTypeText) {
                JMSGTextContent *textContent = (JMSGTextContent *)lastMsg.content;
                self.msgLabel.text = textContent.text;
            } else {
                self.msgLabel.text=@"消息";
            }
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
