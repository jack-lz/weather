//
//  main.m
//  weather
//
//  Created by lz-jack on 8/19/15.
//  Copyright (c) 2015 lz-jack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
/***********系统入口的代码和参数说明
 argc:系统或者用户传入的参数
 argv:系统或用户传入的实际参数
 1.根据传入的第三个参数，创建UIApplication对象
 2.根据传入的第四个产生创建UIApplication对象的代理
 3.设置刚刚创建出来的代理对象为UIApplication的代理
 4.开启一个事件循环（Main Runloop,可以理解为里面是一个死循环）这个事件循环是一个队列（先进先出）先添加进去的先处理
*********/