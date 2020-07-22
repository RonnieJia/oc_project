
#import "RJFunctions.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Base64.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "RJNavigationController.h"
#import "LoginViewController.h"

#pragma mark - for 康家来
BOOL TimeAfterNow(NSTimeInterval time) {
    NSTimeInterval nowTimeInterval = [[NSDate dateWithTimeIntervalSinceNow:-15*24*2600] timeIntervalSince1970];
    return time>nowTimeInterval;
}
NSArray* TimeTransToHMS(NSTimeInterval time) {
    if (!TimeAfterNow(time)) {
        return @[@"0",@"0",@"0"];
    }
    NSTimeInterval nowTimeInterval = [[NSDate dateWithTimeIntervalSinceNow:-15*24*2600] timeIntervalSince1970];
    long long total = (long long)(time-nowTimeInterval);
    NSInteger hour = total/3600;
    NSInteger min = total%3600/60;
    NSInteger second = total%60;
    return @[[NSString stringWithFormat:@"%zd",hour],[NSString stringWithFormat:@"%zd",min],[NSString stringWithFormat:@"%zd",second]];
}





#pragma mark - JSON
void AddObjectForKeyIntoDictionary(id object, id key, NSMutableDictionary *dic)
{
    if (object == nil || key == nil || dic == nil
        || ![dic isKindOfClass:[NSDictionary class]]
        || ([object isKindOfClass:[NSString class]] && [object isEqualToString:@""]))
        return;
    
    [dic setObject:object forKey:key];
}

id ObjForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key)
{
    if (unserializedJSONDic == nil || key == nil || ![unserializedJSONDic isKindOfClass:[NSDictionary class]])
        return nil;
    
    id obj = [unserializedJSONDic objectForKey:key];
    if (obj == [NSNull null])
        return nil;
    else if ([obj isKindOfClass:[NSString class]] && [obj isEqualToString:@""])
        return nil;
    else
        return obj;
}
NSString* StringForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key)
{
    id obj = ObjForKeyInUnserializedJSONDic(unserializedJSONDic,key);
    if (obj == nil) {
        return  @"";
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    return  [NSString stringWithFormat:@"%@",obj];
}
CGFloat FloatForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key)
{
    id obj = ObjForKeyInUnserializedJSONDic(unserializedJSONDic,key);
    if (obj == nil) {
        return  0.0;
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj floatValue];
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return [obj floatValue];
    }
    return  0.0;
}
double DoubleForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key)
{
    id obj = ObjForKeyInUnserializedJSONDic(unserializedJSONDic,key);
    if (obj == nil) {
        return  0.0;
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj doubleValue];
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return [obj doubleValue];
    }
    return  0.0;
}
NSInteger IntForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key)
{
    id obj = ObjForKeyInUnserializedJSONDic(unserializedJSONDic,key);
    if (obj == nil) {
        return  0;
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj intValue];
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return [obj intValue];
    }
    return  0;
}
Boolean BoolForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key)
{
    id obj = ObjForKeyInUnserializedJSONDic(unserializedJSONDic,key);
    if (obj == nil) {
        return  NO;
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj boolValue];
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return [obj boolValue];
    }
    return  NO;
}
UInt64 BigIntForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key)
{
    id obj = ObjForKeyInUnserializedJSONDic(unserializedJSONDic,key);
    if (obj == nil) {
        return  0;
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj unsignedLongLongValue];
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return [obj unsignedLongLongValue];
    }
    return  0;
}

#pragma mark html字符串处理
NSString *htmlString(NSString *string) {
    if (!string) {
        return nil;
    }
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    
    return string;
}

#pragma mark DES加密、解密
NSString *DESEncrypt(NSString *string) {
    NSString *key = @"RJ!@#_&%";
    NSString *ciphertext = nil;
    NSData *textData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [textData length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    Byte iv[] = {1,2,3,4,5,6,7,8};
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          iv,
                                          [textData bytes], dataLength,
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        ciphertext = [Base64 stringByEncodingData:data];
    }
    return ciphertext;
}
NSString *DESDecrypt(NSString *string) {
    NSString *key = @"RJ!@#_&%";
    NSData* cipherData = [Base64 decodeString:string];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    Byte iv[] = {1,2,3,4,5,6,7,8};
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          iv,
                                          [cipherData bytes],
                                          [cipherData length],
                                          buffer,
                                          1024,
                                          &numBytesDecrypted);
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData* data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        plainText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return plainText;
}

