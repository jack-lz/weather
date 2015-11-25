//
//  CityListViewController.h
//  weather
//
//  Created by lz-jack on 8/23/15.
//  Copyright (c) 2015 lz-jack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXLocation.h"

@interface CityListViewController :UIViewController
//想要代理一些组件，就要实现对应的协议
<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UISearchBarDelegate,UISearchResultsUpdating>
//委托代理人，代理一般需使用弱引用(weak或 assign)
@property (nonatomic, assign) id delegate;

@end


// 新建一个协议，协议的名字一般是由“类名+Delegate”
@protocol CityListViewControllerDelegate

- (void) citySelectionUpdate:(NSString*)selectedCity;

@end

