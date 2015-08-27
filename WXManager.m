//
//  WXManager.m
//  weather
//
//  Created by lz-jack on 8/19/15.
//  Copyright (c) 2015 lz-jack. All rights reserved.
//

#import "WXManager.h"
#import "WXClient.h"
#import <TSMessages/TSMessage.h>




@interface WXManager ()

// 声明你在公共接口中添加的相同的属性，但是这一次把他们定义为可读写，因此您可以在后台更改他们。
@property (nonatomic, strong, readwrite) WXCondition *currentCondition;
@property (nonatomic, strong, readwrite) CLLocation *currentLocation;
@property (nonatomic, strong, readwrite) NSArray *hourlyForecast;
@property (nonatomic, strong, readwrite) NSArray *dailyForecast;

// 为查找定位和数据抓取声明一些私有变量。
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) WXClient *client;

@end




@implementation WXManager
//通用的单例构造器
+ (instancetype)sharedManager {
    static id _sharedManager ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}
- (id)init {
    if (self = [super init]) {
        // 创建一个位置管理器，并设置它的delegate为self。
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest; //控制定位精度,越高耗电量越大。
        
        _locationManager.distanceFilter = 20.0f; //控制定位服务更新频率。单位是“米”
        
         [_locationManager startUpdatingLocation];
        
        // 为管理器创建WXClient对象。这里处理所有的网络请求和数据分析，这是关注点分离的最佳实践。
        _client = [[WXClient alloc] init];
        
        // 管理器使用一个返回信号的ReactiveCocoa脚本来观察自身的currentLocation。这与KVO类似，但更为强大。
        [[[[RACObserve(self, currentLocation)
            // 为了继续执行方法链，currentLocation必须不为nil。
            ignore:nil]
           //- flattenMap：非常类似于-map：，但不是映射每一个值，它把数据变得扁平，并返回包含三个信号中的一个对象。通过这种方式，你可以考虑将三个进程作为单个工作单元。
           // Flatten and subscribe to all 3 signals when currentLocation updates
           flattenMap:^(CLLocation *newLocation) {
               return [RACSignal merge:@[
                                         [self updateCurrentConditions],
                                         [self updateDailyForecast],
                                         [self updateHourlyForecast]
                                         ]];
               // 将信号传递给主线程上的观察者。
           }] deliverOn:RACScheduler.mainThreadScheduler]
         //这不是很好的做法，在你的模型中进行UI交互，但出于演示的目的，每当发生错误时，会显示一个banner。
         subscribeError:^(NSError *error) {
             [TSMessage showNotificationWithTitle:@"Error"
                                         subtitle:@"There was a problem fetching the latest weather."
                                             type:TSMessageNotificationTypeError];
         }];
       
    }
   
    return self;
     
}


- (void)findCurrentLocation {
    self.isFirstUpdate = YES;
    //系统版本高于8.0，则询问用户定位权限
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0) {
        // 前台定位
    
      //  [self.locationManager requestWhenInUseAuthorization];
        // 前后台同时定位
              [self.locationManager requestAlwaysAuthorization];
    }
   [self.locationManager  startUpdatingLocation];
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //忽略第一个位置更新，因为它一般是缓存值。
    
    if (self.isFirstUpdate) {
        self.isFirstUpdate = NO;
        return;
    }
 
    CLLocation *location = [locations lastObject];
   
    
    // 一旦你获得一定精度的位置，取此时的地址。
    if (location.horizontalAccuracy > 0) {
        // 设置currentLocation，将触发您之前在init中设置的RACObservable。
        self.currentLocation = location;
        //选择是否停止进一步的更新。选择将只是读取一次。
     //   [self.locationManager stopUpdatingLocation];
    }
}

//最后，是时候添加在客户端上调用并保存数据的三个获取方法。将三个方法捆绑起来，被之前在init方法中添加的RACObservable订阅。您将返回客户端返回的，能被订阅的，相同的信号。所有的属性设置发生在-doNext:中。
- (RACSignal *)updateCurrentConditions {
    return [[self.client fetchCurrentConditionsForLocation:self.currentLocation.coordinate] doNext:^(WXCondition *condition) {
        self.currentCondition = condition;
    }];
    
}

- (RACSignal *)updateHourlyForecast {
    return [[self.client fetchHourlyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.hourlyForecast = conditions;
    }];
    
}

- (RACSignal *)updateDailyForecast {
    return [[self.client fetchDailyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.dailyForecast = conditions;
    }];
}

@end
