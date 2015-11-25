//
//  AppDelegate.m
//  weather
//
//  Created by lz-jack on 8/19/15.
//  Copyright (c) 2015 lz-jack. All rights reserved.
//

#import "AppDelegate.h"
#import "WXController.h"
#import <TSMessage.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

 // 当应用程序启动完毕的时候就会调用(系统自动调用)
<<<<<<< Updated upstream
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
=======
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
>>>>>>> Stashed changes
   self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // 设置根控制器，通常这个控制器是一个的UINavigationController或UITabBarController
    WXController *rootVC = [[WXController alloc] init];
    //将第一个视图控制器作为基栈视图控制器添加到导航视图控制器栈中
    UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:rootVC];
    //作为App的根视图控制器。也可以使用WXController的单个实例作为根试图控制器。
    navCtr.navigationBar.hidden=YES;
    self.window.rootViewController = navCtr;
    // 设置默认的视图控制器来显示你的TSMessages。这样做，你将不再需要手动指定要使用的控制器来显示警告。
    // TSMessages 是另一个非常简单的库，用来显示浮层警告和通知。当出现错误信息而不直接影响用户的时候，最好使用浮层来代替模态窗口(例如UIAlertView)，这样你将尽可能减少对用户的影响。
    [TSMessage setDefaultViewController: self.window.rootViewController];
    //显示窗口
    [self.window makeKeyAndVisible];
    return YES;
}

<<<<<<< Updated upstream
// 即将失去活动状态的时候调用(失去焦点, 不可交互)
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

=======
>>>>>>> Stashed changes
// 应用程序进入后台的时候调用
// 一般在该方法中保存应用程序的数据, 以及状态
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supp orts background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

// 应用程序即将进入前台的时候调用
// 一般在该方法中恢复应用程序的数据,以及状态
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

<<<<<<< Updated upstream
=======
// 即将失去活动状态的时候调用(失去焦点, 不可交互)
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

>>>>>>> Stashed changes
// 重新获取焦点(能够和用户交互)
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

// 应用程序即将被销毁的时候会调用该方法
 // 注意:如果应用程序处于挂起状态的时候无法调用该方法
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}



@end
