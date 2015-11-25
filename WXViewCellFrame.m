//
//  WXViewCellFrame.m
//  weather
//
//  Created by lz-jack on 9/11/15.
//  Copyright (c) 2015 lz-jack. All rights reserved.
//

#import "WXViewCellFrame.h"


#define DateFont [UIFont fontWithName:@"HelveticaNeue-Light" size:18]
#define TemperatureFont [UIFont fontWithName:@"HelveticaNeue-Medium" size:18]



@implementation WXViewCellFrame

- (id)initWithSelectTitle:(NSString *)selectTitle
{
    if (self = [super init])
    {
    self.selectTitle = selectTitle;
    }
    return self;
}
//重写weather属性的setter方法: 在这个方法中设置子控件的显示数据和frame
- (void)setWeather:(WXCondition *)weather
{
    _weather = weather;
    // 间隙
    CGFloat padding = 10;
    // 设置天气图标的frame
    CGFloat pictureViewW = 0;
    CGFloat pictureViewH = 50;
    CGFloat pictureViewX = padding;
    CGFloat pictureViewY = (self.cellHeight-pictureViewH)/2;
    if ([weather imageName] != nil)
    {
        pictureViewW = 50;
    }
    self.pictureViewFrame = CGRectMake(pictureViewX, pictureViewY, pictureViewW, pictureViewH);
    // 设置温度标签的frame
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGSize textSize =  [self sizeWithString:[NSString stringWithFormat:@"%.0f° ~ %.0f°",(_weather.tempHigh.floatValue-32) * 5/9,(_weather.tempLow.floatValue-32) * 5/9] font:TemperatureFont maxSize:CGSizeMake(300, MAXFLOAT)];
    if ([self.selectTitle isEqual:@"Hourly Forecast"])
    {
        textSize = [self sizeWithString:[NSString stringWithFormat:@"%.0f°",(_weather.temperature.floatValue-32)*5/9] font:TemperatureFont maxSize:CGSizeMake(300, MAXFLOAT)];
    }
    CGFloat tempLabelW = textSize.width;
    CGFloat tempLabelH = textSize.height;
    CGFloat tempLabelX = bounds.size.width-tempLabelW-padding;
    CGFloat tempLabelY = pictureViewY + (pictureViewH - tempLabelH) * 0.5;
    self.temperatureLabelFrame = CGRectMake(tempLabelX, tempLabelY, tempLabelW, tempLabelH);
    // 设置date的frame
    CGFloat dateLabelX = CGRectGetMaxX(self.pictureViewFrame ) + padding;
    CGFloat dateLabelH = textSize.height;
    CGFloat dateLabelW = 70;
    CGFloat dateLabelY = pictureViewY + (pictureViewH - dateLabelH) * 0.5;
    self.dateLabelFrame = CGRectMake(dateLabelX, dateLabelY, dateLabelW, dateLabelH);
    // 设置conditionDescription的frame
    CGFloat descriptionLabelX = CGRectGetMaxX(self.dateLabelFrame);
    CGFloat descriptionLabelH = textSize.height;
    CGFloat descriptionLabelW = 130;
    CGFloat descriptionLabelY = pictureViewY + (pictureViewH - dateLabelH) * 0.5;
    self.descriptionLabelFrame = CGRectMake(descriptionLabelX, descriptionLabelY, descriptionLabelW, descriptionLabelH);
}


- (CGSize)sizeWithString:(NSString *)str font:(UIFont *)font maxSize:(CGSize)maxSize
{   //如果计算的文字的范围超出了指定的范围,返回指定的范围，如果小于指定的范围, 返回真实的范围
    NSDictionary *dict = @{NSFontAttributeName : font};
    CGSize size = [str boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    return size;
}

@end
