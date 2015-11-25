//
//  WXController.m
//  weather
//
//  Created by lz-jack on 8/19/15.
//  Copyright (c) 2015 lz-jack. All rights reserved.
//
#import "WXManager.h" 
#import "WXController.h"
#import "CityListViewController.h"
#import "AppDelegate.h"
#import "LGRefreshView.h"
#import "LGHelper.h"
#import "ShuffleAnimation.h"
#import "ScaleAnimation.h"
#import "WXViewCellFrame.h"
#import "WXTableViewCell.h"


@interface WXController ()
{
    ShuffleAnimation *_shuffleAnimationController;
    ScaleAnimation *_scaleAnimationController;
}
@property (nonatomic, strong) UIImageView  *backgroundImageView;
@property (nonatomic, strong) UIImageView  *iconView;
@property (nonatomic, strong) UITableView  *tableView;
@property (nonatomic, strong) LGRefreshView  *refreshView;
@property (nonatomic, strong) UIView  *header;
@property (nonatomic, strong) UIVisualEffectView *blurredView;
@property (nonatomic, strong) UILabel  *hiloLabel;
@property (nonatomic, strong) UILabel  *windLabel;
@property (nonatomic, strong) UILabel  *temperatureLabel;
@property (nonatomic, strong) UILabel  *conditionsLabel;
@property (nonatomic, strong) UILabel  *cityLabel;
@property (nonatomic, strong) UILabel  *dataLabel;
@property (nonatomic, strong) UIButton *cityButton;
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, assign) CGFloat  screenHeight;
@property (nonatomic, assign) CGFloat  cellHeight;
@property (nonatomic, strong) NSDateFormatter  *hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter  *dailyFormatter;
@property (nonatomic, strong) NSString  *selectCity;

@end

@implementation WXController
 




