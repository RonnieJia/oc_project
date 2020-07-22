//
//  ChatImageRightCell.m
//  APPFormwork
//
//  Created by jia on 2019/12/6.
//  Copyright © 2019 RJ. All rights reserved.
//

#import "ChatImageRightCell.h"
#import "SDPhotoBrowser.h"

@interface ChatImageRightCell ()<SDPhotoBrowserDelegate>
@property (weak, nonatomic) IBOutlet UIView *imgContainerView;

@end

@implementation ChatImageRightCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *cellIndentifier = @"ChatImageRightCell";
    ChatImageRightCell *cell = (ChatImageRightCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(nil == cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIndentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentImgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(showImage:)]];
    }
    return cell;
}

- (void)showImage:(UITapGestureRecognizer *)tap {
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.sourceImagesContainerView = self.imgContainerView;
    browser.imageCount = 1;
    browser.currentImageIndex = 0;
    browser.delegate = self;
    [browser show];
}

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    return self.image;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
