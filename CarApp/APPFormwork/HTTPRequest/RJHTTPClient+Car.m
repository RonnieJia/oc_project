//

#import "RJHTTPClient+Car.h"
#import "RescueModel.h"
#import "CityDataManager.h"
#import "CurrentUserInfo.h"
#import "UserLocation.h"

@implementation RJHTTPClient (Car)
- (NSURLSessionDataTask *)fetchShopInfoCompletion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    return [self postPath:@"repair/shop_information" paramters:paramters completion:completion];
}
- (NSURLSessionDataTask *)fetchCityInfoCompletion:(HTTPCompletion)completion {
    return [self getPath:@"index/city_info" paramters:nil completion:completion];
}

- (NSURLSessionDataTask *)editShop:(NSString *)icon name:(NSString *)name address:(NSString *)address city:(NSString *)city phone:(NSString *)phone range:(NSString *)range backgroun:(NSString *)bg demeanor:(NSString *)dem content:(NSString *)content lat:(CGFloat)lat lon:(CGFloat)lon phone2:(NSString *)p2 completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    [paramters setObject:icon?:@"" forKey:@"photo"];
    [paramters setObject:name?:@"" forKey:@"name"];
    [paramters setObject:address?:@"" forKey:@"address"];
    [paramters setObject:phone?:@"" forKey:@"phone"];
    [paramters setObject:range?:@"" forKey:@"range"];
    [paramters setObject:bg?:@"" forKey:@"background_picture"];
    [paramters setObject:dem?:@"" forKey:@"demeanor"];
    [paramters setObject:content?:@"" forKey:@"content"];
    [paramters setObject:city?:@"" forKey:@"city_id"];
    AddObjectForKeyIntoDictionary(p2, @"spare_phone", paramters);
    if (lat==0 || lon == 0) {
        [paramters setObject:[UserLocation sharedInstance].userLatitude?:@"" forKey:@"lat"];
        [paramters setObject:[UserLocation sharedInstance].userLongitude?:@"" forKey:@"lng"];
    } else {
        [paramters setObject:@(lat) forKey:@"lat"];
        [paramters setObject:@(lon) forKey:@"lng"];
    }
    
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    return [self postPath:@"repair/edit_shop" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchMyWalletCompletion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    return [self postPath:@"repair/my_waller" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)isBindZFBCompletion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    return [self postPath:@"repair/is_binding" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)bindZFB:(NSString *)name num:(NSString *)num completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(name, @"name", paramters);
    AddObjectForKeyIntoDictionary(num, @"number", paramters);
    return [self postPath:@"repair/binding" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)cashMoney:(NSString *)money completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(money, @"money", paramters);
    return [self postPath:@"repair/cash" paramters:paramters completion:completion];
}
- (NSURLSessionDataTask*)fetchMoneyDetails:(NSInteger)type page:(NSInteger)page completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(@(type), @"type", paramters);
    AddObjectForKeyIntoDictionary(@(page), @"page", paramters);
    return [self postPath:@"repair/detaileds" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)openRescue:(BOOL)open completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(open?@"1":@"2", @"type", paramters);
    return [self postPath:@"repair/receipt" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)rescue:(NSString *)rescue_id receipt:(BOOL)receipt completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(rescue_id, @"rescue_id", paramters);
    AddObjectForKeyIntoDictionary(receipt?@"1":@"2", @"type", paramters);
    return [self postPath:@"repair/rescue_receipt" paramters:paramters completion:completion];
}

