
#import "ChatCellManager.h"
#import "ChatLeftCell.h"
#import "ChatRightCell.h"
#import "ChatLeftImageCell.h"
#import "ChatImageRightCell.h"

@interface ChatCellManager ()<NSCacheDelegate>
@property(nonatomic, strong)NSCache *cellHeightCache;
@property(nonatomic, strong)NSMutableDictionary *iconIMGCache;
@end

@implementation ChatCellManager
static ChatCellManager *_manager = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[ChatCellManager alloc] init];
    });
    return _manager;
}
- (CGFloat)chatCellHeightWithMessage:(JMSGMessage *)message{
    
    return 0;
}

- (void)iconImgViewShowImage:(UIImageView *)iconImgView user:(JMSGUser *)user {
    NSData *imgData = [self.iconIMGCache objectForKey:@(user.uid)];
    if (imgData) {
        UIImage *image = [UIImage imageWithData:imgData];
        iconImgView.image = image;
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [user thumbAvatarData:^(NSData *data, NSString *objectId, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (data && !error) {
                        [self.iconIMGCache setObject:data forKey:@(user.uid)];
                        UIImage *image = [UIImage imageWithData:data];
                        iconImgView.image = image;
                    } else {
                        [iconImgView rj_setImageWithPath:[CurrentUserInfo sharedInstance].userIcon placeholderImage:KDefaultImg];
                    }
                });
                
            }];
        });
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView chatCellWithMessage:(JMSGMessage *)msg {
    JMSGUser *user = msg.fromUser;
    if (msg.isReceived) {// 接收到的消息
        if (msg.contentType == kJMSGContentTypeImage) {
            ChatLeftImageCell *cell = [ChatLeftImageCell cellWithTableView:tableView];
            JMSGImageContent *content = (JMSGImageContent *)msg.content;
            [content thumbImageData:^(NSData *data, NSString *objectId, NSError *error) {
                if (data && !error) {
                    UIImage *image = [UIImage imageWithData:data];
                    cell.contentImgView.image = image;
                    cell.image = image;
                }
            }];
            [self iconImgViewShowImage:cell.iconImgView user:user];
            return cell;
        } else {
            ChatLeftCell *cell = [ChatLeftCell cellWithTableView:tableView];
            [self iconImgViewShowImage:cell.iconImgView user:user];
            if (msg.contentType == kJMSGContentTypeText) {// 文本
                JMSGTextContent *textContent = (JMSGTextContent *)msg.content;
                cell.contentLabel.text = textContent.text;
            } else {
                cell.contentLabel.text = @"暂不支持该消息类型";
            }
            return cell;
        }
    } else {// 自己发送的消息
        if (msg.contentType == kJMSGContentTypeImage) {
            ChatImageRightCell *cell = [ChatImageRightCell cellWithTableView:tableView];
            JMSGImageContent *content = (JMSGImageContent *)msg.content;
            [content thumbImageData:^(NSData *data, NSString *objectId, NSError *error) {
                if (data && !error) {
                    UIImage *image = [UIImage imageWithData:data];
                    cell.contentImgView.image = image;
                    cell.image = image;
                }
            }];
            [self iconImgViewShowImage:cell.iconImgView user:user];
            return cell;
        } else {
            ChatRightCell *cell = [ChatRightCell cellWithTableView:tableView];
            [self iconImgViewShowImage:cell.iconImgView user:user];
            if (msg.contentType == kJMSGContentTypeText) {// 文本
                JMSGTextContent *textContent = (JMSGTextContent *)msg.content;
                cell.contentLabel.text = textContent.text;
            } else {
                cell.contentLabel.text = @"暂不支持该消息类型";
            }
            return cell;
        }
    }
}


- (NSMutableDictionary *)iconIMGCache {
    if (!_iconIMGCache) {
        _iconIMGCache = [NSMutableDictionary dictionary];
    }
    return _iconIMGCache;
}
- (NSCache *)cellHeightCache {
    if (!_cellHeightCache) {
        _cellHeightCache = [[NSCache alloc] init];
        _cellHeightCache.delegate = self;
    }
    return _cellHeightCache;
}
@end