#pragma mark -MD5加密
NSString* EncryptPassword(NSString *str)
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


#pragma mark -判断是否为空
Boolean IsStringEmptyOrNull(NSString * str)
{
    if (!str) {
        // null object
        return true;
    } else {
        if ([str isKindOfClass:[NSNull class]]) {
            return true;
        }
        if (![[str class] isSubclassOfClass:[NSString class]]) {
            
            str=[NSString stringWithFormat:@"%@",str];
        }
        
        NSString *trimedString = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimedString length] == 0) {
            // empty string
            return true;
        } else if([trimedString isEqualToString:@"null"]){
            // is neither empty nor null
            return true;
        }else if([trimedString isEqualToString:@"<null>"]){
            // is neither empty nor null
            return true;
        }
        else if([trimedString isEqualToString:@"(null)"]){
            // is neither empty nor null
            return true;
        }else {
            return false;
        }
    }
}

Boolean IsNumber(NSString *str) {
    if (IsStringEmptyOrNull(str)) {
        return NO;
    }
     NSInteger count = [[str mutableCopy] replaceOccurrencesOfString:@"." // 要查询的字符串中的某个字符
                                                             withString:@"a"
                                                                options:NSLiteralSearch
                                                                  range:NSMakeRange(0, [str length])];
    if (count>1) {
        return NO;
    }
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    NSString *filtered = [[str componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];

    if (![str isEqualToString:filtered]) {
        return NO;
    }
    return YES;
}
#pragma mark -是否为手机号
Boolean IsNormalMobileNum(NSString  *userMobileNum){
    if ([userMobileNum length] != 11) {
        return NO;
    }
    if (![[userMobileNum substringToIndex:1] isEqualToString:@"1"]) {
        return NO;
    }
    NSString *sub2 = [userMobileNum substringWithRange:NSMakeRange(1, 1)];
    NSInteger sub2Int = [sub2 integerValue];
    if (sub2Int < 3 ) {
        return NO;
    }
    
//    NSString *regex = @"^([1][34578])\\d{9}$";
//
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//
//    return [pred evaluateWithObject:userMobileNum];
    return YES;
    
}
#pragma mark - 保存用户信息
void UserDefaultSaveBool(NSString *key, BOOL value) {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
BOOL UserDefaultBoolForKey(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

void UserDefaultSaveObj(NSString *key, id obj) {
    [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
id UserDefaultObjForKey(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

void SaveUser(NSString *uName, NSString *pwd, NSString *uid) {
    if (!IsStringEmptyOrNull(uName) && !IsStringEmptyOrNull(pwd)) {
        NSString *DESPwd = DESEncrypt(pwd);// 将密码DES加密存储
        NSString *DESId = DESEncrypt(uid);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:uName forKey:@"rjsave_username"];
        [defaults setObject:DESPwd forKey:@"rjsave_pwd"];
        [defaults setObject:DESId forKey:@"rjsave_Uid"];
        [defaults synchronize];
    }
}

void SaveUserToken(NSString *uid, NSString *token, NSString *refreshToken) {
    if (!IsStringEmptyOrNull(token) && !IsStringEmptyOrNull(uid)) {
        NSString *DESId = DESEncrypt(uid);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:DESId forKey:@"rjsave_Uid"];
        [defaults setObject:DESEncrypt(token) forKey:@"rjsave_token"];
        [defaults setObject:DESEncrypt(refreshToken) forKey:@"rjsave_retoken"];
        [defaults synchronize];
    }
}

void SaveUserInfo(NSDictionary *dict) {
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (NSString *key in dict.allKeys) {
            NSString *value = dict[key];
            if ([value isKindOfClass:[NSNull class]] || ([value isKindOfClass:[NSString class]] && IsStringEmptyOrNull(value))) {
                value=@"";
            }
            [dic setObject:value forKey:key];
        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:dic forKey:@"rjuser_Info"];
        [defaults synchronize];
    }
}

void ClearUser() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"rjsave_pwd"];
    [defaults removeObjectForKey:@"rjuser_Info"];
    [defaults removeObjectForKey:@"rjsave_Uid"];
    [defaults removeObjectForKey:@"rjsave_token"];
    [defaults removeObjectForKey:@"rjsave_retoken"];
    [defaults synchronize];
}

BOOL IsSaveUser() {
    NSString *pwd = GetUserPwd();
    NSString *userid = GetUserId();
    if (pwd && userid && [pwd isKindOfClass:[NSString class]] && pwd.length > 0 && [userid isKindOfClass:[NSString class]] && userid.length > 0) {
        return YES;
    }
    return NO;
}

NSDictionary *GetUserInfo(){
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"rjuser_Info"];

}
NSString *GetUserName() {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"rjsave_username"];
}

