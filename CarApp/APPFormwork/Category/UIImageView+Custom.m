//
//  UIImageView+Custom.m
//  APPFormwork

#import "UIImageView+Custom.h"


@implementation UIImageView (Custom)
- (void)rj_setImageWithPath:(nullable NSString *)path {
    if ([path hasPrefix:@"http"]) {
        [self sd_setImageWithURL:[NSURL URLWithString:path]];
    } else {
        [self sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",KImgBaseUrl, path]]];
    }
}
 - (void)rj_setImageWithPath:(nullable NSString *)path
 placeholderImage:(nullable UIImage *)placeholder {
    if ([path hasPrefix:@"http"]) {
        [self sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:placeholder];
    } else {
        [self sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",KImgBaseUrl, path]] placeholderImage:placeholder];
    }
}
@end
