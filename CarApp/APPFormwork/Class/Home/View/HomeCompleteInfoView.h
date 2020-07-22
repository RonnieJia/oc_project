//
//  HomeCompleteInfoView.h
//  APPFormwork
//
//  Created by jia on 2019/11/11.
//  Copyright © 2019 RJ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeCompleteInfoView : UIView
- (void)show:(void(^)())block;

@property(nonatomic,copy)void(^blcok)();
@end

NS_ASSUME_NONNULL_END