NSString *GetUserId() {
    return DESDecrypt([[NSUserDefaults standardUserDefaults] objectForKey:@"rjsave_Uid"]);
}

NSString *GetUserToken() {
    return DESDecrypt([[NSUserDefaults standardUserDefaults] objectForKey:@"rjsave_token"]);
}

NSString *GetUserReToken() {
    return DESDecrypt([[NSUserDefaults standardUserDefaults] objectForKey:@"rjsave_retoken"]);
}

NSString *GetUserPwd() {
    return DESDecrypt([[NSUserDefaults standardUserDefaults] objectForKey:@"rjsave_pwd"]);
}

void SaveUserCity(NSString *city_name, NSString *city_id) {
    if (IsStringEmptyOrNull(city_name) || IsStringEmptyOrNull(city_id)) {
        
    } else {
        NSDictionary *dict = @{@"city_name":city_name, @"city_id":city_id};
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:[NSString stringWithFormat:@"user_cityInfo_%@",[CurrentUserInfo sharedInstance].userId]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

NSDictionary *GetUserCityInfo() {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"user_cityInfo_%@",[CurrentUserInfo sharedInstance].userId]];
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        return dict;
    }
    return nil;
}


void SaveUserLocation(NSString *lat, NSString *lon, NSString *city) {
    if (IsStringEmptyOrNull(lat) || IsStringEmptyOrNull(lon) || IsStringEmptyOrNull(city)) {
        
    } else {
        NSDictionary *dict = @{@"lat":lat, @"lon":lon, @"city":city};
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"user_locatiionInfo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
NSString *GetUserLatitude() {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_locatiionInfo"];
    return [dict objectForKey:@"lat"];
}
NSString *GetUserLongtude() {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_locatiionInfo"];
    return [dict objectForKey:@"lon"];
}
NSString *GetUserCity() {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_locatiionInfo"];
    return [dict objectForKey:@"city"];
}


#pragma mark - 错误Alert提示
void ShowImportErrorAlertView(NSString *errorString){
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:errorString delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
}


#pragma mark -Image TOOL
UIImage* createImageWithColor(UIColor *color)
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

UIColor* colorAddAlpha(UIColor* color,CGFloat alpha)
{
    if (CGColorGetNumberOfComponents([color CGColor]) == 2) {
        const CGFloat *colorComponents = CGColorGetComponents([color CGColor]);
        return [UIColor colorWithRed:colorComponents[0]
                               green:colorComponents[0]
                                blue:colorComponents[0]
                               alpha:alpha];
    }
    else if (CGColorGetNumberOfComponents([color CGColor]) == 4) {
        const CGFloat * colorComponents = CGColorGetComponents([color CGColor]);
        return [UIColor colorWithRed:colorComponents[0]
                               green:colorComponents[1]
                                blue:colorComponents[2]
                               alpha:alpha];
    }
    return color;
}

#pragma mark -dateFormat
NSDateFormatter* dateLocalShortStyleFormatter()
{
    NSDateFormatter *dateFormatter = dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    dateFormatter.locale = [NSLocale currentLocale];
    return dateFormatter;
}

#pragma mark -MBProgressHUD
MBProgressHUD* CreateCustomColorHUDOnView(UIView *onView)
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:onView];
    hud.bezelView.color = [UIColor blackColor];
    hud.label.textColor = [UIColor whiteColor];
    return hud;
}

void ShowAutoHideMBProgressHUD(UIView *onView, NSString *labelText)
{
    if (!onView || [labelText length] <= 0)
        return;
    
    MBProgressHUD *hud = CreateCustomColorHUDOnView(onView);
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = labelText;
    hud.label.textColor = [UIColor whiteColor];
    hud.label.numberOfLines = 0;
    hud.completionBlock = nil;
    [onView addSubview:hud];
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:2.0];
}

