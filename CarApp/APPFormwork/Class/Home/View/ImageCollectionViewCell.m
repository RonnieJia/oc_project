//
//  ImageCollectionViewCell.m
//  APPFormwork
#import "ImageCollectionViewCell.h"

@implementation ImageCollectionViewCell
- (IBAction)deleteImage:(id)sender {
    if (self.imageDeleteBlock) {
        self.imageDeleteBlock();
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
