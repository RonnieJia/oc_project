#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotesChangeView : UIView
- (instancetype)initWithItems:(NSArray *)items;
- (void)count:(NSInteger)count changeAtIndex:(NSInteger)index;
@property (nonatomic, strong) NSArray *indexCount;
@property (nonatomic, copy) void(^notesCallBack)(NSInteger selectIndex);
@property (nonatomic, assign) NSInteger selectIndex;

@end

NS_ASSUME_NONNULL_END