void ShowAutoHideMBProgressHUDWithOneSec(UIView *onView, NSString *labelText)
{
    if (!onView || [labelText length] <= 0)
        return;
    
    MBProgressHUD *hud = CreateCustomColorHUDOnView(onView);
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = labelText;
    hud.label.numberOfLines = 0;
    hud.completionBlock = nil;
    [hud hideAnimated:YES afterDelay:0.3];
    [onView addSubview:hud];
    [hud showAnimated:YES];
}

void ShowIMAutoHideMBProgressHUD(UIView *onView, NSString *labelText)
{
    if (!onView || [labelText length] <= 0)
        return;
    
    MBProgressHUD *hud = CreateCustomColorHUDOnView(onView);
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = labelText;
    hud.label.numberOfLines = 0;
    hud.completionBlock = nil;
    [onView addSubview:hud];
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:1.0];
}

void WaittingMBProgressHUD(UIView *onView, NSString *labelText)
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:onView];
    if (hud == nil) {
        hud = [[MBProgressHUD alloc] initWithView:onView];
    }
    /*
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"rjloading" withExtension:@"gif"];
    //将GIF图片转换成对应的图片源
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef) fileUrl, NULL);
    //获取其中图片源个数，即由多少帧图片组成
    size_t frameCount = CGImageSourceGetCount(gifSource);
    //定义数组存储拆分出来的图片
    NSMutableArray *frames = [[NSMutableArray alloc] init];
    for (size_t i = 0; i < frameCount; i++) {
        //从GIF图片中取出源图片
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        //将图片源转换成UIimageView能使用的图片源
        UIImage *imageName = [UIImage imageWithCGImage:imageRef];
        //将图片加入数组中
        [frames addObject:imageName];
        CGImageRelease(imageRef);
    }
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.animationImages = frames;
    imgView.animationDuration=1.5;
    //    imgView.animationRepeatCount = 0;
    [imgView startAnimating];
    */
    UIImageView *imgView = RJCreateSimpleImageView(CGRectMake(0, 0, KAUTOSIZE(116), KAUTOSIZE(116)), [UIImage imageNamed:@"xlloading"]);
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = imgView;
    hud.removeFromSuperViewOnHide = YES;
    if (labelText && [labelText isKindOfClass:[NSString class]] && labelText.length>0) {
        hud.label.text = labelText;
    }
    hud.label.numberOfLines = 0;
    hud.label.textColor = [UIColor whiteColor];
    hud.completionBlock = nil;
    hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [UIColor clearColor];
    [onView addSubview:hud];
    [hud showAnimated:YES];
}
void SuccessMBProgressHUD(UIView *onView, NSString *labelText)
{
    if (IsStringEmptyOrNull(labelText)) {
        FinishMBProgressHUD(onView);
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD HUDForView:onView];
    if (hud == nil) {
        return;
    }
    UIView *view = hud.customView;
    if (view && [view isKindOfClass:[UIImageView class]]) {
        UIImageView *imgView = (UIImageView *)view;
        [imgView stopAnimating];
    }
    
    hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    hud.label.textColor = [UIColor whiteColor];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success"]];
    hud.square = YES;
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = labelText;
    hud.label.numberOfLines = 0;
    hud.label.textColor = [UIColor whiteColor];
    hud.completionBlock = nil;
    [onView addSubview:hud];
    [onView bringSubviewToFront:hud];
    [hud hideAnimated:YES afterDelay:1.0];
}

void LongTimeSuccessMBProgressHUD(UIView *onView, NSString *labelText)
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:onView];
    if (hud == nil) {
        return;
    }
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"black_tips_ok.png"]];
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text=nil;
    hud.label.font=[UIFont systemFontOfSize:16.0f];
    hud.label.numberOfLines = 0;
    hud.detailsLabel.text = labelText;
    hud.completionBlock = nil;
    [onView addSubview:hud];
    [onView bringSubviewToFront:hud];
    [hud hideAnimated:YES afterDelay:2.5];
}

