//
//  UIImage+Size.h
//  APPFormwork
//
//  Created by jia on 2018/3/6.
//  Copyright © 2018年 RJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Size)
-(NSData *)compressWithMaxLength:(NSUInteger)maxLength;
@end
