//
//  WXURLSession.h
//  weather
//
//  Created by lz-jack on 11/3/15.
//  Copyright © 2015 lz-jack. All rights reserved.
//

@import Foundation;
@import CoreLocation;
@import UIKit;
#import <Mantle.h>


@interface WXURLSession : NSObject

+ (instancetype)sharedSession;

- (void)getJSONWithURL:(NSURL *)url   completionHandler:(void (^)( NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (void)postJSONWithURL:(NSURL *)url   completionHandler:(void (^)( NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (void)postDictWithURL:(NSURL *)url   dictionary:(NSDictionary *)dict completionHandler:(void (^)( NSData *data, NSURLResponse *response, NSError *error))completionHandler;
@end