void FailedMBProgressHUD(UIView *onView, NSString *labelText)
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:onView];
    if (hud == nil) {
        return;
    }
    if (!labelText || labelText.length==0) {
        FinishMBProgressHUD(onView);
        return;
    }
    UIView *view = hud.customView;
    if (view && [view isKindOfClass:[UIImageView class]]) {
        UIImageView *imgView = (UIImageView *)view;
        [imgView stopAnimating];
    }
    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    hud.label.textColor = [UIColor whiteColor];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"black_tips_error.png"]];
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = labelText;
    hud.label.numberOfLines = 0;
    hud.label.textColor = [UIColor whiteColor];
    hud.completionBlock = nil;
    [onView addSubview:hud];
    [onView bringSubviewToFront:hud];
    [hud hideAnimated:YES afterDelay:2.5];
}
void FinishMBProgressHUD(UIView *onView)
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:onView];
    if (hud == nil) {
        return;
    }
    
    UIView *view = hud.customView;
    if (view && [view isKindOfClass:[UIImageView class]]) {
        UIImageView *imgView = (UIImageView *)view;
        [imgView stopAnimating];
    }
    [hud hideAnimated:YES];
}

#pragma mark -时间函数
NSString *timeShortDesc(double localAddTime)
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps;
    
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:localAddTime];
    
    // 年月日获得
    comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSCalendarUnitWeekOfYear)
                        fromDate:timeDate];
    
    NSInteger year0 = [comps year];
    NSInteger day0 = [comps day];
    NSInteger weak0 = [comps weekOfYear];
    NSInteger month0=[comps month];
    
    comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSCalendarUnitWeekOfYear)
                        fromDate:[NSDate date]];
    
    NSInteger year1 = [comps year];
    NSInteger day1 = [comps day];
    NSInteger weak1 = [comps weekOfYear];
    NSInteger month1=[comps month];
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    if (year1 > year0)
    {
        [dateformatter setDateFormat:@"yyyy-MM-dd"];
        return [dateformatter stringFromDate:timeDate];
    }
    if(month1 > month0)
    {
        [dateformatter setDateFormat:@"MM-dd"];
        return [dateformatter stringFromDate:timeDate];
    }
    NSUInteger day = day1 - day0;
    if (day == 0)
    {
        [dateformatter setDateFormat:@"HH:mm"];
        return [dateformatter stringFromDate:timeDate];
    }
    
    if (day == 1)
    {
        [dateformatter setDateFormat:@"HH:mm"];
//        return [NSString stringWithFormat:@"昨天 %@",[dateformatter stringFromDate:timeDate]];
        return @"昨天";
    }
    if (day == 2)
    {
        [dateformatter setDateFormat:@"HH:mm"];
//        return [NSString stringWithFormat:@"前天 %@",[dateformatter stringFromDate:timeDate]];
        return @"前天";
    }
    
    //本周
    if (weak0 == weak1) {
        [dateformatter setDateFormat:@"EEEE"];
        return [dateformatter stringFromDate:timeDate];
    }
    
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    return [dateformatter stringFromDate:timeDate];
}

NSString *timeShortDescForTBK(double localAddTime)
{
    NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
    if (localAddTime/nowTimeInterval > 100) {
        localAddTime = localAddTime/1000;
    }
    
    if (localAddTime>nowTimeInterval-60) {
        return @"刚刚";
    } else if (localAddTime > (nowTimeInterval - 60*60)) {
        return [NSString stringWithFormat:@"%d分钟前",(int)((nowTimeInterval-localAddTime)/60)];
    } else if (localAddTime > (nowTimeInterval - 60*60*24)){
        return [NSString stringWithFormat:@"%d小时前",(int)((nowTimeInterval-localAddTime)/3600)];
    } else if (localAddTime > (nowTimeInterval - 60*60*24*30)) {
        return [NSString stringWithFormat:@"%d天前",(int)((nowTimeInterval-localAddTime)/(3600 * 24))];
    } else if (localAddTime > (nowTimeInterval - 60*60*24*30*12)) {
        return [NSString stringWithFormat:@"%d月前",(int)((nowTimeInterval-localAddTime)/(3600 * 24*30))];
    } else {
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        dateformatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
            [dateformatter setDateFormat:@"yyyy-MM-dd"];
        return [dateformatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:localAddTime]];
    }
}


extern BOOL CompareStr(NSString *str1,NSString *str2)
{
    if ([str1 compare:str2] == NSOrderedAscending) {
        return YES;
    }
    else {
        return NO;
    }
    
}

