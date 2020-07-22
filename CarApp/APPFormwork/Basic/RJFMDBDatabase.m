#import "RJFMDBDatabase.h"

@implementation RJFMDBDatabase
@synthesize dbQueue = _dbQueue;

static RJFMDBDatabase *sharedDB = nil;
+ (instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDB = [[self alloc] init];
    });
    return sharedDB;
}

// 创建数据的保存路径
+ (NSString *)dbPath {
    NSString *docuPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    docuPath = [docuPath stringByAppendingPathComponent:@"videoDownloadDB"];
    BOOL isDir;
    BOOL exit = [fileManage fileExistsAtPath:docuPath isDirectory:&isDir];
    if (!exit || !isDir) {
        [fileManage createDirectoryAtPath:docuPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *dbPath = [docuPath stringByAppendingPathComponent:@"video.sqlite"];
    return dbPath;
}

- (FMDatabaseQueue *)dbQueue {
    if (_dbQueue == nil) {
        _dbQueue = [[FMDatabaseQueue alloc] initWithPath:[self.class dbPath]];
    }
    return _dbQueue;
}

@end