- (void)fetchAllStateRescueCompletion:(HTTPCompletion)completion {
    dispatch_group_t group = dispatch_group_create();
    __block NSMutableDictionary *data = [NSMutableDictionary dictionary];
    for (NSInteger i = 0; i<4; i++) {
        dispatch_group_enter(group);
        [self fetchRescue:i page:kPageStartIndex completion:^(WebResponse *response) {
            if (response.responseObject) {
                [data setObject:response.responseObject forKey:@(i)];
            }
            dispatch_group_leave(group);
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        WebResponse *resp= [[WebResponse alloc] init];
        resp.code = WebResponseCodeSuccess;
        resp.responseObject = data;
        if (completion) {
            completion(resp);
        }
    });
}


- (NSURLSessionDataTask *)fetchRescue:(NSInteger)state page:(NSInteger)page completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(@(state), @"state", paramters);
    AddObjectForKeyIntoDictionary(@(page), @"page", paramters);
    return [self postPath:@"repair/rescue_record" paramters:paramters completion:completion];
}
- (NSURLSessionDataTask *)fetchRescueDetail:(NSString *)r_id completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(r_id, @"r_id", paramters);
    return [self postPath:@"repair/rescue_details" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)rescueEdit:(NSString *)r_id pmoney:(NSString *)pmoney time:(NSString *)tMoney completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(r_id, @"r_id", paramters);
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"repair_id", paramters);
    AddObjectForKeyIntoDictionary(pmoney, @"pmoney", paramters);
    AddObjectForKeyIntoDictionary(tMoney, @"wmoney", paramters);
    return [self postPath:@"repair/edit_order" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)rescueRefuse:(NSString *)r_id completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(r_id, @"rescue_id", paramters);
    return [self postPath:@"repair/rescue_refuse" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)rescueComplete:(NSString *)r_id completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"repair_id", paramters);
    AddObjectForKeyIntoDictionary(r_id, @"rescue_id", paramters);
    return [self postPath:@"repair/rescue_completed" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)deleteRescue:(NSString *)rid completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(rid, @"id", paramters);
    AddObjectForKeyIntoDictionary(@"2", @"type", paramters);
    return [self postPath:@"index/del" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchReservationList:(NSInteger)page state:(NSInteger)state completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"id", paramters);
    AddObjectForKeyIntoDictionary(@(page), @"page", paramters);
    AddObjectForKeyIntoDictionary(@(state), @"state", paramters);
    return [self postPath:@"repair/appointment_record" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchReservationDetail:(NSString *)r_id completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(r_id, @"id", paramters);
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    return [self postPath:@"repair/appointment_details" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)reservation:(NSString *)rid receipt:(BOOL)receipt completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(rid, @"id", paramters);
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(receipt?@"1":@"2", @"type", paramters);
    return [self postPath:@"repair/is_booking" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)deleteReservation:(NSString *)rid completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(rid, @"id", paramters);
    AddObjectForKeyIntoDictionary(@"1", @"type", paramters);
    return [self postPath:@"index/del" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchFixList:(NSInteger)page state:(NSInteger)state completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(@(page), @"page", paramters);
    AddObjectForKeyIntoDictionary(@(state), @"type", paramters);
    return [self postPath:@"repair/repair_order" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchFixInfo:(NSString *)fid completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(fid, @"order_rid", paramters);
    return [self postPath:@"repair/repair_info" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fixOffer:(NSString *)rid pMoney:(NSString *)pMoney hMoney:(NSString *)hMoney remark:(NSString *)remark completion:(HTTPCompletion)completion {
    
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(rid, @"order_rid", paramters);
    AddObjectForKeyIntoDictionary(pMoney, @"parts_price", paramters);
    AddObjectForKeyIntoDictionary(hMoney, @"hours_price", paramters);
    AddObjectForKeyIntoDictionary(remark, @"remarks", paramters);
    return [self postPath:@"repair/repair_offer" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fixComplete:(NSString *)rid completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
//    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(rid, @"order_rid", paramters);
    return [self postPath:@"repair/repair_complete" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchFixInfo2:(NSString *)rid completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    //    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(rid, @"order_rid", paramters);
    return [self postPath:@"repair/repair_data" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)deleteFixOrder:(NSString *)oid completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    //    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(oid, @"order_rid", paramters);
    return [self postPath:@"index/repair_del" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchRepairList:(NSInteger)page state:(NSInteger)state completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"repair_id", paramters);
    AddObjectForKeyIntoDictionary(@(page), @"page", paramters);
    AddObjectForKeyIntoDictionary(@(state), @"type", paramters);
    return [self postPath:@"repair/onerepair_list" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchRepairInfo:(NSString *)rid completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
//    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"repair_id", paramters);
    AddObjectForKeyIntoDictionary(rid, @"re_id", paramters);
    return [self postPath:@"repair/onerepair_info" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)repairOffer:(NSString *)rid pMoney:(NSString *)pMon hMoney:(NSString *)hMon remark:(NSString *)remark completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"repair_id", paramters);
    AddObjectForKeyIntoDictionary(rid, @"re_id", paramters);
    AddObjectForKeyIntoDictionary(pMon, @"parts_money", paramters);
    AddObjectForKeyIntoDictionary(hMon, @"working_money", paramters);
    AddObjectForKeyIntoDictionary(remark, @"order_remarks", paramters);
    return [self postPath:@"repair/onerepair_offer" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)repairRefund:(NSString *)rid reason:(NSString *)reason completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
        AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"repair_id", paramters);
        AddObjectForKeyIntoDictionary(rid, @"re_id", paramters);
        AddObjectForKeyIntoDictionary(reason, @"repair_reason", paramters);
        return [self postPath:@"repair/not_recognized" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)repairComplete:(NSString *)rid completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"repair_id", paramters);
    AddObjectForKeyIntoDictionary(rid, @"re_id", paramters);
    return [self postPath:@"repair/onerepair_complete" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)deleteRepair:(NSString *)fid completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(fid, @"re_id", paramters);
    return [self postPath:@"index/onerepair_del" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)repairSubmitAdmin:(NSString *)reid completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"repair_id", paramters);
    AddObjectForKeyIntoDictionary(reid, @"re_id", paramters);
    return [self postPath:@"repair/submit_admin" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchCarInfo:(NSString *)car_id completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(car_id, @"vehicle_id", paramters);
    return [self postPath:@"repair/car_info" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)cancelRepairOrder:(NSString *)oid type:(NSInteger)type title:(NSString *)title content:(NSString *)content completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"repair_id", paramters);
    if (type==0) {// 维修
        AddObjectForKeyIntoDictionary(oid, @"order_rid", paramters);
        AddObjectForKeyIntoDictionary(@(2), @"type", paramters);
    } else if(type==1) {//报修
        AddObjectForKeyIntoDictionary(oid, @"re_id", paramters);
    }
    
    AddObjectForKeyIntoDictionary(title, @"title", paramters);
    AddObjectForKeyIntoDictionary(content, @"content", paramters);
    return [self postPath:type==0?@"index/cancel_repair":@"repair/cancel_order" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchShop:(NSInteger)page completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(@(page), @"page", paramters);
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    return [self postPath:@"repair/shop" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchGoodsCategoryCompletion:(HTTPCompletion)completion {
    return [self getPath:@"repair/goods_cate" paramters:nil completion:completion];
}

- (NSURLSessionDataTask *)fetchSearchHotCompletion:(HTTPCompletion)compleiton {
    return [self getPath:@"repair/hot_keyword" paramters:nil completion:compleiton];
}

- (NSURLSessionDataTask *)fetchGoodsList:(NSString *)cate_id page:(NSInteger)page overall:(BOOL)overall price:(BOOL)price compeltion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(@(page), @"page", paramters);
    AddObjectForKeyIntoDictionary(cate_id, @"category_id_2", paramters);
    if (overall) {
        AddObjectForKeyIntoDictionary(@"1", @"overall", paramters);
    } else {
        AddObjectForKeyIntoDictionary(price?@"1":@"2", @"price", paramters);
    }
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    return [self postPath:@"repair/goods_list" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchGoodsList:(NSInteger)page cate:(NSString *)cate_id all:(BOOL)all sort:(NSInteger)sort goodsName:(NSString *)name completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(@(page), @"page", paramters);
    AddObjectForKeyIntoDictionary(cate_id, all?@"category_id_1":@"category_id_2", paramters);
    if (sort==0) {
        AddObjectForKeyIntoDictionary(@"1", @"overall", paramters);
    } else if (sort==1) {
        AddObjectForKeyIntoDictionary(@"1", @"price", paramters);
    } else {
        AddObjectForKeyIntoDictionary(@"2", @"price", paramters);
    }
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(name, @"goods_name", paramters);
    return [self postPath:@"repair/goods_list" paramters:paramters completion:completion];
}


- (NSURLSessionDataTask *)fetchGoodsDetail:(NSString *)g_id completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(g_id, @"goods_id", paramters);
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    return [self postPath:@"repair/goods_details" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)collectionGoods:(NSString *)g_id type:(BOOL)type completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(g_id, @"goods_id", paramters);
    AddObjectForKeyIntoDictionary(type?@"1":@"2", @"type", paramters);
    return [self postPath:@"repair/goods_collection" paramters:paramters completion:completion];
}
- (NSURLSessionDataTask *)fetchCollctionList:(NSInteger)page completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(@(page), @"page", paramters);
    return [self postPath:@"repair/my_collection" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)addCart:(NSString *)g_id sku:(NSString *)sku num:(NSInteger)num completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(g_id, @"goods_id", paramters);
    AddObjectForKeyIntoDictionary(sku, @"sku_id", paramters);
    AddObjectForKeyIntoDictionary(@(num), @"num", paramters);
    return [self postPath:@"repair/add_car" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchCartCompletion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    return [self postPath:@"repair/car" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)cartGoods:(NSString *)cart_id num:(NSInteger)num completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(cart_id, @"cart_id", paramters);
    AddObjectForKeyIntoDictionary(@(num), @"num", paramters);
    return [self postPath:@"repair/sum_car" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)deleteCartGoods:(NSString *)cart_id completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(cart_id, @"cart_id", paramters);
    return [self postPath:@"repair/del_cart" paramters:paramters completion:completion];
}
- (NSURLSessionDataTask *)fetchAddressListCompletion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    return [self postPath:@"repair/address_list" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)deleAddress:(NSString *)aid completion:(HTTPCompletion)compleiton {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(aid, @"id", paramters);
    return [self postPath:@"repair/del_address" paramters:paramters completion:compleiton];
}

- (NSURLSessionDataTask *)editAddress:(NSString *)name mobile:(NSString *)mobile province:(NSString *)pid city:(NSString *)cid address:(NSString *)address defau:(BOOL)isdef addresID:(NSString *)aid completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(name, @"name", paramters);
    AddObjectForKeyIntoDictionary(mobile, @"phone", paramters);
    AddObjectForKeyIntoDictionary(pid, @"province_id", paramters);
    AddObjectForKeyIntoDictionary(cid, @"city_id", paramters);
    AddObjectForKeyIntoDictionary(address, @"address", paramters);
    AddObjectForKeyIntoDictionary(isdef?@1:@0, @"is_default", paramters);
    if (aid) {
        AddObjectForKeyIntoDictionary(aid, @"id", paramters);
        return [self postPath:@"repair/edit_address" paramters:paramters completion:completion];
    } else {
        return [self postPath:@"repair/add_address" paramters:paramters completion:completion];
    }
    
}

- (NSURLSessionDataTask *)fetchAddressDetail:(NSString *)a_id completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(a_id, @"id", paramters);
    return [self postPath:@"repair/address_info" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchPayOrderInfo:(NSString *)cart completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(cart, @"cart_id", paramters);
    return [self postPath:@"repair/order_details" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)payCartOrder:(NSString *)cart paytype:(NSInteger)payType address:(NSString *)aid message:(NSString *)msg completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(cart, @"cart_id", paramters);
    AddObjectForKeyIntoDictionary(@(payType), @"payment_type", paramters);
    AddObjectForKeyIntoDictionary(aid, @"address_id", paramters);
    AddObjectForKeyIntoDictionary(msg, @"buyer_message", paramters);
    return [self postPath:@"repair/create_order" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)payBuyNowOrder:(NSString *)goods sku:(NSString *)sku num:(NSInteger)num paytype:(NSInteger)payType address:(NSString *)aid message:(NSString *)msg completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(goods, @"goods_id", paramters);
    AddObjectForKeyIntoDictionary(sku, @"sku_id", paramters);
    AddObjectForKeyIntoDictionary(@(num), @"num", paramters);
    AddObjectForKeyIntoDictionary(@(payType), @"payment_type", paramters);
    AddObjectForKeyIntoDictionary(aid, @"address_id", paramters);
    AddObjectForKeyIntoDictionary(msg, @"buyer_message", paramters);
    return [self postPath:@"repair/create_order" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchShopOrderList:(NSInteger)type page:(NSInteger)page completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(@(page), @"page", paramters);
    AddObjectForKeyIntoDictionary(@(type), @"type", paramters);
    return [self postPath:@"repair/order_list" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchShopOrderDetail:(NSString *)order_id completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(order_id, @"order_id", paramters);
    return [self postPath:@"repair/buy_details" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)deleteShopOrder:(NSString *)order_id completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(order_id, @"id", paramters);
    return [self postPath:@"index/order_del" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)payOrderAgain:(NSString *)order_id money:(NSString *)money type:(NSInteger)type completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(order_id, @"order_id", paramters);
    AddObjectForKeyIntoDictionary(money, @"money", paramters);
    AddObjectForKeyIntoDictionary(@"1", @"type", paramters);
    AddObjectForKeyIntoDictionary(@(type), @"pay_type", paramters);
    return [self postPath:@"repair/payment" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchRefundReason:(NSInteger)type completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(@(type), @"type", paramters);
    return [self postPath:@"repair/refund_type" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)orderRefundMoney:(NSString *)order_id title:(NSString *)title content:(NSString *)content completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(order_id, @"order_id", paramters);
    AddObjectForKeyIntoDictionary(title, @"title", paramters);
    AddObjectForKeyIntoDictionary(content, @"content", paramters);
    return [self postPath:@"repair/refund_add" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)orderReceived:(NSString *)order_id completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"r_id", paramters);
    AddObjectForKeyIntoDictionary(order_id, @"order_id", paramters);
    return [self postPath:@"repair/receiving" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchProvinceListCompletion:(HTTPCompletion)completion {
    return [self getPath:@"repair/province_list" paramters:nil completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            NSArray *arr = [ProvinceModel listWithJSONArray:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"list")];
            [[CityDataManager sharedInstance].provincesArray removeAllObjects];
            [[CityDataManager sharedInstance].provincesArray addObjectsFromArray:arr];
            [CityDataManager sharedInstance].loadProvince = YES;
            ProvinceModel *p = [CityDataManager sharedInstance].provincesArray.firstObject;
            if (p) {
                [p loadCityListCompletion:^(WebResponse *response2) {
                    if (completion) {
                        completion(response);
                    }
                }];
            } else {
                if (completion) {
                    completion(response);
                }
            }
        } else {
            if (completion) {
                completion(response);
            }
        }
    }];
}
- (NSURLSessionDataTask *)fetchCityList:(NSString *)pid completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary(pid, @"provinceid", paramters);
    return [self postPath:@"repair/city_list" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)fetchSystemMessage:(NSInteger)page state:(NSInteger)state completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"id", paramters);
    AddObjectForKeyIntoDictionary(@(page), @"page", paramters);
    AddObjectForKeyIntoDictionary(@(3), @"type", paramters);
    if (state==1||state==2) {
        AddObjectForKeyIntoDictionary(@(state), @"state", paramters);
    }
    return [self postPath:@"index/message_list" paramters:paramters completion:completion];
}
- (NSURLSessionDataTask *)fetchMessageDetail:(NSString *)mid completion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"id", paramters);
    AddObjectForKeyIntoDictionary(mid, @"m_id", paramters);
    return [self postPath:@"index/message_info" paramters:paramters completion:completion];
}

- (NSURLSessionDataTask *)deleteSystemMessage:(NSString *)mid completion:(HTTPCompletion)compleiton {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"uid", paramters);
    AddObjectForKeyIntoDictionary(mid, @"m_id", paramters);
    return [self postPath:@"index/message_del" paramters:paramters completion:compleiton];
}

- (NSURLSessionDataTask *)fetchSystemMsgInfoCompletion:(HTTPCompletion)completion {
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    AddObjectForKeyIntoDictionary([CurrentUserInfo sharedInstance].userId, @"id", paramters);
    AddObjectForKeyIntoDictionary(@(3), @"type", paramters);
    return [self postPath:@"index/message" paramters:paramters completion:completion];
}
@end
