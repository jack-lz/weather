//
//  WXCondition.h
//  weather
//
//  Created by lz-jack on 8/19/15.
//  Copyright (c) 2015 lz-jack. All rights reserved.
//


#import <Mantle.h>
//MTLJSONSerializing协议告诉Mantle序列化该对象如何从JSON映射到Objective-C的属性。
@interface WXCondition : MTLModel <MTLJSONSerializing>

//这些都是你的天气数据的属性。你将会使用这些属性的get set方法，但是当你要扩展App，这是一种很好的方法来访问数据。
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *humidity;
@property (nonatomic, strong) NSNumber *temperature;
@property (nonatomic, strong) NSNumber *tempHigh;
@property (nonatomic, strong) NSNumber *tempLow;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSDate *sunrise;
@property (nonatomic, strong) NSDate *sunset;
@property (nonatomic, strong) NSString *conditionDescription;
@property (nonatomic, strong) NSString *condition;
@property (nonatomic, strong) NSNumber *windBearing;
@property (nonatomic, strong) NSNumber *windSpeed;
@property (nonatomic, strong) NSString *icon;

// 这是一个简单的辅助方法，从天气状况映射到图像文件。
- (NSString *)imageName;
- (NSString *)windBearingString;
- (NSString *)windSpeedString;
- (NSNumber *)fahrenheitToCelsius:(NSNumber *)fahrenheit;
@end
