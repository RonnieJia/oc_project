//
//  BMKWalkNaviHelper.h
//  WalkCycleComponent
//
//  Created by Xin,Qi on 24/01/2018.
//  Copyright © 2018 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BMKWalkCycleNavigationDelegates.h"
#import "BMKWalkNaviLaunchParam.h"
#import "BMKWalkCycleNavigationDisplayOption.h"
#import "BMKWalkCycleLocationService.h"

#pragma mark - 步行导航控制器类
/**
 步行导航控制器类
 */
@interface BMKWalkNavigationManager : NSObject

/**
 算路代理回调
 */
@property (nonatomic, weak) id <BMKWalkCycleRoutePlanDelegate> routePlanDelegate;

/**
 导航状态信息回调
 */
@property (nonatomic, weak) id <BMKWalkCycleRouteGuidanceDelegate> routeGuidanceDelegate;

/**
 语音播报文本回调
 */
@property (nonatomic, weak) id <BMKWalkCycleTTSPlayerDelegate> ttsPlayerDelegate;

/**
  步骑行导航定位权限授权代理
  */
@property (nonatomic, weak) id <BMKWalkCycleLocationServiceDelegate> locationAuthorizationDelegate;

/**
 单例全局访问点
 
 @return BMKWalkNavigationManager单例对象。
 */
+ (instancetype)sharedManager;

/**
 销毁单例
 */
+ (void)destroy;

/**
 初始化引擎

 @param controller 导航页面，由开发者提供。
 @return 引擎初始化结果。
 */
- (BOOL)initNaviEngine:(UIViewController *)controller;

/**
 发起算路
 
 @param parameter 步行导航起终点参数类。
 */
- (void)routePlanWithParams:(BMKWalkNaviLaunchParam *)parameter;

/**
 导航过程生命周期函数, 开始导航。
 选择模式的不同，加载导航页面不一样，分为普通步行和AR步行两种模式。
 @param navigationMode 步行导航模式。
 @return 开始导航结果
 */
- (BOOL)startWalkNavi:(BMKWalkNavigationMode)navigationMode;

/**
 导航过程生命周期函数，暂停导航。
 */
- (void)pause;

/**
 导航过程生命周期函数，恢复导航。
 */
- (void)resume;

/**
 导航过程生命周期函数，结束导航。
 */
- (void)stop;

@end
