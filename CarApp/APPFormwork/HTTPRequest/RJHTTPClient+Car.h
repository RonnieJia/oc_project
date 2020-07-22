//
#import "RJHTTPClient.h"

NS_ASSUME_NONNULL_BEGIN
@interface RJHTTPClient (Car)

/**
 店铺资料
 */
- (NSURLSessionDataTask *)fetchShopInfoCompletion:(HTTPCompletion)completion;

/// 获取城市
- (NSURLSessionDataTask *)fetchCityInfoCompletion:(HTTPCompletion)completion;

/// 编辑店铺资料
/// @param icon 头像
/// @param name 店铺名
/// @param address 地址
/// @param city 城市id
/// @param phone 电话
/// @param range 范围
/// @param bg 背景图
/// @param dem 风采
/// @param content 简介
- (NSURLSessionDataTask *)editShop:(NSString *)icon name:(NSString *)name address:(NSString *)address city:(NSString *)city phone:(NSString *)phone range:(NSString *)range backgroun:(NSString *)bg demeanor:(NSString *)dem content:(NSString *)content lat:(CGFloat)lat lon:(CGFloat)lon phone2:(NSString *)p2 completion:(HTTPCompletion)completion;

/// 我的钱包
- (NSURLSessionDataTask *)fetchMyWalletCompletion:(HTTPCompletion)completion;

/// 是否绑定支付宝
- (NSURLSessionDataTask *)isBindZFBCompletion:(HTTPCompletion)completion;

/// 绑定支付宝
/// @param name 用户名
/// @param num 账号
- (NSURLSessionDataTask *)bindZFB:(NSString *)name num:(NSString *)num completion:(HTTPCompletion)completion;

/// 提现
/// @param money 钱数
- (NSURLSessionDataTask *)cashMoney:(NSString *)money completion:(HTTPCompletion)completion;

/// 资金明细
/// @param type 1-提现 2-收入
/// @param page 页码
- (NSURLSessionDataTask*)fetchMoneyDetails:(NSInteger)type page:(NSInteger)page completion:(HTTPCompletion)completion;

/// 是否开启救援
/// @param open 是否开启
- (NSURLSessionDataTask *)openRescue:(BOOL)open completion:(HTTPCompletion)completion;

/// 是否接单该救援
/// @param rescue_id 救援id
/// @param receipt 是否接受
- (NSURLSessionDataTask *)rescue:(NSString *)rescue_id receipt:(BOOL)receipt completion:(HTTPCompletion)completion;

/// 救援记录
/// @param state 订单状态 0待接单 1已接单 2已完成 3已拒绝
/// @param page 页码
- (NSURLSessionDataTask *)fetchRescue:(NSInteger)state page:(NSInteger)page completion:(HTTPCompletion)completion;
- (void)fetchAllStateRescueCompletion:(HTTPCompletion)completion;
/// 救援订单详情
/// @param r_id 救援记录id
- (NSURLSessionDataTask *)fetchRescueDetail:(NSString *)r_id completion:(HTTPCompletion)completion;

/// 救援编辑订单
/// @param r_id id
/// @param pmoney 配件费
/// @param tMoney 工时费
- (NSURLSessionDataTask *)rescueEdit:(NSString *)r_id pmoney:(NSString *)pmoney time:(NSString *)tMoney completion:(HTTPCompletion)completion;

/// 救援订单拒绝
/// @param r_id 九原订单id
- (NSURLSessionDataTask *)rescueRefuse:(NSString *)r_id completion:(HTTPCompletion)completion;

/// 救援维修完成
/// @param r_id 救援id
- (NSURLSessionDataTask *)rescueComplete:(NSString *)r_id completion:(HTTPCompletion)completion;

/// 救援删除
/// @param rid 订单id
- (NSURLSessionDataTask *)deleteRescue:(NSString *)rid completion:(HTTPCompletion)completion;
/// 预约记录
/// @param page 页码
/// @param state 0待接单 1已接单 2已拒绝
- (NSURLSessionDataTask *)fetchReservationList:(NSInteger)page state:(NSInteger)state completion:(HTTPCompletion)completion;

/// 预约详情
/// @param r_id 预约id
- (NSURLSessionDataTask *)fetchReservationDetail:(NSString *)r_id completion:(HTTPCompletion)completion;

/// 预约订单----接单、拒绝
/// @param rid 订单id
/// @param receipt 1-接受
- (NSURLSessionDataTask *)reservation:(NSString *)rid receipt:(BOOL)receipt completion:(HTTPCompletion)completion;

/// 预约订单删除
/// @param rid 订单id
- (NSURLSessionDataTask *)deleteReservation:(NSString *)rid completion:(HTTPCompletion)completion;

///  维修订单
/// @param page 页码
/// @param state 1待维修 2维修中 3已完成 4已取消
- (NSURLSessionDataTask *)fetchFixList:(NSInteger)page state:(NSInteger)state completion:(HTTPCompletion)completion;

