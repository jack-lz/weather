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
//申明华氏到摄氏的转换
-(NSNumber * )fahrenheitToCelsius:(NSNumber *)fahrenheit{
    NSNumber *fah=nil;
    if (fahrenheit!=nil) {
        fah=[[NSNumber alloc]initWithFloat:(fahrenheit.floatValue-32)*5/9];
    }
    return fah;

}


- (NSString *) windBearingString {
    
    NSString *windBear=[[NSString alloc]init];
   int windBearingInt=(int)ceilf(self.windBearing.floatValue);
    switch (windBearingInt/10)
    {
        case 34:case 35:case 36:case 0:case 1:
            windBear=@"北风";
            break;
        case 2:case 3:case 4:case 5:case 6:
            windBear=@"东北风";
            break;
        case 7:case 8:case 9:case 10:
            windBear=@"东风";
            break;
        case 11:case 12:case 13:case 14:case 15:
            windBear=@"东南风";
            break;
        case 16:case 17:case 18:case 19:
            windBear=@"南风";
            break;
        case 20:case 21:case 22:case 23:case 24:
            windBear=@"西南风";
            break;
        case 25:case 26:case 27:case 28:
            windBear=@"西风";
            break;
        case 29:case 30:case 31:case 32:case 33:
            windBear=@"西北风";
            break;
        default:
            break;
    }
    return windBear;
}
- (NSString *) windSpeedString {
int intValue=(int)ceilf(self.windSpeed.floatValue);
NSString *windSpeed=[[NSString alloc]init];
switch (intValue)
{
    case 0:case 1:
        windSpeed=@"0级  无风";
        break;
    case 2:case 3:case 4:case 5:
        windSpeed=@"1级  软风";
        break;
    case 6:case 7:case 8:case 9:case 10:case 11:
        windSpeed=@"2级  轻风";
        break;
    case 12:case 13:case 14:case 15:case 16:case 17:case 18:case 19:
        windSpeed=@"3级  微风";
        break;
    case 20:case 21:case 22:case 23:case 24:case 25:case 26:case 27:case 28:
        windSpeed=@"4级  和风";
        break;
    case 29:case 30:case 31:case 32:case 33:case 34:case 35:case 36:case 37:case 38:
        windSpeed=@"5级  清风";
        break;
    case 39:case 40:case 41:case 42:case 43:case 44:case 45:case 46:case 47:case 48:case 49:
        windSpeed=@"6级  强风";
        break;
    case 50:case 51:case 52:case 53:case 54:case 55:case 56:case 57:case 58:case 59:case 60:case 61:
        windSpeed=@"7级  疾风";
        break;
    case 62:case 63:case 64:case 65:case 66:case 67:case 68:case 69:case 70:case 71:case 72:case 73:case 74:
        windSpeed=@"8级  大风";
        break;
    case 75:case 76:case 77:case 78:case 79:case 80:case 81:case 82:case 83:case 84:case 85:case 86:case 87:case 88:
        windSpeed=@"9级  烈风";
        break;
    case 89:case 90:case 91:case 92:case 93:case 94:case 95:case 96:case 97:case 98:case 99:case 100:case 101:case 102:
        windSpeed=@"10级  狂风";
        break;
    case 103:case 104:case 105:case 106:case 107:case 108:case 109:case 110:case 111:case 112:case 113:case 114:case 115:case 116:case 117:
        windSpeed=@"11级  暴风";
        break;
    default:
        windSpeed=@"12级  台风";
        break;
   }
   return windSpeed;
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

//以下的函数都是针对各个属性的转换方法，提供给MTLJSONAdapter类调用的，命名方法必须是属性名+JSONTransformer这个格式。
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
