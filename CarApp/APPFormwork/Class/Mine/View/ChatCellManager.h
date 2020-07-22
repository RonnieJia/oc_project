//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatCellManager : NSObject
+ (instancetype)sharedInstance;
- (CGFloat)chatCellHeightWithMessage:(JMSGMessage *)message;
- (UITableViewCell *)tableView:(UITableView *)tableView chatCellWithMessage:(JMSGMessage *)msg;
@end

NS_ASSUME_NONNULL_END
