//
//  WXLocation.m
//  weather
//
//  Created by lz-jack on 11/10/15.
//  Copyright © 2015 lz-jack. All rights reserved.
//

#import "WXLocation.h"


@interface WXLocation ()
// 创建一个位置管理器.
@property (nonatomic, strong) CLLocationManager *locationManager;


@end


@implementation WXLocation


- (id)init
{
    if (self = [super init])
    {
        // 创建一个位置管理器，并设置它的delegate为self。
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; //控制定位精度,越高耗电量越大。
        self.locationManager.distanceFilter = 20.0f; //控制定位服务更新频率。单位是“米”
    }
    return self;
}


#pragma LocationFunction
- (void)requestLocationAuthority
{
    //系统版本高于8.0，则询问用户定位权限
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0)
    {
        [self.locationManager requestAlwaysAuthorization];
    }
}


- (void)startUpdatingLocation
{
    [self.locationManager  startUpdatingLocation];//开始定位
}


- (void)stopUpdatingLocation
{
    [self.locationManager stopUpdatingLocation];//停止定位
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    // 一旦你获得一定精度的位置，取此时的地址。
    if (location.horizontalAccuracy > 0)
    {
      [_delegate updateLocation:location];
        //选择是否停止进一步的更新。选择将只是读取一次。
        [self stopUpdatingLocation];
    }
}

@end
