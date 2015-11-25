//
//  WXClient.m
//  weather
//
//  Created by lz-jack on 8/19/15.
//  Copyright (c) 2015 lz-jack. All rights reserved.
//

#import "WXClient.h"
#import "WXCondition.h"
#import "WXDailyForecast.h"

@interface WXClient ()
//这个接口用这个属性来管理API请求的URL session。
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation WXClient

- (id)init
{
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

//- fetchJSONFromURL：创建一个对象给其他方法和对象使用；这种行为有时也被称为工厂模式。
- (RACSignal *)fetchJSONFromURL:(NSURL *)url
{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber)
    {
        // 创建一个NSURLSessionDataTask（在iOS7中加入）从URL取数据。你会在之后添加数据解析。
        [[WXURLSession sharedSession]  getJSONWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
            if (! error)
            {
                NSError *jsonError = nil;
                //序列化
                id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (! jsonError)
                {
                    // 当JSON数据存在并且没有错误，发送给订阅者序列化后的JSON数组或字典。
                    [subscriber sendNext:json];
                }
                else
                {
                    // 在任一情况下如果有一个错误，通知订阅者。
                    [subscriber sendError:jsonError];
                } 
            } 
            else
            {
                // 在任一情况下如果有一个错误，通知订阅者。
                [subscriber sendError:error]; 
            }
            // 无论该请求成功还是失败，通知订阅者请求已经完成。
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{  }];
    }] doError:^(NSError *error) {   }];
}


//获取当前状况
- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&appid=2de143494c0b295cca9337e1e96b00e0",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json)
    {
        return [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:json error:nil];
    }];
}


//获取逐时预报
- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&appid=2de143494c0b295cca9337e1e96b00e0",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json)
    {
        RACSequence *list = [json[@"list"] rac_sequence];
        return [[list map:^(NSDictionary *item)
        {
            return [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:item error:nil];
        }] array];
    }]; 
}


//获取每日预报
- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&appid=2de143494c0b295cca9337e1e96b00e0",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json)
    {
        RACSequence *list = [json[@"list"] rac_sequence];
        return [[list map:^(NSDictionary *item)
        {
            return [MTLJSONAdapter modelOfClass:[WXDailyForecast class] fromJSONDictionary:item error:nil];
        }] array];
    }];
}

@end
