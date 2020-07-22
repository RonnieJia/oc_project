//
//  RJTabBar.h
//  RJMySelfTabbar
//
//  Created by jia on 2017/1/6.
//  Copyright © 2017年 RJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RJTabBar;

@protocol RJTabBarDelegate <UITabBarDelegate>
- (void)tabBarDidClickPlusButton:(RJTabBar *)tabBar;
@end

@interface RJTabBar : UITabBar
@property (nonatomic, weak)id<RJTabBarDelegate> RJdelegate;
@end
