//
//  ImageCollectionViewCell.h
//  APPFormwork

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property(nonatomic, copy)void(^imageDeleteBlock)();
@end

NS_ASSUME_NONNULL_END
