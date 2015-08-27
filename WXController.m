//
//  WXController.m
//  weather
//
//  Created by lz-jack on 8/19/15.
//  Copyright (c) 2015 lz-jack. All rights reserved.
//
#import "WXManager.h" 
#import "WXController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "CityListViewController.h"
#import "AppDelegate.h"


@interface WXController ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, strong) NSDateFormatter *hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter *dailyFormatter;
@property (nonatomic, retain) UIButton *cityButton;
@property (nonatomic, strong) NSString *defaultCity;//全局变量，专用于给下一视图传送当前城市的
@end

@implementation WXController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 获取并存储屏幕高度。之后，你将在用分页的方式来显示所有天气数据时，使用它。
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    UIImage *background = [UIImage imageNamed:@"bg"];
    
    // 创建一个静态的背景图，并添加到视图上。
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    // 使用LBBlurredImage来创建一个模糊的背景图像，并设置alpha为0（初始透明的），使得开始下面的backgroundImageView是可见的。
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    
    // 创建tableview来处理所有的数据呈现。 设置WXController为delegate和dataSource，以及滚动视图的delegate。请注意，设置pagingEnabled为YES（pagingEnabled 是否自动滚动到subView边界 scrollEnabled 是否可以滚动 ）。
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES; 
    [self.view addSubview:self.tableView];
    
    // 设置table的header大小与屏幕相同。你将利用的UITableView的分页来分隔页面页头和每日每时的天气预报部分。
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    // 创建inset（或padding）变量，以便您的所有标签均匀分布并居中。
    CGFloat inset = 20;
    // 创建并初始化为各种视图创建的高度变量。设置这些值作为常量，使得可以很容易地在需要的时候，配置和更改您的视图设置。
    CGFloat temperatureHeight = 180;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 70;
    // 使用常量和inset变量，为label和view创建框架。
    CGRect hiloFrame = CGRectMake(inset,
                                  headerFrame.size.height - hiloHeight,
                                  headerFrame.size.width - (2 * inset),
                                  hiloHeight);
    
    CGRect temperatureFrame = CGRectMake(inset,
                                         headerFrame.size.height - (temperatureHeight + hiloHeight),
                                         headerFrame.size.width - (2 * inset),
                                         temperatureHeight);
    
    CGRect iconFrame = CGRectMake(inset+30,
                                  temperatureFrame.origin.y - 3.6*iconHeight,
                                  iconHeight,
                                  iconHeight);
    //复制图标框，调整它，使文本具有一定的扩展空间，并通过xy将其移动到该图标的右侧。当我们把标签添加到视图，你会看到布局的效果。
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight +10);
    
    // 设置当前view为你的table header。
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    // 构建每一个显示气象数据的标签。
    // bottom left
    UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.text = @"0°";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:130];
    temperatureLabel.textAlignment = NSTextAlignmentRight;
    [header addSubview:temperatureLabel];
    
    // bottom left
    UILabel *hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    hiloLabel.text = @"0° / 0°";
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:37];
    hiloLabel.textAlignment = NSTextAlignmentRight;
    [header addSubview:hiloLabel];
    
    //添加一个天气图标的图像视图。
    // bottom left
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit; //图片缩放以适应固定的行
    iconView.backgroundColor = [UIColor clearColor];
    [header addSubview:iconView];
    //添加天气图标后的天气状态
    UILabel *conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:65];
    conditionsLabel.textColor = [UIColor whiteColor];
    conditionsLabel.textAlignment = NSTextAlignmentLeft;
    [header addSubview:conditionsLabel];
    
    // top
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 20, self.view.bounds.size.width-150, 30)];
    cityLabel.backgroundColor = [UIColor clearColor];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.text = @"Loading...";
    cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22];
    cityLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:cityLabel];
    // top
    self.cityButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-50, 20, 45, 30)];
    self.cityButton.backgroundColor = [UIColor clearColor];
    [self.cityButton.layer setMasksToBounds:YES];//方法告诉layer将位于它之下的layer都遮盖
    [self.cityButton.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
    [self.cityButton.layer setBorderWidth:0.8]; //边框宽度
    [self.cityButton setTitle: @"City >" forState:UIControlStateNormal];//设置 title
    self.cityButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.cityButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];//title color
    self.cityButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    [self.cityButton addTarget:self action:@selector(CityButtonUp:) forControlEvents:UIControlEventTouchUpInside];//添加 action
     [self.cityButton addTarget:self action:@selector(CityButtondown:) forControlEvents:UIControlEventTouchDown];//添加 action
    self.cityButton .userInteractionEnabled=YES;//使能可以点击
    [header addSubview:self.cityButton];
    
    
    
    // 观察WXManager单例的currentCondition。
    [[RACObserve([WXManager sharedManager], currentCondition)
      //传递在主线程上的任何变化，因为你正在更新UI。
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(WXCondition *newCondition) {
         if (newCondition) {
         //使用气象数据更新文本标签；你为文本标签使用newCondition的数据，而不是单例。订阅者的参数保证是最新值。
         temperatureLabel.text = [NSString stringWithFormat:@"%.0f°",newCondition.temperature.floatValue];
         
         conditionsLabel.text = [newCondition.condition capitalizedString];
         cityLabel.text = [newCondition.locationName capitalizedString];
         self.defaultCity=cityLabel.text;
         //使用映射的图像文件名来创建一个图像，并将其设置为视图的图标。
         iconView.image = [UIImage imageNamed:[newCondition imageName]];
         }
     }];
    
    // RAC（…）宏有助于保持语法整洁。从该信号的返回值将被分配给hiloLabel对象的text。
    RAC(hiloLabel, text) = [[RACSignal combineLatest:@[
                                                       // 观察currentCondition的高温和低温。合并信号，并使用两者最新的值。当任一数据变化时，信号就会触发。
                                                       RACObserve([WXManager sharedManager], currentCondition.tempHigh),
                                                       RACObserve([WXManager sharedManager], currentCondition.tempLow)]
                             // 从合并的信号中，减少数值，转换成一个单一的数据，注意参数的顺序与信号的顺序相匹配。
                                              reduce:^(NSNumber *hi, NSNumber *low) {
                                                  return [NSString  stringWithFormat:@"%.0f°/ %.0f°",hi.floatValue,low.floatValue];
                                              }] 
                            // 同样，因为你正在处理UI界面，所以把所有东西都传递到主线程。
                            deliverOn:RACScheduler.mainThreadScheduler];
  
    
    [[RACObserve([WXManager sharedManager], hourlyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    
    [[RACObserve([WXManager sharedManager], dailyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    
    
    //这告诉管理类，开始寻找设备的当前位置。
    [[WXManager sharedManager] findCurrentLocation];
    
   
}

//在WXController.m中，你的视图控制器调用该方法来编排其子视图。
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}

//隐藏和显示导航控制栈的导航栏
- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    self.cityButton.backgroundColor = [UIColor clearColor];
}
- (void)viewWillDisappear:(BOOL)animated
{
  
    self.navigationController.navigationBar.hidden = NO;
}
- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
   
}


//city 按下事件 action
- (void)CityButtondown: (UIButton*) citybutton {
    self.cityButton.backgroundColor = [UIColor blueColor];
}

//city 弹起事件 action
- (void)CityButtonUp: (id *)sender {
   
    //launch city list view
   
    CityListViewController *CityViewController = [[CityListViewController alloc]  init];

    CityViewController.delegate = self;
   
    [self.navigationController pushViewController:CityViewController animated:YES];
    
}
//这是委托的一个函数，可以在 CityListController.m中调用获取现在的城市。
- (NSString*) getDefaultCity
{
    return self.defaultCity;
}



#pragma mark - UITableViewDataSource
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 第一部分是对的逐时预报。使用最近6小时的预预报，并添加了一个作为页眉的单元格。
   if (section == 0) {
     return MIN([[WXManager sharedManager].hourlyForecast count], 6) + 1;
    }
    // 接下来的部分是每日预报。使用最近6天的每日预报，并添加了一个作为页眉的单元格。
     return MIN([[WXManager sharedManager].dailyForecast count], 6) + 1;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
   
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.section == 0) {
        // 每个部分的第一行是标题单元格。
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Hourly Forecast"];
        }
        else {
            // 获取每小时的天气和使用自定义配置方法配置cell。
           WXCondition *weather = [WXManager sharedManager].hourlyForecast[indexPath.row - 1];
           [self configureHourlyCell:cell weather:weather];
        }
    }
    else if (indexPath.section == 1) {
        // 每个部分的第一行是标题单元格。
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Daily Forecast"];
        }
        else {
            // 获取每天的天气，并使用另一个自定义配置方法配置cell。
           WXCondition *weather = [WXManager sharedManager].dailyForecast[indexPath.row - 1];
           [self configureDailyCell:cell weather:weather];
        } 
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //  Determine cell height based on screen
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight / (CGFloat)cellCount;
    
    return 44;
}



