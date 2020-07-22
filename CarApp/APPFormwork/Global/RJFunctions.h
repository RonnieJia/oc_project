//
//  RJFunctions.h
//  APPFormwork

#ifndef RJFunctions_h
#define RJFunctions_h

#if defined __cplusplus
extern "C" {
#endif
    
#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
    
    //
#define SafeNumToBool(x) ((x == nil) ? NO : (([x intValue] == 1) ? YES: NO))
#define SafeNumToFloat(x) ((x == nil) ? 0.0 : [x floatValue])
#define SafeNumToInt(x) ((x == nil) ? 0 : [x intValue])
    //#define     BYTE            uint8_t
    //#define     U2              uint16_t
    //#define     U4              uint32_t
    //#define     U8              uint64_t
    //
    //    //变长数据定义
    //#pragma  pack(1)
    //    typedef struct
    //    {
    //        U2      len;
    //        void*   data;
    //    }LV,*PLV;
    //#pragma  pack()
    //#define LV_DATA(plv) ((char* )&plv->data)
    //#define NEXT_LV(plv) ((PLV)((char* )plv + 2 + ntohs(plv->len)))
    
    
#pragma mark - for 康家来
    extern BOOL TimeAfterNow(NSTimeInterval time);
    extern NSArray* TimeTransToHMS(NSTimeInterval time);
    
    
#pragma mark - JSON
    //将键-值对加入字典。会剔除object或key或dic为nil的情况
    extern void AddObjectForKeyIntoDictionary(id object, id key, NSMutableDictionary *dic);
    
    //从反JSON序列化后的字典里面读取Key对应的对象。 如果对象为NSString对象并且是@"", 会返回nil
    extern id ObjForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key);
    
    //从反JSON序列化后的字典里面读取Key对应的String,不是String的数据则进行转换
    extern NSString* StringForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key);
    
    //从反JSON序列化后的字典里面读取Key对应的CGFloat,不是CGFloat的数据则进行转换
    extern CGFloat FloatForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key);
    
    //从反JSON序列化后的字典里面读取Key对应的double,不是double的数据则进行转换
    extern double DoubleForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key);
    
    //从反JSON序列化后的字典里面读取Key对应的NSInteger,不是NSInteger的数据则进行转换
    extern NSInteger IntForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key);
    
    //从反JSON序列化后的字典里面读取Key对应的Boolean,不是Boolean的数据则进行转换
    extern Boolean BoolForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key);
    
    //从反JSON序列化后的字典里面读取Key对应的Uint64 ,不是Uint64的数据则进行转换
    extern UInt64 BigIntForKeyInUnserializedJSONDic(NSDictionary *unserializedJSONDic, id key);

#pragma mark html字符串处理
    extern NSString *htmlString(NSString *string);
    
#pragma mark DES加密解密
    extern NSString *DESEncrypt(NSString *string);
    extern NSString *DESDecrypt(NSString *string);
    
#pragma mark -MD5加密
    extern NSString* EncryptPassword(NSString *str);
    
#pragma mark -判断是否为空
    extern Boolean IsStringEmptyOrNull(NSString * str);
    
#pragma mark - 保存用户的账号密码
    extern void UserDefaultSaveBool(NSString *key, BOOL value);
    extern BOOL UserDefaultBoolForKey(NSString *key);
    extern void UserDefaultSaveObj(NSString *key, id obj);
    extern id UserDefaultObjForKey(NSString *key);
    
    // 用户账号信息
    extern void SaveUser(NSString *uName, NSString *pwd, NSString *uid);
    extern void SaveUserToken(NSString *uid, NSString *token, NSString *refreshToken);
    extern void SaveUserInfo(NSDictionary *dict);
    extern void ClearUser();
    extern BOOL IsSaveUser();
    extern NSString *GetUserName();
    extern NSString *GetUserPwd();
    extern NSString *GetUserId();
    extern NSString *GetUserToken();
    extern NSString *GetUserReToken();
    extern NSDictionary *GetUserInfo();
    
    // 用户位置
    extern void SaveUserCity(NSString *city_name, NSString *city_id);
    extern NSDictionary *GetUserCityInfo();
    extern void SaveUserLocation(NSString *lat, NSString *lon, NSString *city);
    extern NSString *GetUserLatitude();
    extern NSString *GetUserLongtude();
    extern NSString *GetUserCity();
    
#pragma mark -时间函数
    extern NSString *timeShortDesc(double localAddTime);
    extern NSString *timeShortDescForTBK(double localAddTime);
#pragma mark - 时间转换
    extern NSDate * getDateFromString(NSString *time,NSString *formatter);
    extern NSString *getStringFromTimeintervalString(NSString *interval,NSString *formatter);
    extern NSString *getStringFromDate(NSDate *date,NSString *formatter);
#pragma mark - 是否是数字
    extern Boolean IsNumber(NSString *str);
#pragma mark -是否为手机号
    extern Boolean IsNormalMobileNum(NSString  *userMobileNum);
    
#pragma mark - 进行数据录入错误提示
    /** 输入错误提示
     
     *@param errorString *errorString 错误提示信息
     *@See 返回一个对话框，且无标题，仅有错误提示内容和一个确定操作按键
     **/
    extern void ShowImportErrorAlertView(NSString *errorString);
    
#pragma mark -MBProgressHUD
    extern void ShowAutoHideMBProgressHUD(UIView *onView, NSString *labelText);
    extern void ShowIMAutoHideMBProgressHUD(UIView *onView, NSString *labelText);
    extern void ShowAutoHideMBProgressHUDWithOneSec(UIView *onView, NSString *labelText);
    extern void WaittingMBProgressHUD(UIView *onView, NSString *labelText);
    extern void SuccessMBProgressHUD(UIView *onView, NSString *labelText);
    extern void LongTimeSuccessMBProgressHUD(UIView *onView, NSString *labelText);
    extern void FailedMBProgressHUD(UIView *onView, NSString *labelText);
    extern void FinishMBProgressHUD(UIView *onView);
    
#pragma mark -Image TOOL
    extern UIImage* createImageWithColor(UIColor *color);
    extern UIColor* colorAddAlpha(UIColor* color,CGFloat alpha);
    
#pragma mark - 获取url参数
    extern NSDictionary *URLParametersWithURLString(NSString *query);
    
#pragma mark - character 字符数
    extern NSInteger CountOfCharacter(NSString *string);
    
#pragma mark - 截图
    extern UIImage *imageFrowView(UIView *view, CGRect atFrame);
    // 生成黑白图片
    extern UIImage *grayImage(UIImage *sourceImg);
    
#pragma mark 将时间戳卓换成倒计时
    extern NSString *timeString(NSTimeInterval teimInterval);
    
#pragma mark 拨打电话
    extern void makePhoneCall(NSString *mobile);
    
#pragma mark -比较两个字符串
    extern BOOL CompareStr(NSString *str1,NSString *str2);
    
    extern NSTimeInterval TimeIntervalForOrder(NSString *orderTime);
    

    extern void ShowLogin(UIViewController *vc);
    
    extern BOOL NetworkState(UIView *view);
#pragma mark -键盘通知获取高度
    extern CGFloat FetchKeyBoardHeight(NSNotification *noti);
    
    
#if defined __cplusplus
};
#endif


#endif



