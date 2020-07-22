//  群组数据库

#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"

@interface RJFMDBDatabase : NSObject
+ (instancetype)sharedInstanced;
+ (NSString *)dbPath;
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@end
