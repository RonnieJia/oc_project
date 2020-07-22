
#import "RJNullView.h"
#import "Masonry.h"

@interface RJNullView()
@property(nonatomic, weak)UIImageView *imgView;

@end

@implementation RJNullView
+ (void)tableView:(UITableView *)tableView footerSize:(CGSize)size {
    if (tableView) {
        RJNullView *null = [[RJNullView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        tableView.tableFooterView = null;
    }
}
+ (void)showInView:(UIView *)view frame:(CGRect)frame {
    if (view) {
        RJNullView *null = [[RJNullView alloc] initWithFrame:frame];
        null.tag = 987123;
        [view addSubview:null];
        [view bringSubviewToFront:null];
    }
}
+ (void)hideInView:(UIView *)view {
    if (view) {
        UIView *view1 = [view viewWithTag:987123];
        if ([view1 isKindOfClass:[RJNullView class]]) {
            [view1 removeFromSuperview];
        }
    }
}
/**
 在某个视图上显示，且覆盖
 */
+ (void)showInView:(UIView *)view {
    [self showInView:view frame:view.bounds];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.width<217 || self.height<190) {
        self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        self.imgView.contentMode = UIViewContentModeCenter;
    }
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 217, 190)];
        if (self.width<217 || self.height<190) {
            imgView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            imgView.contentMode = UIViewContentModeCenter;
        }
        imgView.image = [UIImage imageNamed:@"jyh_null"];
        [self addSubview:imgView];
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        self.imgView = imgView;
    }
    return self;
}

@end
