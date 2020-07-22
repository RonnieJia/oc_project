//
//  RepairInfoViewController.m
//  APPFormwork

#import "RepairInfoViewController.h"
#import "RepairModel.h"
#import "SDPhotoBrowser.h"
#import "FixModel.h"

@interface RepairInfoViewController ()<SDPhotoBrowserDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *stateTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UILabel *carL;
@property (weak, nonatomic) IBOutlet UILabel *positonL;
@property (weak, nonatomic) IBOutlet UILabel *reasomL;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *userL;
@property (weak, nonatomic) IBOutlet UILabel *phoneL;

@property(nonatomic, strong)NSArray *imgsArr;

@end

@implementation RepairInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isFix) {
        self.title = @"维修信息";
        self.contentView.hidden = YES;
        [self fetchFixInfo];
    } else {
        self.title = @"报修信息";
        [self display];
    }
    self.stateL.text = self.state;
}

- (void)fetchFixInfo {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    self.clientDataTask = [kRJHTTPClient fetchFixInfo2:self.fixModel.order_rid completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [weakSelf displayFix:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"info")];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)displayFix:(NSDictionary *)dic {
    self.stateTitleLabel.text = @"维修状态";
    self.timeL.text=getStringFromTimeintervalString(StringForKeyInUnserializedJSONDic(dic, @"create_time"), @"yyyy-MM-dd HH:mm");
    self.carL.text = StringForKeyInUnserializedJSONDic(dic, @"v_name");
    self.reasomL.text = StringForKeyInUnserializedJSONDic(dic, @"question");
    self.userL.text = StringForKeyInUnserializedJSONDic(dic, @"o_nickname");
    self.phoneL.text = StringForKeyInUnserializedJSONDic(dic, @"o_number");
    self.positonL.text = StringForKeyInUnserializedJSONDic(dic, @"r_address");
    
    NSString *imgs = StringForKeyInUnserializedJSONDic(dic, @"r_pictur");
    if (!IsStringEmptyOrNull(imgs)) {
        NSArray *imgs = [self.repairModel.re_pictures componentsSeparatedByString:@","];
        self.imgsArr = imgs;
        for (int i = 0; i<imgs.count; i++) {
            UIImageView *imgView = RJCreateSimpleImageView(CGRectMake(i*85, 0, 75, 75), nil);
            imgView.layer.cornerRadius = 4;
            imgView.clipsToBounds=YES;
            imgView.tag = i+100;
            imgView.userInteractionEnabled = YES;
            [self.scrollView addSubview:imgView];
            self.scrollView.contentSize = CGSizeMake(imgView.right, 75);
            [imgView rj_setImageWithPath:imgs[i] placeholderImage:KDefaultImg];
            [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage:)]];
        }
    }
    self.contentView.hidden = NO;
}

- (void)display {
    self.timeL.text=getStringFromTimeintervalString(self.repairModel.create_time, @"yyyy-MM-dd HH:mm");
    self.carL.text = self.repairModel.v_name;
    self.reasomL.text = self.repairModel.re_describe;
    self.userL.text = self.repairModel.o_nickname;
    self.phoneL.text = self.repairModel.contact_phone;
    self.positonL.text = self.repairModel.re_address;
    
    if (!IsStringEmptyOrNull(self.repairModel.re_pictures)) {
        NSArray *imgs = [self.repairModel.re_pictures componentsSeparatedByString:@","];
        self.imgsArr = imgs;
        for (int i = 0; i<imgs.count; i++) {
            UIImageView *imgView = RJCreateSimpleImageView(CGRectMake(i*85, 0, 75, 75), nil);
            imgView.layer.cornerRadius = 4;
            imgView.clipsToBounds=YES;
            imgView.tag = i+100;
            imgView.userInteractionEnabled = YES;
            [self.scrollView addSubview:imgView];
            self.scrollView.contentSize = CGSizeMake(imgView.right, 75);
            [imgView rj_setImageWithPath:imgs[i] placeholderImage:KDefaultImg];
            [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage:)]];
        }
    }
}

- (void)showImage:(UITapGestureRecognizer *)tap {
    UIView *imgView = tap.view;
    SDPhotoBrowser *photo = [[SDPhotoBrowser alloc] init];
    photo.delegate = self;
    photo.imageCount = self.imgsArr.count;
    photo.currentImageIndex = imgView.tag-100;
    photo.sourceImagesContainerView = self.scrollView;
    [photo show];
}

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    UIImageView *imgView = [self.scrollView viewWithTag:index+100];
    return imgView.image;
}

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index {
    if (!self.imgsArr || self.imgsArr.count <= index) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",KImgBaseUrl,self.imgsArr[index]]];
}

@end
