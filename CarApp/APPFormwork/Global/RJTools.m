//
//  RJTools.m
//  APPFormwork


#import "RJTools.h"
#import <AVFoundation/AVFoundation.h>
#import "RJFileHelper.h"

@implementation RJTools


+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 {
    UIGraphicsBeginImageContext(image2.size);
    
    // Draw image1
    [image1 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    
    // Draw image2
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

/**
 *  设置图片透明度
 * @param alpha 透明度
 * @param image 图片
 */
+(UIImage *)imageByApplyingAlpha:(CGFloat )alpha  image:(UIImage*)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    
    CGContextSetAlpha(ctx, alpha);
    
    
    
    CGContextDrawImage(ctx, area, image.CGImage);
    
    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    
    
    UIGraphicsEndImageContext();
    
    
    
    return newImage;
    
}


+ (BOOL)requestMediaCaptureAccessWithCompletionHandler:(void (^)(BOOL, NSError *))handler {
    AVAuthorizationStatus videoAuthorStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus audioAuthorStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    if (AVAuthorizationStatusAuthorized == videoAuthorStatus && AVAuthorizationStatusAuthorized == audioAuthorStatus) {
        handler(YES,nil);
    }else{
        if (AVAuthorizationStatusRestricted == videoAuthorStatus || AVAuthorizationStatusDenied == videoAuthorStatus) {
            NSString *errMsg = NSLocalizedString(@"此应用需要访问摄像头，请设置", @"此应用需要访问摄像头，请设置");
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errMsg};
            NSError *error = [NSError errorWithDomain:@"访问权限" code:0 userInfo:userInfo];
            handler(NO,error);
            
            return NO;
        }
        
        if (AVAuthorizationStatusRestricted == audioAuthorStatus || AVAuthorizationStatusDenied == audioAuthorStatus) {
            NSString *errMsg = NSLocalizedString(@"此应用需要访问麦克风，请设置", @"此应用需要访问麦克风，请设置");
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errMsg};
            NSError *error = [NSError errorWithDomain:@"访问权限" code:0 userInfo:userInfo];
            handler(NO,error);
            
            return NO;
        }
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                    if (granted) {
                        handler(YES,nil);
                    }else{
                        NSString *errMsg = NSLocalizedString(@"不允许访问麦克风", @"不允许访问麦克风");
                        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errMsg};
                        NSError *error = [NSError errorWithDomain:@"访问权限" code:0 userInfo:userInfo];
                        handler(NO,error);
                    }
                }];
            }else{
                NSString *errMsg = NSLocalizedString(@"不允许访问摄像头", @"不允许访问摄像头");
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errMsg};
                NSError *error = [NSError errorWithDomain:@"访问权限" code:0 userInfo:userInfo];
                handler(NO,error);
            }
        }];
        
    }
    return YES;
}

+ (void)videoDataWithPath:(NSURL *)videoUrl completion:(void (^)(NSURL *, NSError *error))handler {
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoUrl  options:nil];
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyyMMddHHmmss"];
    NSString *_fileName = [NSString stringWithFormat:@"output-%@.mp4",[formater stringFromDate:[NSDate date]]];
    NSString *_outfilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", _fileName];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        RJLog(@"outPath = %@",_outfilePath);
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        exportSession.outputURL = [NSURL fileURLWithPath:_outfilePath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                RJLog(@"AVAssetExportSessionStatusCompleted---转换成功");
                NSString *_filePath = _outfilePath;
                NSURL *_filePathURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",_outfilePath]];
                if (handler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler(_filePathURL, nil);
                    });
                }
                RJLog(@"转换完成_filePath = %@\\n_filePathURL = %@",_filePath,_filePathURL);
                //获取大小和长度
                //                [self SetViewText];
                //                [self uploadNetWorkWithParam:@{@"contenttype":@"application/octet-stream",@"discription":description}];
            }else{
                if (handler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler(nil, [exportSession error]);
                    });
                }
                RJLog(@"转换失败,值为:%li,可能的原因:%@",(long)[exportSession status],[[exportSession error] localizedDescription]);
            }
        }];
    }
    
}


+(void)ClearMovieFromDoucments{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        RJLog(@"%@",filename);
        if ([filename isEqualToString:@"tmp.PNG"]) {
            RJLog(@"删除%@",filename);
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
            continue;
        }
        if ([[[filename pathExtension] lowercaseString] isEqualToString:@"mp4"]||
            [[[filename pathExtension] lowercaseString] isEqualToString:@"mov"]||
            [[[filename pathExtension] lowercaseString] isEqualToString:@"png"]) {
            RJLog(@"删除%@",filename);
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
    }
}


+ (void)getVideoImage:(NSURL *)path complete:(void(^)(UIImage *img))handler
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *docu = [RJFileHelper documentPath];
        NSString *filePath = [docu stringByAppendingPathComponent:@"video_Image"];
        NSString *key = EncryptPassword(path.absoluteString);
        NSString *imagePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",key]];
        UIImage *temp = [UIImage imageWithContentsOfFile:imagePath];
        if (temp && [temp isKindOfClass:[UIImage class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) {
                    handler(temp);
                }
            });
            return ;
        }
        
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
        AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        
        assetGen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
        [self saveImg:videoImage path:path];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) {
                handler(videoImage);
            }
        });
    });
    
}

+ (void)saveImg:(UIImage *)img path:(NSURL *)path {
    if (!img) {
        return;
    }
    NSString *docu = [RJFileHelper documentPath];
    NSString *filePath = [docu stringByAppendingPathComponent:@"video_Image"];
    NSError *error = [RJFileHelper createDirectoryWithPath:filePath];
    if (error) {
        return;
    }
    
    NSString *key = EncryptPassword(path.absoluteString);
    NSString *imagePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",key]];
    NSData *data = UIImageJPEGRepresentation(img, 0.5);
    BOOL suc = [data writeToFile:imagePath atomically:YES];
    RJLog(@"保存——%zd",suc);
}

@end