- (void)viewDidLoad
{
    
   [super viewDidLoad];
    
    self.navigationController.delegate = self;//设置委托，使得 Navigation Controller Delegate中的两个方法生效
    // 获取并存储屏幕高度。之后，你将在用分页的方式来显示所有天气数据时，使用它。
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
   
    
    // 创建一个静态的背景图，并添加到视图上。
    UIImage *background = [UIImage imageNamed:@"bg"];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:self.backgroundImageView];
    
    // 使用UIBlurEffect类和UIVisualEffectView类来创建一个模糊的背景图像，并设置alpha为0（初始透明的）。
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];//  创建需要的毛玻璃特效类型
    self.blurredView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];   //  毛玻璃view 视图
    self.blurredView.alpha = 0.0f;
    self.blurredView.frame = self.view .bounds;
    [self.view  addSubview:_blurredView];

    // 创建tableview来处理所有的数据呈现。 设置WXController为delegate和dataSource，以及滚动视图的delegate。请注意，设置pagingEnabled为YES（pagingEnabled 是否自动滚动到subView边界 scrollEnabled 是否可以滚动 ）。
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.alwaysBounceVertical = YES; //控制垂直方向遇到边框是否反弹
    self.tableView.allowsSelection = NO;
    [self.view addSubview:self.tableView];
    
    // 设置table的header大小与屏幕相同。你将利用的UITableView的分页来分隔页面页头和每日每时的天气预报部分。
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    CGFloat inset = 20;
    CGFloat temperatureHeight = 180;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 70;
    CGFloat windHeight = 20;
    CGRect hiloFrame = CGRectMake(inset,
                                  headerFrame.size.height - hiloHeight,
                                  headerFrame.size.width - (2 * inset),
                                  hiloHeight);
    CGRect temperatureFrame = CGRectMake(inset,
                                         headerFrame.size.height - (temperatureHeight + hiloHeight),
                                         headerFrame.size.width - (2 * inset),
                                         temperatureHeight);
    CGRect iconFrame = CGRectMake(inset+30,
                                  temperatureFrame.origin.y - 3.6 * iconHeight,
                                  iconHeight,
                                  iconHeight);
    CGRect windFrame = CGRectMake(headerFrame.size.width/2.5,
                                  headerFrame.size.height - (temperatureHeight +2 * windHeight),
                                  headerFrame.size.width/2,
                                  windHeight);
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight +10);
    
    // 设置你的table header。
    self.header = [[UIView alloc] initWithFrame:headerFrame];
    self.header.backgroundColor = [UIColor clearColor];
  
    // 构建每一个显示气象数据的标签。
    // bottom right
    _temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    _temperatureLabel.backgroundColor = [UIColor clearColor];
    _temperatureLabel.textColor = [UIColor whiteColor];
    _temperatureLabel.text = @"0°";
    _temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:100];
    _temperatureLabel.textAlignment = NSTextAlignmentRight;
    [self.header addSubview:_temperatureLabel];
    
    _hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    _hiloLabel.backgroundColor = [UIColor clearColor];
    _hiloLabel.textColor = [UIColor whiteColor];
    _hiloLabel.text = @"0° / 0°";
    _hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:35];
    _hiloLabel.textAlignment = NSTextAlignmentRight;
    [self.header addSubview:_hiloLabel];
   
    //bottom right
    _windLabel = [[UILabel alloc] initWithFrame: windFrame];
    _windLabel.backgroundColor = [UIColor clearColor];
    _windLabel.textColor = [UIColor whiteColor];
    _windLabel.text = @"Loading...";
    _windLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    _windLabel.textAlignment = NSTextAlignmentCenter;
    [self.header addSubview:_windLabel];
    
    //添加一个天气图标的图像视图。
    // bottom left
    _iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    _iconView.contentMode = UIViewContentModeScaleToFill;
    _iconView.backgroundColor = [UIColor clearColor];
    [self.header addSubview:_iconView];
    
    
    //添加天气图标后的天气状态
    _conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    _conditionsLabel.backgroundColor = [UIColor clearColor];
    _conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:65];
    _conditionsLabel.textColor = [UIColor whiteColor];
    _conditionsLabel.textAlignment = NSTextAlignmentCenter;
    [self.header addSubview:_conditionsLabel];
    
    // top
    _cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 20, self.view.bounds.size.width-150, 30)];
    _cityLabel.backgroundColor = [UIColor clearColor];
    _cityLabel.textColor = [UIColor whiteColor];
    _cityLabel.text = @"Loading...";
    _cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25];
    _cityLabel.textAlignment = NSTextAlignmentCenter;
    [self.header addSubview:_cityLabel];
    
    // top
    _dataLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 50, self.view.bounds.size.width-150, 18)];
    _dataLabel.backgroundColor = [UIColor clearColor];
    _dataLabel.textColor = [UIColor whiteColor];
    _dataLabel.text = @"Loading...";
    _dataLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
    _dataLabel.textAlignment = NSTextAlignmentCenter;
    [self.header addSubview:_dataLabel];
   
    
    // top
    self.cityButton = [[UIButton alloc] initWithFrame:CGRectMake(15,23, 45, 28)];
    self.cityButton.backgroundColor = [UIColor clearColor];
    [self.cityButton.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
    [self.cityButton.layer setBorderWidth:0.8]; //边框宽度
    [self.cityButton setTitle: @"City" forState:UIControlStateNormal];//设置 title
    self.cityButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.cityButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];//title color
    self.cityButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    [self.cityButton addTarget:self action:@selector(cityButtonUp:) forControlEvents:UIControlEventTouchUpInside];//添加 action
    [self.cityButton  setBackgroundImage:[LGHelper image1x1WithColor:[UIColor blueColor]] forState:UIControlStateHighlighted];
    [self.cityButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.cityButton .userInteractionEnabled = YES;//使能可以点击
    [self.header addSubview:self.cityButton];
    
    self.refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-50,23, 45, 28)];
    self.refreshButton.backgroundColor = [UIColor clearColor];
    [self.refreshButton.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
    [self.refreshButton.layer setBorderWidth:0.8]; //边框宽度
    [self.refreshButton setTitle: @"Refresh" forState:UIControlStateNormal];//设置 title
    self.refreshButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.refreshButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];//title color
    self.refreshButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [self.refreshButton addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];//添加 action
    [self.refreshButton setBackgroundImage:[LGHelper image1x1WithColor:[UIColor blueColor]] forState:UIControlStateHighlighted];
    [self.refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.refreshButton .userInteractionEnabled = YES;//使能可以点击
    [self.header addSubview:self.refreshButton];
    
    self.tableView.tableHeaderView = self.header;

    // 观察WXManager单例的currentCondition。改变动态分配建立的标签和按钮。它们和tableview 没有关系。
    __weak typeof(self) wself = self;
    [[RACObserve([WXManager sharedManager], currentCondition)
      //传递到主线程上的任何变化，因为你正在更新UI。
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(WXCondition *newCondition) {
         [wself updateUI:newCondition];
     }];
   
    
    [[RACObserve([WXManager sharedManager], hourlyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [wself.tableView reloadData];
     }];
    
    [[RACObserve([WXManager sharedManager], dailyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [wself.tableView reloadData];
     }];
    
    [[WXManager sharedManager] requestLocationAuthority];
    //这告诉WXManager类，开始寻找设备的当前位置。
    [[WXManager sharedManager] startUpdatingLocation];
    //下拉刷新
    [self refreshTableView];
}


//在WXController.m中，你的视图控制器调用该方法来编排其子视图。
- (void)viewWillLayoutSubviews
{ 
    [super viewWillLayoutSubviews];
    CGRect bounds = self.view.bounds;
    self.cityButton.backgroundColor = [UIColor clearColor];
    self.backgroundImageView.frame = bounds;
    self.blurredView .frame=bounds;
    self.tableView.frame = bounds;
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}


//隐藏和显示导航控制栈的导航栏
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
   
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{   // 除了上下颠倒，都支持
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


//界面数据更新的函数
-(void)updateUI:(WXCondition *)newCondition
{
    if (newCondition)
    {
        //使用气象数据更新文本标签；你为文本标签使用newCondition的数据，而不是单例。订阅者的参数保证是最新值。
        self.cityLabel.text = [newCondition.locationName capitalizedString];
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy.MM.dd HH:mm:ss";
        self.dataLabel.text = [NSString stringWithFormat:@"Updated at %@", [dateFormatter stringFromDate:date]];
        //使用映射的图像文件名来创建一个图像，并将其设置为视图的图标。
        self.iconView.image = [UIImage imageNamed:[newCondition imageName]];
        //风向和风速
        NSString *windBearing = [[NSString alloc]initWithString:[newCondition windBearingString]];
        NSString *windSpeed = [[NSString alloc]initWithString:[newCondition windSpeedString]];
        self.windLabel.text = [NSString stringWithFormat:@"   %@   %@",windBearing,windSpeed];
        //改变背景，从下标8开始抽取到字符串结束，包括8，搜索到背景图片
        self.backgroundImageView.image = [UIImage imageNamed:[[newCondition imageName] substringFromIndex:8]];
        self.conditionsLabel.text = [newCondition.condition capitalizedString];//首字母大写
        self.temperatureLabel.text = [NSString stringWithFormat:@"%.0f°",[newCondition fahrenheitToCelsius:newCondition.temperature].floatValue];
        self.hiloLabel.text = [NSString  stringWithFormat:@"%.0f°~%.0f°",(newCondition.tempHigh.floatValue-273.15),(newCondition.tempLow.floatValue-273.15)];
        if(self.refreshView.isRefreshing)
        {
        [self.refreshView endRefreshing];
        }
    }
}


#pragma mark - Navigation Controller Delegate
//自定义视图跳转动画（无需交互）
-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    BaseAnimation *animationController;
//  _scaleAnimationController = [[ScaleAnimation alloc] init];
//    animationController = _scaleAnimationController;
    _shuffleAnimationController = [[ShuffleAnimation alloc]  init];
    animationController = _shuffleAnimationController;
    switch (operation)
    {
        case UINavigationControllerOperationPush:
             animationController.type = AnimationTypePresent;
             break;
        case UINavigationControllerOperationPop:
             animationController.type = AnimationTypeDismiss;
             break;
        default:
             animationController = nil;
             break;
    }
    return  animationController;
}


//city 弹起事件 action,sender表示接收按钮状态，也可以写成(UIButton *)sender
- (void)cityButtonUp: (id *)sender
{
    self.cityButton.backgroundColor = [UIColor clearColor];
    CityListViewController *cityViewController = [[CityListViewController alloc]  init];
    cityViewController.delegate = self;
    [self.navigationController pushViewController:cityViewController animated:YES];
    
}


//这是和 CityListViewController 类之间委托协议的函数，给被代理类（委托方）调用的。
- (void)citySelectionUpdate:(NSString *) selectedCity
{   //改变 currentCondition的值
    self.selectCity= selectedCity;
    [self refreshAction];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //基于屏幕高度去定义 cell 高度
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return (self.screenHeight /(CGFloat)cellCount);
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   // 第一部分是对的逐时预报。使用最近6小时的预预报，并添加了一个作为页眉的单元格。
   NSInteger count = MIN([[WXManager sharedManager].dailyForecast count], 6) + 1;
   if (section == 0)
   {
       count = MIN([[WXManager sharedManager].hourlyForecast count], 6) + 1;
    }
    // 接下来的部分是每日预报。使用最近6天的每日预报，并添加了一个作为页眉的单元格。
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   //选择自定义的 cell
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    self.cellHeight = self.screenHeight /(CGFloat)cellCount;
    WXTableViewCell *cell = [WXTableViewCell cellWithTableView:tableView ];
    WXViewCellFrame *viewFrame = [[WXViewCellFrame alloc] init];
    viewFrame.cellHeight = self.cellHeight;
    if (indexPath.section == 0)
    {
        // 每个部分的第一行是标题单元格。
        if (indexPath.row == 0)
        {
            viewFrame.weather = nil;
            viewFrame.dateLabelFrame = CGRectMake(10, 20, 250,55);
            viewFrame.temperatureLabelFrame = CGRectMake(0, 0, 0,0);
            cell.viewCellFrame = viewFrame;
            cell.dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22];
            cell.dateLabel.text = @"Hourly Forecast";
            cell.dateLabel.textColor = [UIColor blackColor];
        }
        else
        {
            // 获取每小时的天气和使用自定义配置方法配置cell。
            WXCondition *weather = [WXManager sharedManager].hourlyForecast[indexPath.row - 1];
            viewFrame.weather = weather;
            viewFrame.selectTitle = @"Hourly Forecast";
            cell.viewCellFrame = viewFrame;
        }
    }
    else if (indexPath.section == 1)
      {
        // 每个部分的第一行是标题单元格。
        if (indexPath.row == 0)
        {
            viewFrame.weather = nil;
            viewFrame.dateLabelFrame = CGRectMake(10, 20, 250,55);
            viewFrame.temperatureLabelFrame = CGRectMake(0, 0, 0,0);
            cell.viewCellFrame = viewFrame;
            cell.dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22];
            cell.dateLabel.text = @"Daily Forecast";
            cell.dateLabel.textColor = [UIColor blackColor];
        }
        else
        {
            // 获取每天的天气，并使用另一个自定义配置方法配置cell。
            WXCondition *weather = [WXManager sharedManager].dailyForecast[indexPath.row - 1];
            viewFrame.weather = weather;
            viewFrame.selectTitle = @"Daily Forecast";
            cell.viewCellFrame = viewFrame;
        }
      }
    return cell;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //获取滚动视图的高度和内容偏移量。与0偏移量做比较，因此试图滚动table低于初始位置将不会影响模糊效果。
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    //通过滚动的量来区分下拉刷新和翻页，因为 翻页效果会影响下拉的延时效果
    if (position>100.0)
    {
        self.tableView.pagingEnabled = YES;
    }
    else
    {
        self.tableView.pagingEnabled = NO;
    }
    // 偏移量除以高度，并且最大值为1，所以alpha上限为1。
    CGFloat percent = MIN(position / height, 0.9f);
    // 当你滚动的时候，把结果值赋给模糊图像的alpha属性，来更改模糊图像。
    self.blurredView.alpha = percent;
}


#pragma mark -refreshView

//下拉刷新
-(void)refreshTableView
{
    __weak typeof(self) wself = self;
    self.refreshView = [LGRefreshView refreshViewWithScrollView:self.tableView refreshHandler:^(LGRefreshView *refreshView)
                        {
                            if (wself)
                            {
                                __strong typeof(wself) self = wself;
                                [[WXManager sharedManager] chooseCityLocation:self.selectCity];
                                //此处可以添加刷新成功或失败的执行语句
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10*NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
                                               {
                                                   if(self.refreshView.isRefreshing)
                                                   {
                                                       [self.refreshView endRefreshing];
                                                       [self performSelectorOnMainThread:@selector(alertTitle)withObject: nil waitUntilDone:NO];
                                                   }
                                               });
                            }
                        }];
    UIColor *CustomColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.5 alpha:0.3f];
    self.refreshView.tintColor = CustomColor;
    self.refreshView.backgroundColor = [UIColor clearColor];
}


//刷新按钮触发函数
- (void)refreshAction
{
    self.tableView.contentOffset = CGPointMake(0.0, -80.0); //tableview offset 效果，注意位移点的y值为负值
    [self.refreshView triggerAnimated:YES];//是否触发动画
}


#pragma mark -otherFunction
//修改屏幕顶端状态栏的颜色，UIStatusBarStyleDefault状态栏的字体为黑色；UIStatusBarStyleLightContent，状态栏的字体为白色。
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


//内存警告处理函数，调用父类的这个函数释放controller的resouse，不会释放view
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//错误警告
-(void)alertTitle
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接错误"  message:@"请检查网络设置或稍后再试。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
    [alert addButtonWithTitle:@"确认"];
    [alert show];
}

@end
