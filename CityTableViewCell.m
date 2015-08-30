//
//  CityTableViewCell.m
//  weather
//
//  Created by lz-jack on 8/24/15.
//  Copyright (c) 2015 lz-jack. All rights reserved.
//

#import "CityTableViewCell.h"
#define kNameTag 1
#define kColorTag 2
@implementation CityTableViewCell
@synthesize name=_name,color=_color;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGRect nameLableRect=CGRectMake(0, 5, 100, 15);
        //定义一个距形，位置0,5,宽100高15,就是绝对定位
        UILabel *nameLable=[[UILabel alloc] initWithFrame:nameLableRect];
        //在距形定义的位置实例化一个UILable对象
        nameLable.tag=kNameTag;
        [self.contentView addSubview:nameLable];
        
        
        CGRect colorLableRect=CGRectMake(0, 30, 100, 15);
        //定义一个距形，距离上面的nameLable 10
        UILabel *colorLable=[[UILabel alloc] initWithFrame:colorLableRect];
        //在距形定义的位置实例化一个UILable对象
        colorLable.tag=kColorTag;
        [self.contentView addSubview:colorLable];
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
//自己写name和color的setter方法
-(void)setName:(NSString *)name
{
    if(![name isEqualToString:_name])
    {
        _name=[name copy];
        UILabel * nameLable=(UILabel *)[self.contentView viewWithTag:kNameTag];
        //通过viewWithTag方法得到UILable
        nameLable.text=_name;
        
    }
}
-(void)setColor:(NSString *)color
{
    if(![color isEqualToString:_color])
    {
        _color=[color copy];
        UILabel * colorLable=(UILabel *)[self.contentView viewWithTag:kColorTag];
        colorLable.text=_color;
        
    }
}


@end