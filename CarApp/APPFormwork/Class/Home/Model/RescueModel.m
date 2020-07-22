
#import "RescueModel.h"

@implementation RescueModel
- (void)loadRescueDetail:(NSDictionary *)dic {
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        if ([dic.allKeys containsObject:@"order_state"]) {
            self.rescueState = IntForKeyInUnserializedJSONDic(dic, @"order_state");
        }
        if ([dic.allKeys containsObject:@"is_offer"]) {
            self.is_offer = IntForKeyInUnserializedJSONDic(dic, @"is_offer");
        }
        if ([dic.allKeys containsObject:@"create_time"]) {
            self.create_time = StringForKeyInUnserializedJSONDic(dic, @"create_time");
        }
        self.v_name = StringForKeyInUnserializedJSONDic(dic, @"v_name");
        self.offer_time = StringForKeyInUnserializedJSONDic(dic, @"offer_time");
        self.pay_time = StringForKeyInUnserializedJSONDic(dic, @"pay_time");
        self.receipt_time = StringForKeyInUnserializedJSONDic(dic, @"receipt_time");
        self.repair_time = StringForKeyInUnserializedJSONDic(dic, @"repair_time");
        self.working_money = StringForKeyInUnserializedJSONDic(dic, @"working_money");
        self.parts_money = StringForKeyInUnserializedJSONDic(dic, @"parts_money");
        self.payment = IntForKeyInUnserializedJSONDic(dic, @"payment");
        self.r_phone = StringForKeyInUnserializedJSONDic(dic, @"r_phone");
        self.r_position = StringForKeyInUnserializedJSONDic(dic, @"r_position");
        self.vehicle_id = StringForKeyInUnserializedJSONDic(dic, @"vehicle_id");
        self.refuse_time = StringForKeyInUnserializedJSONDic(dic, @"refuse_time");
        self.r_content = StringForKeyInUnserializedJSONDic(dic, @"r_content");
        self.order_number = StringForKeyInUnserializedJSONDic(dic, @"order_number");
    }
}
@end
