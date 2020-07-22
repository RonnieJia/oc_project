
#import "ShopInfoViewController.h"
#import "RJImagePickerManager.h"
#import "ShowImageViewController.h"
#import "ShopInfoModel.h"
#import "ChooseCityViewController.h"
#import "AppEntrance.h"
#import "MapAddressViewController.h"

@interface ShopInfoViewController ()<UITextFieldDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *iconIMGView;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *phone2TF;
@property (weak, nonatomic) IBOutlet UITextField *rangeTF;
@property (weak, nonatomic) IBOutlet UITextField *cityTF;
@property (weak, nonatomic) IBOutlet UILabel *introduceTF;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) UIImage *iconIMG;
@property (weak, nonatomic) IBOutlet UITextView *introTV;

@property(nonatomic, strong)ShopInfoModel *infoModel;

@property(nonatomic, strong)NSArray *backgroundImgs;
@property(nonatomic, strong)NSArray *photoImgs;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentBottom;

@property(nonatomic, assign)__block CGFloat lat;
@property(nonatomic, assign)__block CGFloat lon;
@end

@implementation ShopInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"店铺资料";
    [self setBackButton];
    [self fetchShopInfo];
    [self.photoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTap)]];
    [self.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap)]];
    [self.scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignTextFiled)]];
    self.cityTF.delegate= self;
    self.cityTF.enabled = self.first;
    self.nameTF.enabled = self.first;
    self.addressTF.delegate = self;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.cityTF]) {
        [self resignTextFiled];
        ChooseCityViewController *city = [ChooseCityViewController new];
        weakify(self);
        city.chooseCity = ^(NSString * _Nonnull city, NSString * _Nonnull cityId) {
            weakSelf.infoModel.r_address = city;
            weakSelf.infoModel.city_id = cityId;
            weakSelf.cityTF.text = city;
        };
        [self.navigationController pushViewController:city animated:YES];
        return NO;
    } else if ([textField isEqual:self.addressTF]) {
        MapAddressViewController *add = [[MapAddressViewController alloc] init];
        weakify(self);
        add.chooseMapAddress = ^(NSString * _Nonnull str, CGFloat lat, CGFloat lon) {
            if (str) {
                weakSelf.addressTF.text = str;
                weakSelf.lat = lat;
                weakSelf.lon = lon;
            }
        };
        [self.navigationController pushViewController:add animated:YES];
        return NO;
    }
    return YES;
}

- (void)resignTextFiled {
    [self.view endEditing:YES];
}

- (void)photoTap {
    ShowImageViewController *show = [[ShowImageViewController alloc] init];
    show.imgs = self.photoImgs;
    weakify(self);
    show.changeImagesBlock = ^(NSArray * _Nonnull arr) {
        weakSelf.photoImgs = arr;
        [weakSelf displayImages:1 arr:arr];
    };
    [self.navigationController pushViewController:show animated:YES];
}
- (void)backgroundTap {
    ShowImageViewController *show = [[ShowImageViewController alloc] init];
    weakify(self);
    show.changeImagesBlock = ^(NSArray * _Nonnull arr) {
        weakSelf.backgroundImgs = arr;
        [weakSelf displayImages:0 arr:arr];
    };
    show.imgs = self.backgroundImgs;
    [self.navigationController pushViewController:show animated:YES];
}

- (void)fetchShopInfo {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    self.clientDataTask = [kRJHTTPClient fetchShopInfoCompletion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            weakSelf.infoModel = [ShopInfoModel modelWithJSONDict:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"info")];
            [weakSelf displayInfo:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"info")];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)displayInfo:(NSDictionary *)dic {
    [self.iconIMGView rj_setImageWithPath:self.infoModel.r_portrait placeholderImage:KDefaultImg];
    self.nameTF.text = self.infoModel.r_name;
    self.addressTF.text = self.infoModel.address;
    self.phoneTF.text = self.infoModel.r_phone;
    self.rangeTF.text = self.infoModel.r_range;
    self.introTV.text = self.infoModel.r_introduce;
    self.cityTF.text = self.infoModel.r_address;
    self.phone2TF.text = self.infoModel.spare_phone;
    
    NSString *bgPictures = self.infoModel.r_background;
    self.backgroundImgs = [bgPictures componentsSeparatedByString:@","];
    [self displayImages:0 arr:self.backgroundImgs];
    NSString *photoPictures = self.infoModel.r_photo;
    self.photoImgs = [photoPictures componentsSeparatedByString:@","];
    [self displayImages:1 arr:self.photoImgs];
}

