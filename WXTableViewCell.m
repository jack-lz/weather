
//
//  WXTableViewCell.m
//  weather
//
//  Created by lz-jack on 9/9/15.
//  Copyright (c) 2015 lz-jack. All rights reserved.
//

#import "WXTableViewCell.h"
#import <UIKit/UIKit.h>
#import "WXManager.h" 



#define DateFont [UIFont fontWithName:@"HelveticaNeue-Light" size:18]
#define TemperatureFont [UIFont fontWithName:@"HelveticaNeue-Medium" size:18]

@interface WXTableViewCell ()


/**天气图标**/
@property (nonatomic, weak) UIImageView *pictureView;
/*** 天气情况的frame*/
@property (nonatomic, weak) UILabel *descriptionLabel;
/***气温*/
@property (nonatomic, weak) UILabel *temperatureLabel;
/***日期格式*/
@property (nonatomic, strong) NSDateFormatter *dailyFormatter;
@property (nonatomic, strong) NSDateFormatter *hourlyFormatter;


@end

@implementation WXTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView  
{
    
    
    static NSString *identifier = @"condition";
    // 1.缓存中取
    WXTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    // 2.创建
    if (cell == nil) {
        cell = [[WXTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    return cell;
}


/**
 *  构造方法(在初始化对象的时候会调用)
 *  一般在这个方法中添加需要显示的子控件
 */
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //让自定义Cell和系统的cell一样, 一创建出来就拥有一些子控件提供给我们使用
        
        // 1.创建日期标签
        UILabel *dateLabel = [[UILabel alloc] init];
        dateLabel.font = DateFont;
        [self.contentView addSubview:dateLabel];
        self.dateLabel = dateLabel;
        
        // 2.创建天气描述的标签
        UILabel *descriptionLabel = [[UILabel alloc] init];
        descriptionLabel.font = DateFont;
        [self.contentView addSubview:descriptionLabel];
        self.descriptionLabel= descriptionLabel;
        
        // 3.创建正文
        UILabel *temperatureLabel = [[UILabel alloc] init];
        temperatureLabel.font = TemperatureFont;
        temperatureLabel.numberOfLines = 0;
        [self.contentView addSubview:temperatureLabel];
        self.temperatureLabel = temperatureLabel;
        
        // 4.创建配图
        UIImageView *pictureView = [[UIImageView alloc] init];
        [self.contentView addSubview:pictureView];
        self.pictureView = pictureView;
        
    }
    return self;
}

//重写viewCellFrame的setter方法: 在这个方法中给子控件赋值数据和设置frame。所以cell.viewCellFrame=frame1等价于[self setsetViewCellFrame:frame1]。
- (void)setViewCellFrame:(WXViewCellFrame *)viewCellFrame
{
    _viewCellFrame = viewCellFrame;
    
    // 1.给子控件赋值数据
    [self settingData];
    // 2.设置frame
    [self settingFrame];
}


/**
 *  设置子控件的数据
 */
- (void)settingData
{
    WXCondition *weather = self.viewCellFrame.weather;
    
    //设置一下时区,显示成北京时间（东八区）
    _hourlyFormatter = [[NSDateFormatter alloc] init];
    _hourlyFormatter.dateFormat = @"HH:mm";
    [_hourlyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    
    _dailyFormatter = [[NSDateFormatter alloc] init];
    _dailyFormatter.dateFormat = @"M/d";
    [_dailyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CH"]];
  
    // 设置天气图标
    if ([weather imageName]!=nil) {
        self.pictureView.image = [UIImage imageNamed:[weather imageName]];
        self.pictureView.backgroundColor=[UIColor clearColor];
        self.pictureView.contentMode = UIViewContentModeScaleAspectFit;
        self.pictureView.hidden = NO;
    }

    // 设置日期和气温
    if ([self.viewCellFrame.selectTitle isEqual:@"Hourly Forecast"]) {
        self.temperatureLabel.text =[NSString stringWithFormat:@"%.0f°",[weather fahrenheitToCelsius:weather.temperature].floatValue];
        self.dateLabel.text = [self.hourlyFormatter stringFromDate:weather.date];
    }else{
        self.temperatureLabel.text =[NSString stringWithFormat:@"%.0f° ~ %.0f°",[weather fahrenheitToCelsius:weather.tempLow].floatValue,[weather fahrenheitToCelsius:weather.tempHigh].floatValue];
        self.dateLabel.text = [self.dailyFormatter stringFromDate:weather.date];
    }
    self.dateLabel.backgroundColor=[UIColor clearColor];
    self.dateLabel.textColor=[UIColor whiteColor];
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    self.temperatureLabel.textColor=[UIColor whiteColor];
    self.temperatureLabel.textAlignment = NSTextAlignmentRight;
    //设置天气描述lable
    self.descriptionLabel.text=weather.conditionDescription;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.backgroundColor=[UIColor clearColor];
    self.descriptionLabel.textColor=[UIColor whiteColor];
}
/**
 *  设置子控件的frame
 */
- (void)settingFrame
{
    // 设置日期frame
    self.dateLabel.frame = self.viewCellFrame.dateLabelFrame;
    // 设置天气描述lable
    self.descriptionLabel.frame=self.viewCellFrame.descriptionLabelFrame;
    // 设置温度的frame
    self.temperatureLabel.frame = self.viewCellFrame.temperatureLabelFrame;
    // 设置天气图标的frame
    self.pictureView.frame = self.viewCellFrame.pictureViewFrame;
}

/**
 *  计算文本的宽高
 *
 *  @param str     需要计算的文本
 *  @param font    文本显示的字体
 *  @param maxSize 文本显示的范围
 *
 *  @return 文本占用的真实宽高
 */
- (CGSize)sizeWithString:(NSString *)str font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *dict = @{NSFontAttributeName : font};
    // 如果将来计算的文字的范围超出了指定的范围,返回的就是指定的范围
    // 如果将来计算的文字的范围小于指定的范围, 返回的就是真实的范围
    CGSize size =  [str boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    return size;
}




@end
