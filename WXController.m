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
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, strong) NSDateFormatter *hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter *dailyFormatter;
@property (nonatomic, strong) UIButton *cityButton;
@property (nonatomic, strong) NSString *defaultCity;//全局变量，专用于给下一视图传送当前城市的
@property (nonatomic, strong) NSString *selectCity;
@property (nonatomic, strong) LGRefreshView *refreshView;
@property (nonatomic, strong) UIButton      *refreshButton;


@end

@implementation WXController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
   self.selectCity = @"定位到当前位置";
   self.navigationController.delegate=self;//设置委托，使得 Navigation Controller Delegate中的两个方法生效
  
    
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
    self.tableView.alwaysBounceVertical = YES;
    self.tableView.allowsSelection = NO;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
  //  self.tableView.pagingEnabled = YES;//翻页会影响下拉延时，在后面的滚动函数中视滚动量来设置比较好
    [self.view addSubview:self.tableView];
    
    // 设置table的header大小与屏幕相同。你将利用的UITableView的分页来分隔页面页头和每日每时的天气预报部分。
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    // 创建inset（或padding）变量，以便您的所有标签均匀分布并居中。
    CGFloat inset = 20;
    // 创建并初始化为各种视图创建的高度变量。设置这些值作为常量，使得可以很容易地在需要的时候，配置和更改您的视图设置。
    CGFloat temperatureHeight = 180;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 70;
    CGFloat windHeight = 20;
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
    
    // 设置你的table header。
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    // 构建每一个显示气象数据的标签。
    // bottom right
    UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.text = @"0°";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:130];
    temperatureLabel.textAlignment = NSTextAlignmentRight;
    [header addSubview:temperatureLabel];
    
    // bottom right
    UILabel *hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    hiloLabel.text = @"0° / 0°";
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:37];
    hiloLabel.textAlignment = NSTextAlignmentRight;
    [header addSubview:hiloLabel];
   
    //bottom right
    UILabel *windLabel = [[UILabel alloc] initWithFrame: CGRectMake(headerFrame.size.width/2.5,
                                                                         headerFrame.size.height - (temperatureHeight +2*windHeight),
                                                                         headerFrame.size.width/2,
                                                                         windHeight)];
    windLabel.backgroundColor = [UIColor clearColor];
    windLabel.textColor = [UIColor whiteColor];
    windLabel.text = @"Loading...";
    windLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    windLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:windLabel];
    
    
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
    cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25];
    cityLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:cityLabel];
    
    // top
    UILabel *dataLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 50, self.view.bounds.size.width-150, 18)];
    dataLabel.backgroundColor = [UIColor clearColor];
    dataLabel.textColor = [UIColor whiteColor];
    dataLabel.text = @"Loading...";
    dataLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
    dataLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:dataLabel];
   
    
    // top
    self.cityButton = [[UIButton alloc] initWithFrame:CGRectMake(15,23, 45, 28)];
    self.cityButton.backgroundColor = [UIColor clearColor];
    [self.cityButton.layer setMasksToBounds:YES];//方法告诉layer将位于它之下的layer都遮盖
    [self.cityButton.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
    [self.cityButton.layer setBorderWidth:0.8]; //边框宽度
    [self.cityButton setTitle: @"City" forState:UIControlStateNormal];//设置 title
    self.cityButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.cityButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];//title color
    self.cityButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    [self.cityButton addTarget:self action:@selector(CityButtonUp:) forControlEvents:UIControlEventTouchUpInside];//添加 action
    [self.cityButton  setBackgroundImage:[LGHelper image1x1WithColor:[UIColor blueColor]] forState:UIControlStateHighlighted];
    [self.cityButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.cityButton .userInteractionEnabled=YES;//使能可以点击
    [header addSubview:self.cityButton];
    
    self.refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-50,23, 45, 28)];
    self.refreshButton.backgroundColor = [UIColor clearColor];
    [self.refreshButton.layer setMasksToBounds:YES];//方法告诉layer将位于它之下的layer都遮盖
    [self.refreshButton.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
    [self.refreshButton.layer setBorderWidth:0.8]; //边框宽度
    [self.refreshButton setTitle: @"Refresh" forState:UIControlStateNormal];//设置 title
    self.refreshButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.refreshButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];//title color
    self.refreshButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [self.refreshButton addTarget:self action:@selector(RefreshAction) forControlEvents:UIControlEventTouchUpInside];//添加 action
    [self.refreshButton  setBackgroundImage:[LGHelper image1x1WithColor:[UIColor blueColor]] forState:UIControlStateHighlighted];
    [self.refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.refreshButton .userInteractionEnabled=YES;//使能可以点击
    [header addSubview:self.refreshButton];
    
    
   
    
    // 观察WXManager单例的currentCondition。改变动态分配建立的标签和按钮。它们和tableview 没有关系。
    [[RACObserve([WXManager sharedManager], currentCondition)
      //传递在主线程上的任何变化，因为你正在更新UI。
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(WXCondition *newCondition) {
         if (newCondition) {
         //使用气象数据更新文本标签；你为文本标签使用newCondition的数据，而不是单例。订阅者的参数保证是最新值。
        cityLabel.text = [newCondition.locationName capitalizedString];
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy.MM.dd HH:mm:ss";
        dataLabel.text = [NSString stringWithFormat:@"Updated at %@", [dateFormatter stringFromDate:date]];
        //使用映射的图像文件名来创建一个图像，并将其设置为视图的图标。
        iconView.image = [UIImage imageNamed:[newCondition imageName]];
             
        //风向和风速
        NSString *windBearing=[[NSString alloc]initWithString:[newCondition windBearingString]];
        NSString *windSpeed=[[NSString alloc]initWithString:[newCondition windSpeedString]];
             
        windLabel.text = [NSString stringWithFormat:@"   %@    %@",windBearing,windSpeed];
             
        //改变背景，从下标8开始抽取到字符串结束，包括8，搜索到背景图片
        self.backgroundImageView.image = [UIImage imageNamed:[[newCondition imageName] substringFromIndex:8]];
             
       //self.blurredImageView.image = [UIImage imageNamed:[[newCondition imageName] substringFromIndex:8]];
       [self.blurredImageView setImageToBlur:[UIImage imageNamed:[[newCondition imageName] substringFromIndex:8]] blurRadius:10 completionBlock:nil];
        conditionsLabel.text = [newCondition.condition capitalizedString];//首字母大写
        temperatureLabel.text = [NSString stringWithFormat:@"%.0f°",[newCondition fahrenheitToCelsius:newCondition.temperature].floatValue];
        self.defaultCity=cityLabel.text;
         
         }
     }];
    //wxzhao，函数太长，尽量使用 ios 自带的监听函数。
    // RAC（…）宏有助于保持语法整洁。从该信号的返回值将被分配给hiloLabel对象的text。
    RAC(hiloLabel, text) = [[RACSignal combineLatest:@[
                                                       // 观察currentCondition的高温和低温。合并信号，并使用两者最新的值。当任一数据变化时，信号就会触发。
                                                       RACObserve([WXManager sharedManager], currentCondition.tempHigh),
                                                       RACObserve([WXManager sharedManager], currentCondition.tempLow)]
                             // 从合并的信号中，减少数值，转换成一个单一的数据，注意参数的顺序与信号的顺序相匹配。
                                              reduce:^(NSNumber *hi, NSNumber *low) {
                                                  return [NSString  stringWithFormat:@"%.0f°~%.0f°",(low.floatValue-32)*5/9,(hi.floatValue-32)*5/9];
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
    
    //下拉刷新
    __weak typeof(self) wself = self;
    
    self.refreshView = [LGRefreshView refreshViewWithScrollView:self.tableView refreshHandler:^(LGRefreshView *refreshView)
                    {
                        if (wself)
                        {
                            __strong typeof(wself) self = wself;
                            
                           [[WXManager sharedManager] ChooseCityLocation:self.selectCity];
                        
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
                                           {
                                               [self.refreshView endRefreshing];
                                           });
                        }
                    }];
    
     UIColor *CustomColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.5 alpha:0.3f];
    self.refreshView.tintColor = CustomColor ;
    self.refreshView.backgroundColor = [UIColor clearColor];
}

//在WXController.m中，你的视图控制器调用该方法来编排其子视图。
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    self.cityButton.backgroundColor = [UIColor clearColor];
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
   
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];


}


