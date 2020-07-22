//
//  ShopItemView.h
//  APPFormwork
//
//  Created by jia on 2019/12/6.
//  Copyright © 2019 RJ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShopItemView : UIView
@property(nonatomic, copy)void(^shopHeaderCallBack)(NSInteger index, NSString * _Nullable cla);
@end

NS_ASSUME_NONNULL_END
