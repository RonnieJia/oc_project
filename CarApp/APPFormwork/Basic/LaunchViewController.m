

#import "LaunchViewController.h"

@interface LaunchViewController ()
@property(nonatomic, weak)UIImageView *imgView;
@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:imgView];
    self.imgView = imgView;
    
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:@"launch_img"];
    weakify(self);
    if (!IsStringEmptyOrNull(string)) {
        [self fetchImageWithCompletion:nil];// 缓存最新的
        [weakSelf showImg];
    } else {
        [self fetchImageWithCompletion:^(BOOL success) {
            if (success) {
                [weakSelf showImg];
            } else {
                weakSelf.changeBlock();
            }
        }];
    }
}

- (void)showImg {
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:@"launch_img"];
    NSInteger timeLen = [[NSUserDefaults standardUserDefaults] integerForKey:@"start_time"]>0?:3;
    if (![string hasPrefix:KImgBaseUrl]) {
        string = [NSString stringWithFormat:@"%@%@",KImgBaseUrl,string];
    }
    weakify(self);
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:string] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        strongify(weakSelf);
        if (error) {
            if (strongSelf.changeBlock) {
                strongSelf.changeBlock();
            }
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeLen * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (strongSelf.changeBlock) {
                    strongSelf.changeBlock();
                }
            });
        }
    }];
}

- (void)fetchImageWithCompletion:(void(^)(BOOL success))completion {
    /*
    [kRJHTTPClient fetchBanner:BannerTypeStart completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            NSDictionary *data = [ObjForKeyInUnserializedJSONDic(response.responseObject, @"data") firstObject];
            NSString *pic = StringForKeyInUnserializedJSONDic(data, @"img");
            NSInteger time = 3;
            if (!IsStringEmptyOrNull(pic)) {
                [[NSUserDefaults standardUserDefaults] setObject:pic forKey:@"launch_img"];
                [[NSUserDefaults standardUserDefaults] setInteger:time forKey:@"launch_time"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (completion) {
                    completion(YES);
                }
            } else {
                if (completion)
                    completion(NO);
            }
        } else {
            if (completion)
                completion(NO);
        }
    }];*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
