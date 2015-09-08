//
//  WXCondition.m
//  weather
//
//  Created by lz-jack on 8/19/15.
//  Copyright (c) 2015 lz-jack. All rights reserved.
//

#import "WXCondition.h"

@implementation WXCondition

+ (NSDictionary *)imageMap {
    // 创建一个静态的NSDictionary，因为WXCondition的每个实例都将使用相同的数据映射。
    static NSDictionary *_imageMap = nil;
    if (! _imageMap) {
        // 天气状况与图像文件的关系
        _imageMap = @{
                      @"01d" : @"weather-clear",
                      @"02d" : @"weather-few",
                      @"03d" : @"weather-few",
                      @"04d" : @"weather-broken",
                      @"09d" : @"weather-shower",
                      @"10d" : @"weather-rain",
                      @"11d" : @"weather-tstorm",
                      @"13d" : @"weather-snow",
                      @"50d" : @"weather-mist",
                      @"01n" : @"weather-moon",
                      @"02n" : @"weather-few-night",
                      @"03n" : @"weather-few-night",
                      @"04n" : @"weather-broken",
                      @"09n" : @"weather-shower",
                      @"10n" : @"weather-rain-night",
                      @"11n" : @"weather-tstorm",
                      @"13n" : @"weather-snow",
                      @"50n" : @"weather-mist",
                      };
    }
    return _imageMap;
}

// 声明获取图像文件名的公有方法。
- (NSString *)imageName {
    return [WXCondition imageMap][self.icon];
}


//“JSON到模型属性”的映射，且该方法是MTLJSONSerializing协议的require。在这个方法里，dictionary的key是WXCondition的属性名称，而dictionary的value是JSON的路径。
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"date": @"dt",
             @"locationName": @"name",
             @"humidity": @"main.humidity",
             @"temperature": @"main.temp",
             @"tempHigh": @"main.temp_max",
             @"tempLow": @"main.temp_min",
             @"sunrise": @"sys.sunrise",
             @"sunset": @"sys.sunset",
             @"conditionDescription": @"weather.description",
             @"condition": @"weather.main",
             @"icon": @"weather.icon",
             @"windBearing": @"wind.deg",
             @"windSpeed": @"wind.speed"
             };
}

//为NSDate属性设置的转换器。
+ (NSValueTransformer *)dateJSONTransformer {
    // 使用blocks做属性的转换的工作，并返回一个MTLValueTransformer返回值。^指Block，顾名思义代码块
   // 1. 它使得你的一段代码可以像普通变量值一样传递给其他函数和方法。
   // 2. 控制局部变量的访问，就像其他语言的Lambda表达式。
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [NSDate dateWithTimeIntervalSince1970:str.doubleValue];
    } reverseBlock:^(NSDate *date) {
        return [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    }];
}

// 您只需要详细说明Unix时间和NSDate之间进行转换一次，就可以重用-dateJSONTransformer方法为sunrise和sunset属性做转换。
+ (NSValueTransformer *)sunriseJSONTransformer {
    return [self dateJSONTransformer];
}

+ (NSValueTransformer *)sunsetJSONTransformer {
    return [self dateJSONTransformer];
}


//weather键对应的值是一个JSON数组，但你只关注单一的天气状况。
+ (NSValueTransformer *)conditionDescriptionJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *values) {
        return [values firstObject];
    } reverseBlock:^(NSString *str){
        return @[str];
    }];
}

+ (NSValueTransformer *)conditionJSONTransformer {
    return [self conditionDescriptionJSONTransformer];
}

+ (NSValueTransformer *)iconJSONTransformer {
    return [self conditionDescriptionJSONTransformer];
}




#define MPS_TO_MPH 2.23694f

+ (NSValueTransformer *)windSpeedJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *num ){
        return @(num.floatValue*MPS_TO_MPH);
    } reverseBlock:^(NSNumber *speed){
        return @(speed.floatValue/MPS_TO_MPH);
    }];
}
@end