- (UIStatusBarStyle)preferredStatusBarStyle {
   return UIStatusBarStyleLightContent;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (id)init {
    //设置一下时区,显示成北京时间（东八区）
    [_hourlyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [_dailyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CH"]];
    
    if (self = [super init]) {
        _hourlyFormatter = [[NSDateFormatter alloc] init];
        _hourlyFormatter.dateFormat = @"HH:mm";
        
        _dailyFormatter = [[NSDateFormatter alloc] init];
        _dailyFormatter.dateFormat = @"d-MMM";
    }
    return self;
}

// 配置和添加文本到作为section页眉单元格。你会重用此为每日每时的预测部分。
- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

// 格式化逐时预报的单元格。
- (void)configureHourlyCell:(UITableViewCell *)cell weather:(WXCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.hourlyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°",weather.temperature.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

//格式化每日预报的单元格。
- (void)configureDailyCell:(UITableViewCell *)cell weather:(WXCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.dailyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f° / %.0f°",
                                 weather.tempHigh.floatValue,
                                 weather.tempLow.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 获取滚动视图的高度和内容偏移量。与0偏移量做比较，因此试图滚动table低于初始位置将不会影响模糊效果。
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    // 偏移量除以高度，并且最大值为1，所以alpha上限为1。
    CGFloat percent = MIN(position / height, 1.0);
    // 当你滚动的时候，把结果值赋给模糊图像的alpha属性，来更改模糊图像。
    self.blurredImageView.alpha = percent;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
