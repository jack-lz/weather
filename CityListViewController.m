//
//  CityListViewController.m
//  weather
//
//  Created by lz-jack on 8/23/15.
//  Copyright (c) 2015 lz-jack. All rights reserved.
//



#import "WXManager.h"
#import "WXController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "CityListViewController.h"
#import "AppDelegate.h"


#define CHECK_TAG 1100
#define NavigationbarHeight 64


@interface CityListViewController()

@property NSUInteger curSection;
@property NSUInteger curRow;
@property NSUInteger defaultSelectionRow;
@property NSUInteger defaultSelectionSection;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchController  *searchDc;
@property (nonatomic, strong) NSString *locationCity;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIImageView *checkImgView;
@property (nonatomic, strong) NSDictionary *cities;
@property (nonatomic, strong) NSArray *keys;
@property (nonatomic, strong) NSArray *volues;
@property (nonatomic, strong) NSArray *searchResultsCity;//搜索中间结果
@property (nonatomic, strong) NSMutableArray *volue;
@property (nonatomic, strong) NSMutableArray *searchResults;//用与保存搜索结果，可变数组
@property (nonatomic, strong) WXLocation *locationManager;

@end


@implementation CityListViewController

- (id) init
{
    if (self = [super init])//
    {
        // 创建一个位置管理器，并设置它的delegate为self。
        self.locationManager = [[WXLocation alloc] init];
        self.locationManager.delegate = self;
        [self addObserver:self forKeyPath:@"locationCity" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"locationCity" context:nil];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*****************设置导航栏********************/
    UIBarButtonItem *barBtn1 = [[UIBarButtonItem alloc]initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(goToSearch:)];
    self.navigationItem.rightBarButtonItem = barBtn1;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self.navigationItem setTitle:@"Choose City"];
    UIImage *background = [UIImage imageNamed:@"bp"];
    //创建一个静态的背景图，并添加到视图上。
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    //添加搜索栏
    self.searchDc = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchDc.searchResultsUpdater = self;
    self.searchDc.dimsBackgroundDuringPresentation = NO;//展示搜索结果时是否去掉底板，若是 yes，搜索结果就无法选择了
    self.searchDc.hidesNavigationBarDuringPresentation = NO;//搜索时是否隐藏NavigationBar
    self.definesPresentationContext = YES;
    
    //设置searchBar格式并添加到 tableheader
    self.searchDc.searchBar.backgroundColor = [UIColor clearColor];
    self.searchDc.searchBar.tintColor = [UIColor blackColor];
    self.searchDc.searchBar.delegate = self;
    self.searchDc.searchBar.placeholder = @"Please input city name...";
    self.searchDc.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;//自动纠错类型
    self.searchDc.searchBar.showsCancelButton = NO;// 默认情况不显示cancel 按钮
    [self.searchDc.searchBar sizeToFit];//添加搜索框到页眉位置
    //获取屏幕的框架,创建tableview来处理所有的数据呈现。
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.7 alpha:0.8];//颜色和透明度
    self.tableView.scrollEnabled = YES;
    self.tableView.sectionIndexColor = [UIColor redColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor grayColor];
    /*下面是把 searchbar 作为tableview 的 header，这样做的坏处是，不能通过其他 button 调用 searchbar 了，
     还有就是把 searcher 独立出来，这样就不能一起滚动，而且不能隐藏了*/
    // self.tableView.tableHeaderView = self.searchDc.searchBar;
    /*采用先建立一个 tableviewheader，然后把 searchbar 添加上去，这样最好，没有什么问题,
    还有一个额外的好处，当在顶端下拉时，填充使用的是 tableview 的背景，而不是 searchbar 的背景，这样可以设置为透明了。*/
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.searchDc.searchBar.bounds.size.height)];
     self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
    [self.tableView.tableHeaderView addSubview:self.searchDc.searchBar];
    [self.view addSubview:self.tableView];
    //创建 NSdictionary从 citydict.plist中获取 city数据,并取出所有的key
    NSString *path = [[NSBundle mainBundle] pathForResource:@"citydict" ofType:@"plist"];
    self.cities = [[NSDictionary alloc]  initWithContentsOfFile:path];
    self.keys = [[_cities allKeys] sortedArrayUsingSelector: @selector(compare:)];
    self.volues = [_cities allValues] ;
    self.volue = [[NSMutableArray alloc] init];
    [self ArrayTransformar:self.volues TO:self.volue];
    self.curRow = NSNotFound;
    //开始定位
    [self.locationManager  startUpdatingLocation];
}


//你的视图控制器调用该方法来编排其子视图。
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect bounds = self.view.bounds;
    self.backgroundImageView.frame = bounds;
    //将tableview 下移
    if(self.searchDc.active)
    {
        self.tableView.frame = CGRectMake(bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);
    }
    else
    {
        self.tableView.frame = CGRectMake(bounds.origin.x,bounds.origin.y+NavigationbarHeight,bounds.size.width,bounds.size.height-NavigationbarHeight);
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if(self.searchDc.active)
    {
        self.searchDc.active = NO;
    }
    [self.navigationController setNavigationBarHidden:YES animated:YES];

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{   // 除了上下颠倒，都支持
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


#pragma KVOFunction
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"locationCity"])
    {
        [self.tableView reloadData];
    }
    else
    {
        //若当前类无法捕捉到这个KVO，那很有可能是在他的superClass，或者super-superClass...中
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - WXLocationDelegate

- (void)updateLocation:(CLLocation *)location
{  
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    __weak typeof (self) wself = self;
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
        for (CLPlacemark * placemark in placemarks)
        {
            wself.locationCity = [placemark locality];
        }
     }];
}


