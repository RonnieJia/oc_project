//
//  RJFileHelper.h
//  MvvmApp
//
//  Created by jia on 2017/5/17.
//  Copyright © 2017年 RJ. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kNtesUpdateVideoCachePath = @"ntes_loc_updatevideo";  //上传视频相对路径
static NSString *kNtesUpdateVideoRecordPath = @"ntes_loc_updatevideo_record"; //上传视频记录相对路径
static NSString *kNtesLoginAccountPath = @"nim_sdk_login_data"; //登陆账号相对路径
static NSString *kNtesPresentBoxPath = @"ntes_present_box_data"; //礼物盒子相对路径

@interface RJFileHelper : NSObject
+ (NSString *)documentPath;

+ (NSString *)videoPath;

+ (NSString *)userRootPath;

+ (void)deleteFiles:(NSArray *)filePaths;

+ (NSError *)createDirectoryWithPath:(NSString *)path;
@end
