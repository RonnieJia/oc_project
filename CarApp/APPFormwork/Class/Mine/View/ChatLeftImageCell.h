//
//  ChatLeftImageCell.h
//  APPFormwork
//
//  Created by jia on 2019/12/6.
//  Copyright © 2019 RJ. All rights reserved.
//

#import "RJBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatLeftImageCell : RJBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UIImageView *contentImgView;

@property (nonatomic, strong) UIImage *image;
@end

NS_ASSUME_NONNULL_END