//隐藏和显示导航控制栈的导航栏
- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
    [self.navigationController setNavigationBarHidden:YES animated:animated];
   
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
  
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
    self.cityButton.backgroundColor = [UIColor clearColor];
    CityListViewController *CityViewController = [[CityListViewController alloc]  init];

    CityViewController.delegate = self;
   
    [self.navigationController pushViewController:CityViewController animated:YES];
    
}




#pragma mark - Navigation Controller Delegate

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
  
    BaseAnimation *animationController;
//   _scaleAnimationController=[[ScaleAnimation alloc] init];
//    animationController = _scaleAnimationController;
    _shuffleAnimationController=[[ShuffleAnimation alloc]  init];
    animationController = _shuffleAnimationController;
    switch (operation) {
        case UINavigationControllerOperationPush:
            animationController.type = AnimationTypePresent;
             break;
        case UINavigationControllerOperationPop:
            animationController.type = AnimationTypeDismiss;
            break;
        default: return nil;
    }
    return  animationController;
    
}

-(id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    //    if ([animationController isKindOfClass:[ScaleAnimation class]]) {
    //        ScaleAnimation *controller = (ScaleAnimation *)animationController;
    //        if (controller.isInteractive) return controller;
    //        else return nil;
    //    } else
    return nil;
}