#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfSection = [_keys count];
    if(self.searchDc.active)
    {
        numberOfSection = 1;
    }
    return numberOfSection;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [_keys objectAtIndex:section];
    NSInteger citySectionNumber = [[_cities objectForKey:key] count];
    if(self.searchDc.active)
    {
        citySectionNumber = [_searchResults count];
    }
    return citySectionNumber;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [_keys objectAtIndex:indexPath.section];
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    // 先判断是原 view 还是搜索 view
    if(self.searchDc.active)
    {
        if([_searchResults count] == 0 )
        {
            cell.textLabel.text = nil;
        }
        else
        {
            cell.textLabel.text = [_searchResults objectAtIndex:indexPath.row];
            cell.imageView.image = nil;
        }
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    else
    {
        //再判断是不是第一 section 的第一个，是就显示定位图片。
        if(indexPath.section == 0 && indexPath.row == 0)
        {
            if (self.locationCity !=nil)
            {
                cell.textLabel.text = self.locationCity;
                cell.imageView.image = [UIImage imageNamed:@"dw"];
            }
            else
            {
                cell.textLabel.text = @"loading";
                cell.imageView.image = [UIImage imageNamed:@"dw"];
            }
            cell.textLabel.textColor = [UIColor magentaColor];
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
        else
        {
            cell.textLabel.text = [[_cities objectForKey:key] objectAtIndex:indexPath.row];
            cell.imageView.image = nil;
            cell.textLabel.textColor = [UIColor whiteColor];
        }
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 33;
}


#pragma tableView delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *titleOfHeader = @"loading";
    if(self.searchDc.active)
    {
        titleOfHeader = nil;
    }
    return titleOfHeader;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(-40, 0, tableView.bounds.size.width, 40)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(6, 3, tableView.bounds.size.width - 10, 34)] ;
    label.textColor = [UIColor colorWithRed:0.3 green:0.4 blue:0.8 alpha:0.8];
    label.backgroundColor = [UIColor clearColor];
    NSString *key = [_keys objectAtIndex:section];
    if(!self.searchDc.active)
    {
          if(section == 0 )
          {
              label.text = @"Current City:";
              label.textColor = [UIColor blueColor];
              label.textAlignment = NSTextAlignmentLeft;
              label.font = [UIFont fontWithName:@"Georgia-Bold" size:18];
              [headerView addSubview:label];
          }
          else
          {
              label.text = key;
              label.font = [UIFont fontWithName:@"Georgia-Bold" size:26];
              label.textAlignment = NSTextAlignmentLeft;
              [headerView addSubview:label];
          }
    }
    else
    {   //添加“搜索结果”到headerview 上去。
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(6, 3, tableView.bounds.size.width - 10, 34)] ;
        label.textColor = [UIColor colorWithRed:0.3 green:0.4 blue:0.8 alpha:0.8];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"搜索结果";//设置分组标题
        label.font = [UIFont fontWithName:@"Georgia-Bold" size:23];
        label.textAlignment = NSTextAlignmentCenter;
        [headerView addSubview:label];
    }
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView ;
}


/****************设置右侧索引栏目*****************/
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSArray *sectionIndexTitles =_keys;
    if(self.searchDc.active)
    {
        sectionIndexTitles = nil;
    }
    return sectionIndexTitles;
}


#pragma mark - searchController delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [_searchResults removeAllObjects];
    NSPredicate *searchString = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", self.searchDc.searchBar.text];
    _searchResultsCity = [[_volue  filteredArrayUsingPredicate:searchString] mutableCopy];
    _searchResults=[NSMutableArray arrayWithCapacity:30];
    for (NSString *object in _searchResultsCity)
    {
        [_searchResults addObject:object];
    }
    //这个是异步执行，将右边的参数（任务）提交给左边的参数（队列）进行执行。同步：在当前线程中执行，异步：在另一条线程中执行
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{ [wself.tableView reloadData]; });
}


- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.searchDc];
}


-(void)ArrayTransformar:(NSArray *)volues TO:(NSMutableArray *)volue
{
    for (NSArray *object1 in volues)
    {
        for (NSArray *object2 in object1)
        {
            [volue addObject:object2];
        }
    }
}


- (void)goToSearch:(id)sender
{
    [self.searchDc.searchBar becomeFirstResponder];
}


#pragma mark - Table view delegate--select
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _curSection = indexPath.section;
    _curRow = indexPath.row;
    //pop to the previous view
    [self ReturnSelectCity];
}


- (void)ReturnSelectCity
{
    //带前一页面默认标记功能时，需要判断curRow，若是没找到，而且没选择新的 city 就返回，那就不返回city 值。
    if(self.searchDc.active)
    {
        [_delegate citySelectionUpdate:[_searchResults objectAtIndex:_curRow]];
    }
    else
    {
        if(_curSection == 0 && _curRow == 0)
        {
            [_delegate citySelectionUpdate:self.locationCity];
        }
        else
        {
            NSString *key = [_keys objectAtIndex:_curSection];
            [_delegate citySelectionUpdate:[[_cities objectForKey:key] objectAtIndex:_curRow]];
        }
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end