NSTimeInterval TimeIntervalForOrder(NSString *orderTime) {
    if (![orderTime containsString:@" "]) {
        orderTime = [NSString stringWithFormat:@"%@ 00:00:00",orderTime];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:orderTime];
    return [[NSDate date] timeIntervalSinceDate:date];
}

void ShowLogin(UIViewController *vc) {
    if (vc) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LoginViewController *login = [[LoginViewController alloc] init];
            [vc presentViewController:[[RJNavigationController alloc] initWithRootViewController:login] animated:YES completion:nil];
        });
    }
}

BOOL NetworkState(UIView *view) {
    if ([RJNetworkManager sharedInstace].isConnectNetwork) {
        return YES;
    } else {
        ShowAutoHideMBProgressHUD(view, @"网络异常,请检查网络");
        return NO;
    }
}

CGFloat FetchKeyBoardHeight(NSNotification *noti) {
    return [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
}

#pragma mark - 获取url参数
NSDictionary *URLParametersWithURLString(NSString *query){
    
    NSStringEncoding  encoding = NSUTF8StringEncoding;
    
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"?&;"];
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:query];
    while (![scanner isAtEnd]) {
        NSString* pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString* key = [[kvPair objectAtIndex:0]
                             stringByReplacingPercentEscapesUsingEncoding:encoding];
            NSString* value = [[kvPair objectAtIndex:1]
                               stringByReplacingPercentEscapesUsingEncoding:encoding];
            [pairs setObject:value forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
    
}

#pragma mark - character 字符数
NSInteger CountOfCharacter(NSString *string)
{
    int i,count = (int)[string length],chinese = 0,ascii = 0;unichar cha;
    for(i = 0;i < count;i++){
        cha=[string characterAtIndex:i];
        if(isascii(cha)){
            ascii++;
        }else{
            chinese += 2;
        }
    }
    if(ascii == 0 && chinese == 0){
        return 0;
    }
    return chinese+ascii;
}

#pragma mark - 截图
UIImage *imageFrowView(UIView *view, CGRect atFrame) {
    UIGraphicsBeginImageContextWithOptions(view.frame.size,NO,[[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIRectClip(atFrame);
    [view.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return  theImage;
}

UIImage *grayImage(UIImage *sourceImg) {
    int width = sourceImg.size.width;
    int height = sourceImg.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil, width, height,8,0, colorSpace,kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    if (context ==NULL) {
        return nil;
    }
    CGContextDrawImage(context,CGRectMake(0,0, width, height), sourceImg.CGImage);
    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    return grayImage;
}

NSString *timeString(NSTimeInterval teimInterval) {
    unsigned long seconds, h, m, s;
    char buff[128] = { 0 };
    NSString *nsRet = nil;
    
    seconds = (unsigned long)teimInterval+0.5;
    h = seconds / 3600;
    m = (seconds - h * 3600) / 60;
    s = seconds - h * 3600 - m * 60;
    snprintf(buff, sizeof(buff), "%02ld:%02ld:%02ld", h, m, s);
    nsRet = [[NSString alloc] initWithCString:buff
                                     encoding:NSUTF8StringEncoding];
    
    return nsRet;
}

#pragma mark - 时间转换
NSDate * getDateFromString(NSString *time,NSString *formatter)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    NSDate *destDate= [dateFormatter dateFromString:time];
    return destDate;
}
NSString *getStringFromTimeintervalString(NSString *interval,NSString *formatter)
{
    if (!interval) {
        return @"";
    }
    NSTimeInterval timeInterval = [interval doubleValue];
    if (timeInterval<=0 || [interval containsString:@"-"]) {
        if (interval.length > formatter.length) {
            return [interval substringToIndex:formatter.length];
        }
        return interval;
    }
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970] * 100;
    if (timeInterval>now) {
        timeInterval = timeInterval/1000;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    return getStringFromDate(date, formatter);
}
NSString *getStringFromDate(NSDate *date,NSString *formatter)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    NSString *string = [dateFormatter stringFromDate:date];
    return string;
}

#pragma mark - 拨打电话
void makePhoneCall(NSString *mobile) {
    if (!IsStringEmptyOrNull(mobile)) {
        NSMutableString *str=[[NSMutableString alloc] initWithFormat:@"tel:%@",mobile];
        UIWebView *callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [KKeyWindow addSubview:callWebview];
    }
}






