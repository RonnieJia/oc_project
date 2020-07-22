//
//  UIImageView+Custom.h
//  APPFormwork
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (Custom)
- (void)rj_setImageWithPath:(nullable NSString *)path;
- (void)rj_setImageWithPath:(nullable NSString *)path
           placeholderImage:(nullable UIImage *)placeholder;
@end

NS_ASSUME_NONNULL_END
