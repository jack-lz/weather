//
//  WXTableViewCell.h
//  weather
//
//  Created by lz-jack on 9/9/15.
//  Copyright (c) 2015 lz-jack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXViewCellFrame.h"

@interface WXTableViewCell : UITableViewCell
/**框架模型***/
@property (nonatomic, strong) WXViewCellFrame *viewCellFrame;
/***时间*/
@property (nonatomic, weak) UILabel *dateLabel;

+ (instancetype)cellWithTableView:(UITableView *)tableView  ;

@end