/// 维修订单详情
/// @param fid 维修订单id
- (NSURLSessionDataTask *)fetchFixInfo:(NSString *)fid completion:(HTTPCompletion)completion;

/// 维修订单报价
/// @param rid 维修订单id
/// @param pMoney 配件金额
/// @param hMoney 工时费
/// @param remark 备注
- (NSURLSessionDataTask *)fixOffer:(NSString *)rid pMoney:(NSString *)pMoney hMoney:(NSString *)hMoney remark:(NSString *)remark completion:(HTTPCompletion)completion;

/// 维修订单完成
/// @param rid 订单id
- (NSURLSessionDataTask *)fixComplete:(NSString *)rid completion:(HTTPCompletion)completion;

/// 维修信息
- (NSURLSessionDataTask *)fetchFixInfo2:(NSString *)rid completion:(HTTPCompletion)completion;

/// 取消维修订单删除
- (NSURLSessionDataTask *)deleteFixOrder:(NSString *)oid completion:(HTTPCompletion)completion;

/// 报修记录
/// @param page 页码
/// @param state 1待维修 2维修中 3已完成 4已取消 5不认可
- (NSURLSessionDataTask *)fetchRepairList:(NSInteger)page state:(NSInteger)state
                               completion:(HTTPCompletion)completion;

/// 报修订单详情
/// @param rid order id
- (NSURLSessionDataTask *)fetchRepairInfo:(NSString *)rid completion:(HTTPCompletion)completion;

/// 报修订单报价
/// @param rid 订单id
/// @param pMon 配件费
/// @param hMon 工时费
/// @param remark 备注
- (NSURLSessionDataTask *)repairOffer:(NSString *)rid pMoney:(NSString *)pMon hMoney:(NSString *)hMon remark:(NSString *)remark completion:(HTTPCompletion)completion;

/// 报修订单不认可
/// @param rid 订单id
/// @param reason 原因
- (NSURLSessionDataTask *)repairRefund:(NSString *)rid reason:(NSString *)reason completion:(HTTPCompletion)completion;

/// 报修订单完成
/// @param rid 订单id
- (NSURLSessionDataTask *)repairComplete:(NSString *)rid completion:(HTTPCompletion)completion;

/// 报修订单删除
/// @param fid 订单id
- (NSURLSessionDataTask *)deleteRepair:(NSString *)fid completion:(HTTPCompletion)completion;

/// 报修订单提交到平台
/// @param reid 订单id
- (NSURLSessionDataTask *)repairSubmitAdmin:(NSString *)reid completion:(HTTPCompletion)completion;

/// 车辆详情
/// @param car_id 车id
- (NSURLSessionDataTask *)fetchCarInfo:(NSString *)car_id completion:(HTTPCompletion)completion;

/// 修理订单取消
/// @param oid 订单id
/// type 0-维修  1-报修
/// @param title 取消原因
/// @param content 原因简述
- (NSURLSessionDataTask *)cancelRepairOrder:(NSString *)oid type:(NSInteger)type title:(NSString *)title content:(NSString *)content completion:(HTTPCompletion)completion;


/// 配件商城
/// @param page 页码
- (NSURLSessionDataTask *)fetchShop:(NSInteger)page completion:(HTTPCompletion)completion;

/// 商品分类
- (NSURLSessionDataTask *)fetchGoodsCategoryCompletion:(HTTPCompletion)completion;

/// 商品搜索热门关键词
- (NSURLSessionDataTask *)fetchSearchHotCompletion:(HTTPCompletion)compleiton;

/// 商品列表
/// @param cate_id 分类id
/// @param page 页码
/// @param overall 传1 综合排序
/// @param price 价格排序 1正序 2倒序
- (NSURLSessionDataTask *)fetchGoodsList:(NSString *)cate_id page:(NSInteger)page overall:(BOOL)overall price:(BOOL)price compeltion:(HTTPCompletion)completion;
- (NSURLSessionDataTask *)fetchGoodsList:(NSInteger)page cate:(NSString *)cate_id all:(BOOL)all sort:(NSInteger)sort goodsName:(NSString *)name completion:(HTTPCompletion)completion;

/// 商品详情
/// @param g_id 商品id
- (NSURLSessionDataTask *)fetchGoodsDetail:(NSString *)g_id completion:(HTTPCompletion)completion;

/// 收藏商品
/// @param g_id 商品id
/// @param type yes-收藏 NO-cancel
- (NSURLSessionDataTask *)collectionGoods:(NSString *)g_id type:(BOOL)type completion:(HTTPCompletion)completion;

/// 我的收藏
/// @param page 页码
- (NSURLSessionDataTask *)fetchCollctionList:(NSInteger)page completion:(HTTPCompletion)completion;

/// 加入购物车
/// @param g_id 商品id
/// @param sku 规格id
/// @param num 数量
- (NSURLSessionDataTask *)addCart:(NSString *)g_id sku:(NSString *)sku num:(NSInteger)num completion:(HTTPCompletion)completion;

/// 购物车
- (NSURLSessionDataTask *)fetchCartCompletion:(HTTPCompletion)completion;

