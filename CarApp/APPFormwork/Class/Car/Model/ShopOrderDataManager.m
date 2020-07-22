#import "ShopOrderDataManager.h"

@implementation ShopOrderDataManager
+ (NSArray *)orderInfoList:(NSDictionary *)dic orderState:(ShopOrderState)state {
    NSString *orderNum = StringForKeyInUnserializedJSONDic(dic, @"order_number");
    NSString *paytype = IntForKeyInUnserializedJSONDic(dic, @"payment_type")==1?@"支付宝支付":@"微信支付";
    NSString *payTime = StringForKeyInUnserializedJSONDic(dic, @"pay_time");
    NSString *finishTime = StringForKeyInUnserializedJSONDic(dic, @"finish_time");
    NSString *returnApplyTime = StringForKeyInUnserializedJSONDic(dic, @"refund_time");
    
    NSMutableArray *arr = [NSMutableArray array];
    if (state == ShopOrderStateWait) {
        [arr addObjectsFromArray:@[@{@"title":@"订单编号",@"info":orderNum},@{@"title":@"订单状态",@"info":@"未付款"}]];
    } else if (state == ShopOrderStatePayed || state == ShopOrderStateDispatchin) {
        [arr addObjectsFromArray:@[
                                   @{@"title":@"订单编号",@"info":orderNum},
                                   @{@"title":@"订单状态",@"info":state==ShopOrderStatePayed?@"已付款":@"配送中"},
                                   @{@"title":@"支付方式",@"info":paytype},
                                   @{@"title":@"支付时间",@"info":payTime}
                                   ]];
    } else if (state == ShopOrderStateFinished) {
        [arr addObjectsFromArray:@[
                                   @{@"title":@"订单编号",@"info":orderNum},
                                   @{@"title":@"订单状态",@"info":@"已完成"},
                                   @{@"title":@"支付方式",@"info":paytype},
                                   @{@"title":@"支付时间",@"info":payTime},
                                   @{@"title":@"完成时间",@"info":finishTime}
                                   ]];
        
    } else if (state == ShopOrderStateReturn) {
        NSInteger refundState = IntForKeyInUnserializedJSONDic(dic, @"refund_status");
        NSString *refundStr = @"申请退款";
        if (refundState==2) {
            refundStr = @"已退款";
        } else if (refundState==3) {
            refundStr = @"拒绝退款";
        }
        [arr addObjectsFromArray:@[
                                   @{@"title":@"订单编号",@"info":orderNum},
                                   @{@"title":@"订单状态",@"info":refundStr},
                                   @{@"title":@"支付方式",@"info":paytype},
                                   @{@"title":@"支付时间",@"info":payTime},
                                   @{@"title":@"申请时间",@"info":returnApplyTime}
                                   ]];
    }
    
    return arr;
}

+ (NSArray *)orderReturnInfoList:(NSDictionary *)dic orderState:(ShopOrderState)orderState {
    NSInteger refund_status = IntForKeyInUnserializedJSONDic(dic, @"refund_status");// 退款状态
    NSString *refundMoney = StringForKeyInUnserializedJSONDic(dic, @"refund_money");
    NSString *reason = StringForKeyInUnserializedJSONDic(dic, @"refund_apply");
    NSString *reasonDesc = StringForKeyInUnserializedJSONDic(dic, @"refund_apply_content");
    NSString *refuse = StringForKeyInUnserializedJSONDic(dic, @"refuse_content");
    NSMutableArray *arr = [NSMutableArray array];
    if (refund_status==1) {// 已申请
        [arr addObjectsFromArray:@[
        @{@"title":@"退款原因",@"info":reason},
        @{@"title":@"原因简述",@"info":reasonDesc}
        ]];
    } else if (refund_status == 2) {// 已处理
        [arr addObjectsFromArray:@[
        @{@"title":@"已退款金额",@"info":refundMoney},
        @{@"title":@"退款原因",@"info":reason},
        @{@"title":@"原因简述",@"info":reasonDesc}
        ]];
    } else {// 拒绝退款
        [arr addObjectsFromArray:@[
        @{@"title":@"退款原因",@"info":reason},
        @{@"title":@"原因简述",@"info":reasonDesc},
        @{@"title":@"拒绝退款原因",@"info":refuse}
        ]];
    }
    
    return arr;
}
@end
