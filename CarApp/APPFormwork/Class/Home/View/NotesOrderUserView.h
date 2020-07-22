
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotesOrderUserView : UIView
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *infoLabel;

@property (nonatomic, assign) BOOL hiddenDetail;
@property (nonatomic, copy)void(^pushCarInfoBlock)();

@end

NS_ASSUME_NONNULL_END