/// 购物车数量变化
/// @param cart_id id
/// @param num 数量
- (NSURLSessionDataTask *)cartGoods:(NSString *)cart_id num:(NSInteger)num completion:(HTTPCompletion)completion;

/// 购物车删除
/// @param cart_id sid
- (NSURLSessionDataTask *)deleteCartGoods:(NSString *)cart_id completion:(HTTPCompletion)completion;

/// 地址列表
- (NSURLSessionDataTask *)fetchAddressListCompletion:(HTTPCompletion)completion;

/// 删除收货地址
/// @param aid 地址id
- (NSURLSessionDataTask *)deleAddress:(NSString *)aid completion:(HTTPCompletion)compleiton;

/// 编辑地址
/// @param name 姓名
/// @param mobile 手机
/// @param pid 省
/// @param cid 市
/// @param address 详细地址
/// @param isdef 是否默认
/// @param aid 修改地址 地址id
- (NSURLSessionDataTask *)editAddress:(NSString *)name mobile:(NSString *)mobile province:(NSString *)pid city:(NSString *)cid address:(NSString *)address defau:(BOOL)isdef addresID:(NSString *)aid completion:(HTTPCompletion)completion;

/// 地址详情
/// @param a_id 地址id
- (NSURLSessionDataTask *)fetchAddressDetail:(NSString *)a_id completion:(HTTPCompletion)completion;

/// 结算-订单详情
/// @param cart 购物车id
- (NSURLSessionDataTask *)fetchPayOrderInfo:(NSString *)cart completion:(HTTPCompletion)completion;

/// 购物车订单支付
/// @param cart 购物车id
/// @param payType 支付类型1支付宝 2微信
/// @param aid 地址id
- (NSURLSessionDataTask *)payCartOrder:(NSString *)cart paytype:(NSInteger)payType address:(NSString *)aid message:(NSString *)msg completion:(HTTPCompletion)completion;

/// 立即购买订单支付
/// @param goods 商品id
/// @param sku skuid
/// @param num 数量
/// @param payType 支付类型1支付宝 2微信
/// @param aid 地址id
- (NSURLSessionDataTask *)payBuyNowOrder:(NSString *)goods sku:(NSString *)sku num:(NSInteger)num paytype:(NSInteger)payType address:(NSString *)aid message:(NSString *)msg completion:(HTTPCompletion)completion;


/// 商城订单列表
/// @param type 分类 1未付款 2已付款 3配送中 4已完成 5退款
/// @param page 页
- (NSURLSessionDataTask *)fetchShopOrderList:(NSInteger)type page:(NSInteger)page completion:(HTTPCompletion)completion;

/// 商城订单详情
/// @param order_id 订单id
- (NSURLSessionDataTask *)fetchShopOrderDetail:(NSString *)order_id completion:(HTTPCompletion)completion;

/// 商城订单删除
/// @param order_id 订单id
- (NSURLSessionDataTask *)deleteShopOrder:(NSString *)order_id completion:(HTTPCompletion)completion;

/// 重新支付
/// @param order_id 订单id
/// @param money j金额
/// @param type 支付分类 1支付宝 2微信
- (NSURLSessionDataTask *)payOrderAgain:(NSString *)order_id money:(NSString *)money type:(NSInteger)type completion:(HTTPCompletion)completion;

/// 退款分类列表 / 取消订单分类列表
/// @param type 分类1取消订单分类 2退款分类
- (NSURLSessionDataTask *)fetchRefundReason:(NSInteger)type completion:(HTTPCompletion)completion;

/// 退款提交
/// @param order_id 订单id
/// @param title 退款标题
- (NSURLSessionDataTask *)orderRefundMoney:(NSString *)order_id title:(NSString *)title content:(NSString *)content completion:(HTTPCompletion)completion;

/// 确认收货
/// @param order_id 订单id
- (NSURLSessionDataTask *)orderReceived:(NSString *)order_id completion:(HTTPCompletion)completion;

/// 获取省列表
- (NSURLSessionDataTask *)fetchProvinceListCompletion:(HTTPCompletion)completion;

/// 市列表
/// @param pid 省id
- (NSURLSessionDataTask *)fetchCityList:(NSString *)pid completion:(HTTPCompletion)completion;

/// 系统消息
/// @param page 页码
/// @param state 1订单消息 2系统消息 不传该参数为全部消息
- (NSURLSessionDataTask *)fetchSystemMessage:(NSInteger)page state:(NSInteger)state completion:(HTTPCompletion)completion;

/// 系统消息q详情
/// @param mid 消息id
- (NSURLSessionDataTask *)fetchMessageDetail:(NSString *)mid completion:(HTTPCompletion)completion;

/// 删除系统消息
- (NSURLSessionDataTask *)deleteSystemMessage:(NSString *)mid completion:(HTTPCompletion)compleiton;

/// 未读消息数+最新一条消息
- (NSURLSessionDataTask *)fetchSystemMsgInfoCompletion:(HTTPCompletion)completion;
@end

NS_ASSUME_NONNULL_END
