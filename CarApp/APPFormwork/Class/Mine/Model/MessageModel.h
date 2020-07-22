//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageModel : BaseModel
@property (nonatomic, strong) NSString *m_id;
@property (nonatomic, strong) NSString *m_time;
@property (nonatomic, strong) NSString *m_title;
@property (nonatomic, strong) NSString *m_content;
@property (nonatomic, assign) BOOL is_look;

@end


@interface MessageManager : NSObject
@property (nonatomic, assign) BOOL load;
@property (nonatomic, assign) BOOL noMore;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, assign) NSInteger type;

@end

NS_ASSUME_NONNULL_END
