//

#import "AddressEditViewController.h"
#import "RJBaseTableViewCell.h"
#import "IssueInputView.h"
#import "AddressModel.h"
#import "CityInputView.h"
#import "CityDataManager.h"

@interface AddressEditViewController ()<UITextViewDelegate,UITextFieldDelegate>
@property(nonatomic,strong)UITextField *nameTF;
@property(nonatomic,strong)UITextField *phoneTF;
@property(nonatomic,strong)UITextField *cityTF;
@property(nonatomic,strong)UITextView *addressTV;
@property(nonatomic,strong)UISwitch *autoSwitch;
@property(nonatomic, weak)UILabel *placeLabel;

@property(nonatomic, strong)ProvinceModel *province;
@property(nonatomic, strong)CityModel *city;
@property(nonatomic, weak)UIScrollView *scrollView;
@end

@implementation AddressEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"新增地址";
    if (self.model) {
        self.title=@"修改地址";
    }
    [self createMainView];
}

- (void)createMainView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KViewNavHeight)];
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
     IssueInputView *nameView = [[IssueInputView alloc] initWithY:0 title:@"收货人" placeholder:@"请输入收货人姓名" rightText:nil];
    [scrollView addSubview:nameView];
    self.nameTF = nameView.textField;
    nameView.textField.returnKeyType = UIReturnKeyDone;
    nameView.textField.delegate = self;
    IssueInputView *phoneView = [[IssueInputView alloc] initWithY:nameView.bottom title:@"联系电话" placeholder:@"请输入联系电话" rightText:nil];
    [scrollView addSubview:phoneView];
    self.phoneTF = phoneView.textField;
    
    UIImageView *ii = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 7, 12)];
    ii.image = [UIImage imageNamed:@"come001"];
    IssueInputView *zoneView = [[IssueInputView alloc]initWithY:phoneView.bottom title:@"所在地区" placeholder:@"请选择所在地区" rightView:ii];
    self.cityTF = zoneView.textField;
    CityInputView *cityInput=[[CityInputView alloc] init];
    weakify(self);
    cityInput.areaBlock = ^(ProvinceModel *p, CityModel *c) {
        weakSelf.province = p;
        weakSelf.city = c;
        NSString *pStr = p.province;
        NSString *cStr = c.city;
        if (!IsStringEmptyOrNull(cStr)) {
            weakSelf.cityTF.text = [NSString stringWithFormat:@"%@ %@",pStr,cStr];
        } else {
            weakSelf.cityTF.text = pStr;
        }
    };
    cityInput.areaResignBlock = ^{
        [weakSelf.view endEditing:YES];
    };
    self.cityTF.inputView =cityInput;
    
    [scrollView addSubview:zoneView];
    
    UIView *detailView = RJCreateSimpleView(CGRectMake(0, zoneView.bottom, KScreenWidth, 80), KTextWhiteColor);
    [scrollView addSubview:detailView];
    
    UILabel *placeL = RJCreateDefaultLable(CGRectMake(15, 15, 150, 16), kFontWithSmallSize, kPlaceholderColor, @"请输入详细地址");
    [detailView addSubview:placeL];
    self.placeLabel = placeL;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 7, KScreenWidth-20, detailView.height-14)];
    [detailView addSubview:textView];
    textView.font = kFontWithSmallSize;
    textView.textColor = KTextDarkColor;
    textView.backgroundColor = [UIColor clearColor];
    self.addressTV = textView;
    textView.delegate = self;
    textView.returnKeyType = UIReturnKeyDone;
    
    IssueInputView *autoView = [[IssueInputView alloc]initWithY:detailView.bottom+10 title:@"设为默认" placeholder:nil rightView:self.autoSwitch];
    autoView.textField.enabled = NO;
    autoView.textField.width = 0;
    self.autoSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(KScreenWidth-80, 0, 60, 30)];

    self.autoSwitch.right = KScreenWidth-10;
    self.autoSwitch.centerY = autoView.height/2.0;
    [autoView addSubview:self.autoSwitch];[scrollView addSubview:autoView];
    UIButton *addBtn = [UIButton sureButtonWithTop:autoView.bottom+50 title:@"添加"];
    [scrollView addSubview:addBtn];
    [addBtn addTarget:self action:@selector(addClick:) forControlEvents:UIControlEventTouchUpInside];
    scrollView.contentSize = CGSizeMake(KScreenWidth, addBtn.bottom+10);
        
    if (self.model) {// 修改地址
        [self fetchAddressDetail];
    }
}

- (void)displayEditAddress:(NSDictionary *)dic {
    ProvinceModel *p = [ProvinceModel new];
    p.provinceid = StringForKeyInUnserializedJSONDic(dic, @"province");
    p.province = StringForKeyInUnserializedJSONDic(dic, @"province_name");
    self.province = p;
    CityModel *c = [CityModel new];
    c.city = StringForKeyInUnserializedJSONDic(dic, @"city_name");
    c.cityid = StringForKeyInUnserializedJSONDic(dic, @"city");
    self.city = c;
    self.nameTF.text = StringForKeyInUnserializedJSONDic(dic, @"consigner");
    self.phoneTF.text = StringForKeyInUnserializedJSONDic(dic, @"mobile");
    self.cityTF.text = [NSString stringWithFormat:@"%@ %@",p.province,c.city];
    self.addressTV.text = StringForKeyInUnserializedJSONDic(dic, @"address");
    if (self.addressTV.text.length>0) {
        self.placeLabel.hidden=1;
    }
    self.autoSwitch.on = BoolForKeyInUnserializedJSONDic(dic, @"is_default");
}

- (void)fetchAddressDetail {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient fetchAddressDetail:self.model.aid completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [weakSelf displayEditAddress:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"info")];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

-(void)addClick:(UIButton *)sender{
    if (self.nameTF.text.length==0) {
        ShowAutoHideMBProgressHUD(self.view, self.nameTF.placeholder);
        return;
    }
    if (self.phoneTF.text.length==0) {
        ShowAutoHideMBProgressHUD(self.view, self.phoneTF.placeholder);
        return;
    }
    if (self.cityTF.text.length==0) {
        ShowAutoHideMBProgressHUD(self.view, self.cityTF.placeholder);
//        return;
    }
    if (self.addressTV.text.length==0) {
        ShowAutoHideMBProgressHUD(self.view, self.placeLabel.text);
        return;
    }
    [self endViewEditing];
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient editAddress:self.nameTF.text mobile:self.phoneTF.text province:self.province.provinceid city:self.city.cityid address:self.addressTV.text defau:self.autoSwitch.isOn addresID:self.model.aid completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            if (weakSelf.reloadAddressBlock) {
                weakSelf.reloadAddressBlock();
            }
            SuccessMBProgressHUD(weakSelf.view, response.message);
            [NSTimer scheduledTimerWithTimeInterval:1.5 target:weakSelf selector:@selector(popVc) userInfo:nil repeats:NO];
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}
-(void)popVc{
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)endViewEditing {
    [self.view endEditing:YES];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView {
    self.placeLabel.hidden=textView.text.length>0;
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - 键盘弹出及收起
- (void)keyboardWasShown:(NSNotification *)noti {
    CGFloat hei = FetchKeyBoardHeight(noti);
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.height = KViewNavHeight-hei;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification *)noti {
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.height = KViewNavHeight;
    }];
}


-(void)zoneClick{
    NSLog(@"3333");
}

@end
