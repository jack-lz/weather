//
//  CityListViewController.h
//  weather
//
//  Created by lz-jack on 8/23/15.
//  Copyright (c) 2015 lz-jack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>


@property (nonatomic, assign) id delegate;


@end

@protocol CityListViewControllerProtocol
- (void) citySelectionUpdate:(NSString*)selectedCity;
- (NSString*) getDefaultCity;
@end

