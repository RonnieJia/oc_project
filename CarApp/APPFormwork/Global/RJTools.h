
#import <Foundation/Foundation.h>

@interface RJTools : NSObject
+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2;
/**
 *  设置图片透明度
 * @param alpha 透明度
 * @param image 图片
 */
+(UIImage *)imageByApplyingAlpha:(CGFloat )alpha  image:(UIImage*)image;

/**
 判断相机和麦克风的权限
 */
+ (BOOL)requestMediaCaptureAccessWithCompletionHandler:(void (^)(BOOL, NSError *))handler;

+ (void)videoDataWithPath:(NSURL *)videoUrl completion:(void (^)(NSURL *filePath, NSError *error))handler;

+ (void)getVideoImage:(NSURL *)path complete:(void(^)(UIImage *img))handler;
@end
