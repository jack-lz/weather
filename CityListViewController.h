//
//  CityListViewController.h
//  weather
//
//  Created by lz-jack on 8/23/15.
//  Copyright (c) 2015 lz-jack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityListViewController :UIViewController
<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

// 委托代理人，代理一般需使用弱引用(weak或 assign)
@property (nonatomic, assign) id delegate;


@end

// 新建一个协议，协议的名字一般是由“类名+Delegate”
@protocol CityListViewControllerProtocol
- (void) citySelectionUpdate:(NSString*)selectedCity;//
- (NSString*) getDefaultCity;
@end

