
#import "RJADLaunchView.h"
#import "AppDelegate.h"
#import "RJFileHelper.h"

@interface RJADLaunchView ()
@property(nonatomic, assign)NSInteger time;
@property(nonatomic, strong)NSTimer *timer;
@property(nonatomic, weak)UIImageView *adImgView;
@property(nonatomic, weak)UILabel *timeLabel;
@property(nonatomic, assign)BOOL closed;
@end
@implementation RJADLaunchView
+ (instancetype)sharedInstance {
    static RJADLaunchView *view = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        view = [[RJADLaunchView alloc] init];
    });
    return view;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.frame=[UIScreen mainScreen].bounds;
        self.tag = 9999;
        
        UIImageView *imgView = RJCreateSimpleImageView(self.bounds, nil);
        [self addSubview:imgView];
        imgView.contentMode = UIViewContentModeScaleToFill;
        imgView.userInteractionEnabled=YES;
        self.adImgView = imgView;
        [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushToADDetail)]];
        
        UIView *timeView = RJCreateSimpleView(CGRectMake(KScreenWidth-15-50, StatusBarHeight+10, 50, 24), [KTextBlackColor colorWithAlphaComponent:0.6]);
        timeView.layer.cornerRadius = 12;
        timeView.clipsToBounds = YES;
//        [self addSubview:timeView];
        UILabel *timeL = RJCreateLable(timeView.bounds, kFontWithSmallSize, KTextWhiteColor, NSTextAlignmentCenter, @"5s");
//        [timeView addSubview:timeL];
        self.timeLabel = timeL;
    }
    return self;
}

- (void)pushToADDetail {
    return;
    [[NSNotificationCenter defaultCenter] postNotificationName:kPushToADDetail object:nil];
    [self closeAD];
}

- (void)timeStartAction {
    self.time = 5;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeChanged) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [timer fire];
    self.timer = timer;
}

- (void)timeChanged {
    if (self.time == 0) {
        [self closeAD];
    }
    self.timeLabel.text = [NSString stringWithFormat:@"%zds",self.time];
    self.time--;
}

- (void)closeAD {
    if (self.closed) {
        return;
    }
    self.closed = YES;
    if (self.timer) {
        if ([self.timer isValid]) {
            [self.timer invalidate];
        }
        self.timer = nil;
    }
    [UIView animateWithDuration:0.35 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

+ (void)showAD {
    NSString *path = [[RJFileHelper documentPath] stringByAppendingPathComponent:@"start.png"];
    UIImage *data = [UIImage imageWithContentsOfFile:path];
    
    if (data && [data isKindOfClass:[UIImage class]]) {
        RJADLaunchView *adView = [RJADLaunchView sharedInstance];
        adView.closed = NO;
        adView.adImgView.image = data;
        [adView performSelector:@selector(closeAD) withObject:nil afterDelay:4];
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        UIViewController *vc = appdelegate.window.rootViewController;
        [vc.view addSubview:adView];
    }
    [kRJHTTPClient fetchStartPageCompletion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            NSString *path2 = StringForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"info"), @"c_repair_start");
            if (!IsStringEmptyOrNull(path2)) {
                [[NSUserDefaults standardUserDefaults] setObject:path2 forKey:@"start_img"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:[KImgBaseUrl stringByAppendingPathComponent:path2]] options:SDWebImageDownloaderLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    if (finished && data && !error) {
                        [data writeToFile:path atomically:YES];
                    }
                }];
            }
        }
    }];
}
@end
