//
//  RJFileHelper.m
//  MvvmApp
//
//  Created by jia on 2017/5/17.
//  Copyright © 2017年 RJ. All rights reserved.
//

#import "RJFileHelper.h"
#import "CurrentUserInfo.h"

#define RJ_FILE_CACHE_IDENTIFIER @"rj_fileStreamApp"

@implementation RJFileHelper
//主路径
+ (NSString *)homePath
{
    return NSHomeDirectory();
}

//沙盒路径
+ (NSString *)documentPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)videoPath {
    return [[self documentPath] stringByAppendingPathComponent:@"rj_videodownload"];
}

//用户根路径
+ (NSString *)userRootPath
{
    NSString *docPath = [RJFileHelper documentPath];
    NSString *userId = [CurrentUserInfo sharedInstance].userId;// [NTESLoginManager sharedManager].currentNTESLoginData.username;
    NSString *rootPath = [NSString stringWithFormat:@"%@/%@/%@", docPath, RJ_FILE_CACHE_IDENTIFIER, userId];
    
    NSError *error = [RJFileHelper createDirectoryWithPath:rootPath];
    return (error ? nil : rootPath);
}

//创建目录
+ (NSError *)createDirectoryWithPath:(NSString *)path
{
    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] || isDirectory == NO)
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            RJLog(@"[NTESFileHelper] 视频根路径创建失败，%zi", error.code);
        }
        return error;
    }
    return nil;
}

//删除文件
+ (void)deleteFiles:(NSArray *)filePaths
{
    for (NSString *path in filePaths)
    {
        NSError *error = nil;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        }
        
        if (error)
        {
            NSLog(@"[NTESFileHelper] 文件[%@]删除失败，%zi", path, error.code);
        }
    }
}

//删除缓存
+ (void)clearCache
{
    NSString *docPath = [RJFileHelper documentPath];
    NSString *path = [NSString stringWithFormat:@"%@/%@", docPath, RJ_FILE_CACHE_IDENTIFIER];
    [RJFileHelper deleteFiles:@[path]];
}

//文件大小
+ (long long) fileSizeAtPath:(NSString *)filePath
{
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] && !isDir) {
        return [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

@end
