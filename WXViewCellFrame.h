//
//  WXViewCellFrame.h
//  weather
//
//  Created by lz-jack on 9/11/15.
//  Copyright (c) 2015 lz-jack. All rights reserved.


//  专门用来保存每一行数据的frame, 计算frame
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WXCondition.h"

@interface WXViewCellFrame : NSObject

/*** 日期时间的frame*/
@property (nonatomic, assign) CGRect dateLabelFrame;
/*** 天气情况的frame*/
@property (nonatomic, assign) CGRect descriptionLabelFrame;
/*** 温度的frame*/
@property (nonatomic, assign) CGRect temperatureLabelFrame;
/*** 天气图标的frame*/
@property (nonatomic, assign) CGRect pictureViewFrame;
/***  行高*/
@property (nonatomic, assign) CGFloat cellHeight;
/*** 模型数据*/
@property (nonatomic, strong) WXCondition *weather ;
/***每时或每天的设定*/
@property (nonatomic, strong) NSString *selectTitle;
@end
