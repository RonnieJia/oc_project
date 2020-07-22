

#import "TBKSuccessView.h"

@interface TBKSuccessView()
@property(nonatomic, weak)UILabel *titleLabel;
@property(nonatomic, weak)UILabel *contentLabel;
@end

@implementation TBKSuccessView
+ (instancetype)sharedInstance {
    static TBKSuccessView *view=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        view = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [KTextBlackColor colorWithAlphaComponent:0.4];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 215, 140)];
        contentView.backgroundColor = KTextWhiteColor;
        [self addSubview:contentView];
        contentView.layer.cornerRadius = 8;
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 23, 35, 35)];
        [contentView addSubview:imgView];
        imgView.centerX = contentView.width/2;
        imgView.image = [UIImage imageNamed:@"tbk_success"];
        
        UILabel *l1 = [UILabel labelWithFrame:CGRectMake(5, imgView.bottom+15, contentView.width-10, 16) textColor:KTextDarkColor font:kFontWithSmallSize textAlignment:NSTextAlignmentCenter text:@"日常任务"];
        [contentView addSubview:l1];
        self.titleLabel = l1;
        
        UILabel *l2 = [UILabel labelWithFrame:CGRectMake(5, l1.bottom+10, l1.width, 16) textColor:KTextGrayColor font:kFontWithSmallSize textAlignment:NSTextAlignmentCenter text:nil];
        self.contentLabel = l2;
        [contentView addSubview:l2];
        [contentView addGestureRecognizer:[UITapGestureRecognizer new]];
        contentView.height = l2.bottom+24;
        
        
        contentView.center=CGPointMake(KScreenWidth/2, KScreenHeight/2);
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSelf)]];
        
    }
    return self;
}

- (void)showWithTitle:(NSString *)title content:(NSString *)content {
    self.titleLabel.text = title;
    self.contentLabel.text = content;
    [KKeyWindow addSubview:self];
}

- (void)showWithType:(TBKSuccessType)type {
    switch (type) {
        case TBKSuccessTypeCopy:
        {
            self.titleLabel.text = @"复制成功";
            self.contentLabel.text = @"快邀请好友加入吧！";
        }
            break;
        case TBKSuccessTypeShare:
        {
            self.titleLabel.text = @"分享成功";
            self.contentLabel.text = @"发现更多宝贝来分享吧";
        }
            break;
        case TBKSuccessTypeCopyTKL:
        {
            self.titleLabel.text = @"复制成功";
            self.contentLabel.text = @"打开淘宝即可查看";
        }
            break;
        case TBKSuccessTypeBand:
        {
            self.titleLabel.text = @"绑定成功";
            self.contentLabel.text = @"恭喜您绑定成功啦！";
        }
            break;
        case TBKSuccessTypeComment:
        {
            self.titleLabel.text = @"评论成功";
            self.contentLabel.text = @"发表一下你的观点吧！";
        }
            break;
        case TBKSuccessTypeSaveImg:
        {
            self.titleLabel.text = @"保存成功";
            self.contentLabel.text = @"已保存至您的手机相册!";
        }
            break;
            
        default:
            break;
    }
    [KKeyWindow addSubview:self];
}
- (void)hideSelf{
    [self removeFromSuperview];
}

@end