- (void)displayImages:(NSInteger)type arr:(NSArray *)imgs {
    if (type == 1) {
        UIScrollView *sc = [self.photoView viewWithTag:999];
        if (sc) {
            [sc removeFromSuperview];
        }
    } else {
        UIScrollView *sc = [self.backgroundView viewWithTag:999];
        if (sc) {
            [sc removeFromSuperview];
        }
    }
    
    if (imgs && imgs.count>0) {
        UIScrollView *bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(80, 10, KScreenWidth-80-27, 60)];
        bgScrollView.tag = 999;
        if (type==1) {
            [self.photoView addSubview:bgScrollView];
        } else {
            [self.backgroundView addSubview:bgScrollView];
        }
        UIView *contentView = RJCreateSimpleView(CGRectMake(0, 0, 200, 60), KTextWhiteColor);
        [bgScrollView addSubview:contentView];
        for (int i = 0; i<imgs.count; i++) {
            UIImageView *imgView = RJCreateImageView(CGRectMake(70*i, 0, 60, 60), KTextWhiteColor, nil, 4);
            imgView.contentMode = UIViewContentModeScaleToFill;
            id obj = imgs[i];
            if ([obj isKindOfClass:[UIImage class]]) {
                imgView.image = obj;
            } else {
                [imgView rj_setImageWithPath:imgs[i] placeholderImage:KDefaultImg];
            }
            [contentView addSubview:imgView];
            contentView.width = imgView.right;
        }
        if (contentView.width < bgScrollView.width) {
            contentView.left = bgScrollView.width-contentView.width-1;
        }
        bgScrollView.contentSize = CGSizeMake(contentView.right, 60);
    }
}

- (IBAction)changeIconImg:(id)sender {
    weakify(self);
    [[RJImagePickerManager sharedInstance] viewController:self showTitle:@"店铺头像" callBack:^(UIImage *image) {
        weakSelf.iconIMG = image;
        weakSelf.iconIMGView.image = image;
    }];
}
- (IBAction)changeShopInfo:(id)sender {
    dispatch_group_t group = dispatch_group_create();
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    if (self.iconIMG) {
        dispatch_group_enter(group);
        [kRJHTTPClient uploadImage:self.iconIMG completion:^(WebResponse *response) {
            if (response.code == WebResponseCodeSuccess) {
                weakSelf.infoModel.r_portrait = StringForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"data");
            }
            dispatch_group_leave(group);
        }];
    }
    NSMutableArray *photosArray = [NSMutableArray array];
    for (id obj in self.photoImgs) {
        if ([obj isKindOfClass:[UIImage class]]) {
            dispatch_group_enter(group);
            [kRJHTTPClient uploadImage:obj completion:^(WebResponse *response) {
                if (response.code == WebResponseCodeSuccess) {
                    [photosArray addObject:StringForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"data")];
                }
                dispatch_group_leave(group);
            }];
        } else {
            [photosArray addObject:obj];
        }
    }
    
    NSMutableArray *backgroundArray = [NSMutableArray array];
    for (id obj in self.backgroundImgs) {
        if ([obj isKindOfClass:[UIImage class]]) {
            dispatch_group_enter(group);
            [kRJHTTPClient uploadImage:obj completion:^(WebResponse *response) {
                if (response.code == WebResponseCodeSuccess) {
                    [backgroundArray addObject:StringForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"data")];
                }
                dispatch_group_leave(group);
            }];
        } else {
            [backgroundArray addObject:obj];
        }
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [kRJHTTPClient editShop:weakSelf.infoModel.r_portrait name:weakSelf.nameTF.text address:weakSelf.addressTF.text city:weakSelf.infoModel.city_id phone:weakSelf.phoneTF.text range:weakSelf.rangeTF.text backgroun:[backgroundArray componentsJoinedByString:@","] demeanor:[photosArray componentsJoinedByString:@","] content:weakSelf.introTV.text lat:weakSelf.lat lon:weakSelf.lon phone2:self.phone2TF.text completion:^(WebResponse *response) {
            if (response.code == WebResponseCodeSuccess) {
//                [self updateUserInfoToChat];
                if (self.first) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [AppEntrance setLoginForRoot];
                    });
                }
            }
            FailedMBProgressHUD(weakSelf.view, response.message);
            
        }];
        
    });
}

/// 更新极光的用户信息
- (void)updateUserInfoToChat {
    JMSGUserInfo *info = [[JMSGUserInfo alloc] init];
    info.nickname = self.nameTF.text;
    self.iconIMG = [UIImage imageNamed:@"shopbanner004"];
    if (self.iconIMG) {
        NSData *data = UIImageJPEGRepresentation(self.iconIMG, 0.5);
        info.avatarData = data;
    }
    [JMSGUser updateMyInfoWithUserInfo:info completionHandler:^(id resultObject, NSError *error) {
        if (!error) {
            RJLog(@"更新成功");
        }
    }];
}

#pragma mark - 键盘弹出及收起
- (void)keyboardWasShown:(NSNotification *)noti {
    CGFloat hei = FetchKeyBoardHeight(noti);
    self.contentBottom.constant = hei+20;
}

- (void)keyboardWillBeHidden:(NSNotification *)noti {
    self.contentBottom.constant = 20;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height-self.scrollView.height)];
    });
}
@end