//这是和 CityListViewController 类之间委托协议的2个函数，给被代理类（委托方）调用的。
- (NSString*) getDefaultCity
{
    return self.defaultCity;//向 WXManager 传值
}

- (void)citySelectionUpdate:(NSString *) selectedCity
{
    self.selectCity= selectedCity;//从 WXManger 传值回来
//NSLog(@"%@",self.SelectCity);
    
    [[WXManager sharedManager] ChooseCityLocation:self.selectCity];//改变 currentCondition的值

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
    
    NSInteger count= MIN([[WXManager sharedManager].dailyForecast count], 6) + 1;
   if (section == 0) {
       count=MIN([[WXManager sharedManager].hourlyForecast count], 6) + 1;
    }
    
    // 接下来的部分是每日预报。使用最近6天的每日预报，并添加了一个作为页眉的单元格。
     return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
 
    self.cellHeight=self.screenHeight /(CGFloat)cellCount;
    //选择自定义的 cell
    WXTableViewCell *cell = [WXTableViewCell cellWithTableView:tableView ];
    WXViewCellFrame *viewFrame = [[WXViewCellFrame alloc] init];
    viewFrame.cellHeight=self.cellHeight;
    
    if (indexPath.section == 0) {
        // 每个部分的第一行是标题单元格。
        if (indexPath.row == 0) {
            viewFrame.weather = nil;
            viewFrame.dateLabelFrame = CGRectMake(10, 20, 250,55);
            viewFrame.temperatureLabelFrame=CGRectMake(0, 0, 0,0);
            cell.viewCellFrame=viewFrame;
            cell.dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22];
            cell.dateLabel.text = @"Hourly Forecast";
            cell.dateLabel.textColor=[UIColor blackColor];
        }
        else {
            // 获取每小时的天气和使用自定义配置方法配置cell。
            WXCondition *weather = [WXManager sharedManager].hourlyForecast[indexPath.row - 1];
            viewFrame.weather = weather;
            viewFrame.selectTitle=@"Hourly Forecast";
            cell.viewCellFrame=viewFrame;
        }
    }
    else if (indexPath.section == 1) {
        // 每个部分的第一行是标题单元格。
        if (indexPath.row == 0) {
            viewFrame.weather = nil;
            viewFrame.dateLabelFrame = CGRectMake(10, 20, 250,55);
            viewFrame.temperatureLabelFrame=CGRectMake(0, 0, 0,0);
            cell.viewCellFrame=viewFrame;
            cell.dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22];
            cell.dateLabel.text = @"Daily Forecast";
             cell.dateLabel.textColor=[UIColor blackColor];
        }
        else {
            // 获取每天的天气，并使用另一个自定义配置方法配置cell。
            WXCondition *weather = [WXManager sharedManager].dailyForecast[indexPath.row - 1];
            viewFrame.weather = weather;
            viewFrame.selectTitle=@"Daily Forecast";
             cell.viewCellFrame=viewFrame;
        }
    }
   // cell.viewCellFrame=viewFrame;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //  Determine cell height based on screen
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight /(CGFloat)cellCount;

}



- (UIStatusBarStyle)preferredStatusBarStyle {
   return UIStatusBarStyleLightContent;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 获取滚动视图的高度和内容偏移量。与0偏移量做比较，因此试图滚动table低于初始位置将不会影响模糊效果。
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    //通过滚动的量来区分下拉刷新和翻页，因为 翻页效果会影响下拉的延时效果
    if (position>100.0) {
        self.tableView.pagingEnabled = YES;
    }else {self.tableView.pagingEnabled = NO;}
    // 偏移量除以高度，并且最大值为1，所以alpha上限为1。
    CGFloat percent = MIN(position / height, 1.0);
    // 当你滚动的时候，把结果值赋给模糊图像的alpha属性，来更改模糊图像。
    self.blurredImageView.alpha = percent;
}







/** It's not necessary, but better doing like so */
- (BOOL)shouldAutorotate
{
    return !self.refreshView.isRefreshing;
}


#pragma mark -

- (void)RefreshAction
{
    self.tableView.contentOffset = CGPointMake(0.0, -80.0); //实现下拉效果，注意位移点的y值为负值
    
    [self.refreshView triggerAnimated:YES];
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
