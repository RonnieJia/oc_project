//

#import "CarInfoViewController.h"
#import "SDPhotoBrowser.h"

@interface CarInfoViewController ()<SDPhotoBrowserDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *carNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *threeing;
@property (weak, nonatomic) IBOutlet UILabel *tStartTimeL;
@property (weak, nonatomic) IBOutlet UILabel *tEndTimeL;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *baseLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *partLabels;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIScrollView *imgScrollView;
@property(nonatomic, strong)NSArray *imgsArr;

@end

@implementation CarInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self setScrollViewAdjustsScrollViewInsets:self.scrollView];
    [self fetchData];
}
- (void)fetchData {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient fetchCarInfo:self.car_id completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [weakSelf displayInfo:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"info")];
        
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)displayInfo:(NSDictionary *)dic {
    [self.iconImgView rj_setImageWithPath:StringForKeyInUnserializedJSONDic(dic, @"background")];
    self.carNameLabel.text = StringForKeyInUnserializedJSONDic(dic, @"v_name");
    self.tStartTimeL.text = StringForKeyInUnserializedJSONDic(dic, @"packs_starttime");
    self.tEndTimeL.text = StringForKeyInUnserializedJSONDic(dic, @"packs_endtime");
    BOOL is_packs = BoolForKeyInUnserializedJSONDic(dic, @"is_packs");
    self.threeing.selected = !is_packs;
    NSArray *arr = @[@"car_title",@"v_vin_num",@"v_factory_time",@"v_brand_time",@"v_production_name",@"v_name"];
    for (int i = 0; i<self.baseLabels.count; i++) {
        UILabel *l = self.baseLabels[i];
        l.text = StringForKeyInUnserializedJSONDic(dic, arr[i]);
    }
    
    NSString *mingpaiStr = StringForKeyInUnserializedJSONDic(dic, @"v_pictur");
    if (!IsStringEmptyOrNull(mingpaiStr)) {
        NSArray *arrImg = [mingpaiStr componentsSeparatedByString:@","];
        self.imgsArr = arrImg;
        if (arrImg && arrImg.count>0) {
            for (int i = 0; i<arrImg.count; i++) {
                UIImageView *mpImg = RJCreateSimpleImageView(CGRectMake(i*90, 0, 80, 80), nil);
                mpImg.tag = i+100;
                mpImg.userInteractionEnabled = YES;
                [mpImg addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage:)]];
                [mpImg rj_setImageWithPath:arrImg[i] placeholderImage:KDefaultImg];
                [self.imgScrollView addSubview:mpImg];
            }
            self.imgScrollView.contentSize = CGSizeMake(90*arrImg.count, 80);
        }
    }
    
    NSArray *arr2 = @[@"v_axle_name",@"v_suspension",@"v_tyre_name",@"v_abs",@"v_relay_name",@"v_relay_name",@"v_support_name",@"v_tow_name"];
    for (int i = 0; i<self.partLabels.count; i++) {
        UILabel *l = self.partLabels[i];
        if (i==1) {
            l.text = IntForKeyInUnserializedJSONDic(dic, arr[1])==1?@"有":@"无";
        } else {
            l.text = StringForKeyInUnserializedJSONDic(dic, arr2[i]);
        }
    }
}

- (void)showImage:(UITapGestureRecognizer *)tap {
    UIView *imgView = tap.view;
    SDPhotoBrowser *photo = [[SDPhotoBrowser alloc] init];
    photo.delegate = self;
    photo.imageCount = self.imgsArr.count;
    photo.currentImageIndex = imgView.tag-100;
    photo.sourceImagesContainerView = self.imgScrollView;
    [photo show];
}

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    UIImageView *imgView = [self.imgScrollView viewWithTag:index+100];
    return imgView.image;
}

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index {
    if (!self.imgsArr || self.imgsArr.count <= index) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",KImgBaseUrl,self.imgsArr[index]]];
}

- (IBAction)backBtnClick:(id)sender {
    [self backBtnAction];
}

@end
