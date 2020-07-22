

#import "CityInputView.h"

@interface CityInputView ()<UIPickerViewDelegate, UIPickerViewDataSource>
@property(nonatomic, strong)UIPickerView *pickView;
@property(nonatomic, strong)NSArray *dataArray;
@property(nonatomic, strong)ProvinceModel *province;
@property(nonatomic, strong)CityModel *city;

@end

@implementation CityInputView
- (instancetype)init {
    self =[super initWithFrame:CGRectMake(0, 0, KScreenWidth, 300+kIPhoneXBH)];
    if (self) {
        self.backgroundColor = KTextWhiteColor;
        UIButton *sure = [UIButton buttonWithFrame:CGRectMake(KScreenWidth-50, 0, 40, 40) title:@"确定" font:kFontWithSmallSize titleColor:kTextBlueColor target:self action:@selector(buttonAction:)];
        sure.tag = 100;
        [self addSubview:sure];
        
        UIButton *cancel = [UIButton buttonWithFrame:CGRectMake(10, 0, 40, 40) title:@"取消" font:kFontWithSmallSize titleColor:kTextBlueColor target:self action:@selector(buttonAction:)];
        [self addSubview:cancel];
        
//        NSString *str = [[NSBundle mainBundle]pathForResource:@"area.json"ofType:nil];
//        NSData *data = [NSData dataWithContentsOfFile:str];
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
//        self.dataArray = ObjForKeyInUnserializedJSONDic(dict, @"root");
//        self.proviceDict = self.dataArray.firstObject;
//        NSArray *cities = ObjForKeyInUnserializedJSONDic(self.proviceDict, @"cities");
//        self.cityDict = cities.firstObject;
//        NSArray *counties = ObjForKeyInUnserializedJSONDic(self.cityDict, @"counties");
//        self.countDict = counties.firstObject;
        [self addSubview:self.pickView];
        if (![CityDataManager sharedInstance].loadProvince) {
            [self fetchProvinceList];
        } else {
            [self reloadPickView];
        }
    }
    return self;
}

- (void)fetchProvinceList {
    WaittingMBProgressHUD(self, @"");
    weakify(self);
    [kRJHTTPClient fetchProvinceListCompletion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [weakSelf reloadPickView];
        }
        FinishMBProgressHUD(weakSelf);
    }];
}

- (void)reloadPickView {
    [self.pickView reloadComponent:0];
    if ([CityDataManager sharedInstance].provincesArray>0) {
        [self.pickView selectRow:0 inComponent:0 animated:YES];
        self.province = [CityDataManager sharedInstance].provincesArray.firstObject;
        [self.pickView reloadComponent:1];
        if (self.province.citysArray.count>0) {
            self.city = self.province.citysArray.firstObject;
            [self.pickView selectRow:0 inComponent:1 animated:YES];
        }
        
    }
}

- (void)buttonAction:(UIButton *)btn {
    if (btn.tag == 100) {
        if (self.areaBlock) {
            self.areaBlock(self.province,self.city);
        }
    }
    if (self.areaResignBlock) {
        self.areaResignBlock();
    }
}

- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *str = nil;
    if (component==0) {
        ProvinceModel *p = [CityDataManager sharedInstance].provincesArray[row];
        str = p.province;
    } else if (component == 1) {
        if (self.province) {
            CityModel *c = self.province.citysArray[row];
            str = c.city;
        }
    }
    if (str) {
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:str];
        [att addAttribute:NSFontAttributeName value:kFontWithSmallSize range:NSMakeRange(0, str.length)];
        [att addAttribute:NSForegroundColorAttributeName value:KTextDarkColor range:NSMakeRange(0, str.length)];
        return att;
    } else {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component==0) {
        self.province = [CityDataManager sharedInstance].provincesArray[row];
        if (self.province.loadCity) {
            self.city = self.province.citysArray.firstObject;
            [pickerView reloadComponent:1];
            [pickerView selectRow:0 inComponent:1 animated:YES];
        } else {
            self.city = nil;
            WaittingMBProgressHUD(self, @"");
            weakify(self);
            [self.province loadCityListCompletion:^(WebResponse *response) {
                weakSelf.city = weakSelf.province.citysArray.firstObject;
                [weakSelf.pickView reloadComponent:1];
                [weakSelf.pickView selectRow:0 inComponent:1 animated:YES];
                FinishMBProgressHUD(weakSelf);
            }];
        }
        
    } else if (component == 1) {
        if (self.province) {
            self.city = self.province.citysArray[row];
        }
    }
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component==0) {
        return [CityDataManager sharedInstance].provincesArray.count;
    } else if (component==1) {
        if (self.province) {
            return self.province.citysArray.count;
        }
    }
    return 0;
}

- (UIPickerView *)pickView {
    if (!_pickView) {
        _pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, KScreenWidth, 240)];
        _pickView.delegate=self;
        _pickView.dataSource=self;
    }
    return _pickView;
}

@end
