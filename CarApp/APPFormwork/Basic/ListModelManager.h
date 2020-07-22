//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ListModelManager : NSObject
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL load;
@property (nonatomic, assign) BOOL noMoreData;

@property (nonatomic, strong) NSMutableArray *listArray;

@end

NS_ASSUME_NONNULL_END
