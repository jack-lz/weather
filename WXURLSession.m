//
//  WXURLSession.m
//  weather
//
//  Created by lz-jack on 11/3/15.
//  Copyright © 2015 lz-jack. All rights reserved.
//

#import "WXURLSession.h"



@interface WXURLSession ()
//这个接口用这个属性来管理API请求的URL session。
@property (nonatomic, strong) NSURLSession *session;

@end


@implementation WXURLSession

//通用的单例构造器
+ (instancetype)sharedSession
{
    static id _sharedSession;
    static dispatch_once_t onceToken;
    __weak typeof (self) wself = self;
    dispatch_once(&onceToken, ^{
        _sharedSession = [[wself alloc] init];
    });
    return _sharedSession;
}


- (id)init
{   //使用defaultSessionConfiguration为您创建session。
    if (self = [super init])
    {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}


// GET方式接收json数据并序列化，使用 Mantle 库转换，dictionary转换成指定类。
- (void)getJSONWithURL:(NSURL *)url   completionHandler:(void (^)( NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    NSLog(@"Fetching: %@",url.absoluteString);
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          if (!error)
                                          {
                                              completionHandler(data, response, nil);
                                          }
                                          else
                                          {
                                              completionHandler(nil, nil, error);
                                          }
                                      }];
    [dataTask resume];
}


- (void)postJSONWithURL:(NSURL *)url   completionHandler:(void (^)( NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    NSLog(@"Fetching: %@",url.absoluteString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *str = @"username=wyzc&pwd=wyzc";
    request.HTTPBody = [str dataUsingEncoding:NSUTF8StringEncoding];
    // 设置缓存策略(有缓存就用缓存，没有缓存就重新请求)
    // request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    //此处发送千万不能设置，这个地方只发送了口令数据接收者未使用json格式
    //  [request setValue:@"application/jason" forHTTPHeaderField:@"Content-Type"];
    NSURLSession  *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                    {
                                        if (!error)
                                        {
                                            completionHandler(data, response, nil);
                                        }
                                        else
                                        {
                                            completionHandler(nil, nil, error);
                                        }
                                    }];
    [dataTask resume];
}

- (void)postDictWithURL:(NSURL *)url   dictionary:(NSDictionary *)dict completionHandler:(void (^)( NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    NSLog(@"Fetching: %@",url.absoluteString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = data;
    //此处发送一定要设置，这个地方把Dictionary封装为json格式
    [request setValue:@"application/jason" forHTTPHeaderField:@"Content-Type"];
    // 设置缓存策略(有缓存就用缓存，没有缓存就重新请求)
    // request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          if (!error)
                                          {
                                              completionHandler(data, response, nil);
                                          }
                                          else
                                          {
                                              completionHandler(nil, nil, error);
                                          }
                                      }];
    [dataTask resume];
}


@end
