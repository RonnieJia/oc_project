//
//  SearchViewController.h
//  APPFormwork
//
//  Created by jia on 2017/8/28.
//  Copyright © 2017年 RJ. All rights reserved.
//

#import "RJBaseViewController.h"

@interface SearchViewController : RJBaseViewController
@property (nonatomic, strong)NSString *placeholder;
@property (nonatomic, strong)NSString *searchWord;
@property (nonatomic, weak)UITextField *searchTextField;


- (void)searchAction;
@end
