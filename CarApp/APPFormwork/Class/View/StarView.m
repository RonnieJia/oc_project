

#import "StarView.h"

static CGFloat const kStarSize = 16;

@implementation StarView
- (void)awakeFromNib {
    if (self.isEdited) {// 可编辑的状态
        [self createButtonView];
    } else {// 纯粹显示状态
        [self createShowView];
    }
    
    [super awakeFromNib];
}

- (void)setStarValue:(CGFloat)starValue {
    _starValue = starValue;
    if (self.isEdited) {
        for (int i = 0; i<5; i++) {
            UIButton *btn = [self viewWithTag:100+i];
            if (i<starValue) {
                btn.selected = YES;
            } else {
                btn.selected=NO;
            }
        }
    } else {
        
    }
    
}

- (void)createButtonView {
    self.size = CGSizeMake((kStarSize+10)*4+kStarSize, kStarSize);
    CGFloat wid = kStarSize;
    for (int i = 0; i<5; i++) {
        UIButton *btn = RJCreateImageButton(CGRectMake(i*(wid+10), 0, wid, wid), [UIImage imageNamed:@"JYH_star001"], [UIImage imageNamed:@"JYH_star002"]);
        btn.adjustsImageWhenHighlighted=NO;
        btn.tag = 100+i;
        [self addSubview:btn];
    }
}

- (void)createShowView {
    self.size = CGSizeMake((kStarSize+10)*4+kStarSize, kStarSize);
    UIView *backView = RJCreateSimpleView(self.bounds, [UIColor clearColor]);
    UIView *frontView = RJCreateSimpleView(self.bounds, [UIColor clearColor]);
    [self addSubview:backView];
    [self addSubview:frontView];
    frontView.clipsToBounds=YES;
    CGFloat wid = kStarSize;
    for (int i = 0; i<5; i++) {
        UIImageView *imgView = RJCreateSimpleImageView(CGRectMake(i*(wid+10), 0, wid, wid), [UIImage imageNamed:@"JYH_star001"]);
        imgView.contentMode = UIViewContentModeLeft;
        [backView addSubview:imgView];
        
        UIImageView *imgView2 = RJCreateSimpleImageView(CGRectMake(imgView.left, 0, wid, wid), [UIImage imageNamed:@"JYH_star002"]);
        imgView2.contentMode = UIViewContentModeLeft;
        [frontView addSubview:imgView2];
    }
}

- (void)setEdited:(BOOL)edited {
    _edited = edited;
    for (int i = 0; i<5; i++) {
        UIButton *btn = [self viewWithTag:100+i];
        btn.enabled = edited;
    }
}

@end
