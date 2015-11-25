//
//  WXLocation.h
//  weather
//
//  Created by lz-jack on 11/10/15.
//  Copyright © 2015 lz-jack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKMapView.h>

@interface WXLocation : NSObject
<CLLocationManagerDelegate>

@property (nonatomic, assign) id delegate;

- (void)requestLocationAuthority;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end


// 新建一个协议，协议的名字一般是由“类名+Delegate”
@protocol WXLocationDelegate

- (void)updateLocation:(CLLocation *)location;//用于返回定位地址的 delegate

@end