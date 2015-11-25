//
//  WXManager.m
//  weather
//
//  Created by lz-jack on 8/19/15.
//  Copyright (c) 2015 lz-jack. All rights reserved.
//

#import "WXManager.h"
#import <TSMessages/TSMessage.h>


@interface WXManager ()

// 声明你在公共接口中添加的相同的属性，但是这一次把他们定义为可读写，因此您可以在后台更改他们。
@property (nonatomic, strong, readwrite) CLLocation  *currentLocation;
@property (nonatomic, strong, readwrite) WXCondition *currentCondition;
@property (nonatomic, strong, readwrite) NSArray *hourlyForecast;
@property (nonatomic, strong, readwrite) NSArray *dailyForecast;
@property (nonatomic, strong, readwrite) CLLocation *selectCity;
@property (nonatomic, strong, readwrite) WXLocation *locationManager;
@property (nonatomic, strong) WXClient *client;

@end



@implementation WXManager

//通用的单例构造器
+ (instancetype)sharedManager
{
    static id _sharedManager ;
    static dispatch_once_t onceToken;
    __weak typeof (self) wself = self;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[wself alloc] init];
    });
    return _sharedManager;
}


- (id)init
{
    if (self = [super init])
    {
        // 创建一个位置管理器，并设置它的delegate为self。
        self.locationManager = [[WXLocation alloc] init];
        self.locationManager.delegate = self;
        self.client = [[WXClient alloc] init];
        __weak typeof (self) wself = self;
    [[[[RACObserve(self, currentLocation) ignore:nil]
       flattenMap:^(CLLocation *newLocation) {
           return [RACSignal merge:@[
                                     [wself updateCurrentConditions],
                                     [wself updateHourlyForecast],
                                     [wself updateDailyForecast],
                                     ]];
           // 将信号传递给主线程上的观察者。
       }] deliverOn:RACScheduler.mainThreadScheduler]
       subscribeError:^(NSError *error) {
         [TSMessage showNotificationWithTitle:@"Error"
                                     subtitle:@"There was a problem fetching the latest weather."
                                         type:TSMessageNotificationTypeError];
     }];
    }
    return self;
}


#pragma LocationFunction
- (void)requestLocationAuthority
{
    [self.locationManager requestLocationAuthority];
}


- (void)startUpdatingLocation
{
    [self.locationManager  startUpdatingLocation];
}


- (void)chooseCityLocation:(NSString *) selectedCity
{
    if (selectedCity != nil)
    {
        /***************也可以先转化为拼音再搜索************/
        CFMutableStringRef string = CFStringCreateMutableCopy(NULL, 0, (__bridge CFStringRef)selectedCity);//转换字符串
        CFStringTransform(string, NULL, kCFStringTransformMandarinLatin, NO);//转换为拼音
        CFStringTransform(string, NULL, kCFStringTransformStripDiacritics, NO);//去掉音标
        NSString *oreillyAddress = [(__bridge NSString *)(string) stringByReplacingOccurrencesOfString:@" " withString:@""];//去掉空格
        //反向地理编码
        CLGeocoder *myGeocoder = [[CLGeocoder alloc] init];
        __weak typeof (self) wself = self;
        [myGeocoder geocodeAddressString:oreillyAddress completionHandler:^(NSArray *placeMarks, NSError *error)
         {
             if ([placeMarks count] > 0 && error == nil)
             {
                 CLPlacemark *firstPlaceMark = [placeMarks objectAtIndex:0];
                 wself.selectCity=[[CLLocation alloc] initWithLatitude:firstPlaceMark.location.coordinate.latitude longitude:firstPlaceMark.location.coordinate.longitude];
                 wself.currentLocation = wself.selectCity;
             }
         }];
    }
    else
    {
        [self  startUpdatingLocation];
    }
}



#pragma mark - WXLocationDelegate

- (void)updateLocation:(CLLocation *)location
{
    self.currentLocation = location;
}


#pragma mark -fetchDataSelector

- (RACSignal *)updateCurrentConditions
{
    __weak typeof (self) wself = self;
    return [[self.client fetchCurrentConditionsForLocation:self.currentLocation.coordinate]
            doNext:^(WXCondition *condition)
    {
        wself.currentCondition = condition;
    }];
}


- (RACSignal *)updateHourlyForecast
{
    __weak typeof (self) wself = self;
    return [[self.client fetchHourlyForecastForLocation:self.currentLocation.coordinate]
            doNext:^(NSArray *conditions)
    {
        wself.hourlyForecast = conditions;
    }];
}


- (RACSignal *)updateDailyForecast
{
    __weak typeof (self) wself = self;
    return [[self.client fetchDailyForecastForLocation:self.currentLocation.coordinate]
            doNext:^(NSArray *conditions)
    {
       wself.dailyForecast = conditions;
    }];
}


#pragma Error
//错误警告
-(void)alertTitle
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接错误"  message:@"请检查网络设置或稍后再试。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
    [alert addButtonWithTitle:@"确认"];
    [alert show];
}

@end
