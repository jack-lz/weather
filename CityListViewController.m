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

@interface CityListViewController()
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (strong, nonatomic) UISearchController  *searchDc;
@property (nonatomic, strong) NSString* defaultCity;
@property (nonatomic, retain) UIImageView *checkImgView;
@property NSUInteger curSection;
@property NSUInteger curRow;
@property NSUInteger defaultSelectionRow;
@property NSUInteger defaultSelectionSection;
@property (nonatomic, retain) NSDictionary *cities;
@property (nonatomic, retain) NSArray *keys;
@property (nonatomic, retain) NSArray *volues;
@property (nonatomic, retain) NSMutableArray *volue;
@property (nonatomic, retain) NSMutableArray *searchResults;//用与保存搜索结果，可变数组
@end


@implementation CityListViewController

NSArray *searchResultsCity;//搜索中间结果

#define CHECK_TAG 1100
#define NavigationbarHeight 64

@synthesize cities, keys, checkImgView, curSection, curRow, delegate,searchDc;
@synthesize defaultSelectionRow, defaultSelectionSection;


- (id) init
{
    self = [super init];
  
    if (self) {
       
    }
    return self;
  
  
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*****************设置导航栏********************/
  
    UIBarButtonItem *barBtn1=[[UIBarButtonItem alloc]initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(goToSearch:)];
    self.navigationItem.rightBarButtonItem=barBtn1;
    
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    //设置导航条背景颜色，也是半透明玻璃状的颜色效果
   // self.navigationController.navigationBar.backgroundColor=[UIColor clearColor];
   // self.navigationController.navigationBar.frame = CGRectMake(self.view.bounds.origin.x,self.view.bounds.origin.y,self.view.bounds.size.width,30);
    [self.navigationItem setTitle:@"Choose City"];
    
    
   
     UIImage *background = [UIImage imageNamed:@"bp"];
    // 创建一个静态的背景图，并添加到视图上。
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    // 使用LBBlurredImage来创建一个模糊的背景图像,设置alpha为0则透明显示下面的backgroundImageView。
    self.blurredImageView = [[UIImageView alloc] initWithImage:background];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha =0;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    [self.view  addSubview:self.blurredImageView];
    
  //添加搜索栏
    self.searchDc.searchBar.scopeButtonTitles = @[NSLocalizedString(@"ScopeButtonCountry",@"Country"),
                                                          NSLocalizedString(@"ScopeButtonCapital",@"Capital")];
    
    self.searchDc= [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchDc.searchResultsUpdater = self;
    self.searchDc.dimsBackgroundDuringPresentation = NO;//展示搜索结果时是否去掉底板，若是 yes，搜索结果就无法选择了
    self.searchDc.hidesNavigationBarDuringPresentation = YES;//搜索时是否隐藏NavigationBar
    self.definesPresentationContext = YES;//Finally since the search view covers the table view when active we make the table view controller define the presentation context
    [self.searchDc.searchBar sizeToFit];
    //设置searchBar格式并添加到 tableheader
    self.searchDc.searchBar.backgroundColor = [UIColor clearColor];
    self.searchDc.searchBar.tintColor=[UIColor blackColor];
    self.searchDc.searchBar.delegate = self;
    self.searchDc.searchBar.placeholder=@"Please input key word...";
    self.searchDc.searchBar.autocorrectionType=UITextAutocorrectionTypeNo;//自动纠错类型
    self.searchDc.searchBar.showsCancelButton=NO;// Don't show the scope bar or cancel button until editing begins
    //添加搜索框到页眉位置
    // 获取屏幕的框架，创建tableview来处理所有的数据呈现。
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.7 alpha:0.8];
    self.tableView.scrollEnabled = YES;
    //改变索引文本的颜色
    self.tableView.sectionIndexColor = [UIColor redColor];
     //改变索引的背景
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    //改变索引选中时的背景颜色
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor grayColor];
    /*下面是把 searchbar 作为tableview 的 header，这样做的坏处是，不能通过其他 button 调用 searchbar 了，
     还有就是把 searcher 独立出来，这样就不能一起滚动，而且不能隐藏了*/
    //self.tableView.tableHeaderView = self.searchDc.searchBar;
    /*采用先建立一个 tableviewheader，然后把 searchbar 添加上去，这样最好，没有什么问题,
    还有一个额外的好处，当在顶端下拉时，填充使用的是 tableview 的背景，而不是 searchbar 的背景，这样可以设置为透明了。*/
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.searchDc.searchBar.bounds.size.height)];
     self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
    [self.tableView.tableHeaderView addSubview:self.searchDc.searchBar];
    
     // Hide the search bar until user scrolls up
    CGRect newBounds = [[self tableView] bounds];
    newBounds.origin.y = newBounds.origin.y +  self.searchDc.searchBar.bounds.size.height;
    [[self tableView] setBounds:newBounds];
    
    [self.view addSubview:self.tableView];
  
    
    //******使用自定义的 check mark ,***************//
    //创建 UIImagrView 保存选择标志图像
    //self.checkImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check"]];
    //checkImgView.tag = CHECK_TAG;
   
    
    //创建 NSdictionary从 citydict.plist中获取 city数据,并取出所有的key
    NSString *path=[[NSBundle mainBundle] pathForResource:@"citydict" ofType:@"plist"];
    self.cities = [[NSDictionary alloc]  initWithContentsOfFile:path];
    self.keys = [[cities allKeys] sortedArrayUsingSelector: @selector(compare:)];
    self.volues=[cities allValues] ;
    
    self.volue = [[NSMutableArray alloc] init];
    [self ArrayTransformar:self.volues TO:self.volue];
   
    
    //get default selection from delegate
    self.defaultCity = [delegate getDefaultCity];
    if (self.defaultCity==nil) {
        self.defaultCity=@"loading";
    }
    
     self.curRow = NSNotFound;
    /*************以下是可以在 tableview中找到defaultCity，并翻到那一页，标记它，若没有，就保留curRow = NSNotFound，返回上一界面***************/
//    if (defaultCity) {
//        NSArray *citySection;
//        self.defaultSelectionRow = NSNotFound;
//        //set table index to this city if it existed
//        for (NSString* key in keys) {
//            citySection = [cities objectForKey:key];
//            self.defaultSelectionRow = [citySection indexOfObject:defaultCity];
//            if (NSNotFound == defaultSelectionRow)
//                continue;
//            //found match recoard position
//            self.defaultSelectionSection = [keys indexOfObject:key];
//            break;
//        }
//        
//        if (NSNotFound != defaultSelectionRow) {
//            
//            self.curSection = defaultSelectionSection;
//            self.curRow = defaultSelectionRow;
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:defaultSelectionRow inSection:defaultSelectionSection];
//            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//            
//        }
//    }
}

//在WXController.m中，你的视图控制器调用该方法来编排其子视图。
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
  //将tableview 下移
      if(self.searchDc.active){
          self.tableView.frame=CGRectMake(bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);}
      else{self.tableView.frame=CGRectMake(bounds.origin.x,bounds.origin.y+NavigationbarHeight,bounds.size.width,bounds.size.height);}
    
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.keys = nil;
    self.cities = nil;
    self.checkImgView = nil;
    self.tableView = nil;
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


 //   self.navigationController.navigationBar.hidden = YES;
    
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
   if(self.searchDc.active){
       self.searchDc.active = NO;}
  [self.searchDc.searchBar removeFromSuperview];
   
   [self.navigationController setNavigationBarHidden:YES animated:YES];

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
     if(self.searchDc.active)
    {
        return 1;
    } else {
        return [keys count];// Return the number of sections.
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.一般 tableheadwer和 sectionheader是不显示的，本例中显示了 sectionheader，在 WXController.m中只显示了 tableheader，使用 section 的第一行作为 sectionheader。
    NSString *key = [keys objectAtIndex:section];
    NSArray *citySection = [cities objectForKey:key];
     if(self.searchDc.active)
    {
        return [_searchResults count];
    } else {
      return [citySection count];    }
   
  
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   
    //首先根据标识去缓存池取
    static NSString *CellIdentifier = @"CellIdentifier";
    NSString *key = [keys objectAtIndex:indexPath.section];
     //如果缓存池没有取到则重新创建并放到缓存池中
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    } else {
        /**********使用自定义的 check mark ***************/
//         for (UIView *view in cell.contentView.subviews) {
//         if (view.tag == CHECK_TAG) {
//         if (indexPath.section == curSection && indexPath.row == curRow)
//         checkImgView.hidden = false;
//         else
//         checkImgView.hidden = true;
//         }
//         }
    }
    
    // Configure the cell...
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.textLabel.textColor = [UIColor whiteColor];
   // 先判断是原 view 还是搜索 view
     if(self.searchDc.active)
     {
        
        cell.textLabel.text = [_searchResults objectAtIndex:indexPath.row];
        cell.imageView.image = nil;
         //添加“搜索结果”到 tableview 的headerview 上去。
         UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(6, 3, tableView.bounds.size.width - 10, 34)] ;
         label.textColor = [UIColor colorWithRed:0.3 green:0.4 blue:0.8 alpha:0.8];
         label.backgroundColor = [UIColor clearColor];
         label.text =@"搜索结果";//设置分组标题
         label.font = [UIFont fontWithName:@"Georgia-Bold" size:23];
         label.textAlignment = NSTextAlignmentCenter;
         [self.tableView.tableHeaderView addSubview:label];

         
     }
     else
     {   cell.textLabel.text = [[cities objectForKey:key] objectAtIndex:indexPath.row];
         //再判断是不是第一 section 的第一个，是就显示定位图片。
         if(indexPath.section == 0 && indexPath.row == 0){
             cell.imageView.image = [UIImage imageNamed:@"dw"];
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
             cell.textLabel.textColor = [UIColor magentaColor];
         }
         else{cell.imageView.image = nil;
             cell.textLabel.textColor = [UIColor whiteColor];
             }
         
      }
    
   
    
    
      /**********使用系统自带的 check mark ，主要再界面滚动时，刷新时保留标记***************/
    if (indexPath.section == curSection && indexPath.row == curRow)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}

/********************设置 sectionheader*********************/
//启用sectionheader
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if(self.searchDc.active)
   {
    return nil;
    }
  else
    {
  return @"loading";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(self.searchDc.active){return 1;
    }
    return 40;
}
//自定义view
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(-40, 0, tableView.bounds.size.width, 40)];
    
  //  这是改变文本颜色的方法：
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(6, 3, tableView.bounds.size.width - 10, 34)] ;
  
    label.textColor = [UIColor colorWithRed:0.3 green:0.4 blue:0.8 alpha:0.8];
    label.backgroundColor = [UIColor clearColor];
    NSString *key = [keys objectAtIndex:section];
    
     if(!self.searchDc.active)
    {
          if(section == 0 ){
          label.text =[@"Current City: " stringByAppendingString:self.defaultCity];
          label.textColor = [UIColor blackColor];
          label.textAlignment = NSTextAlignmentCenter;
          label.font = [UIFont fontWithName:@"Georgia-Bold" size:18];
          [headerView addSubview:label];
          }else{
          label.text =key;
          label.font = [UIFont fontWithName:@"Georgia-Bold" size:26];
          label.textAlignment = NSTextAlignmentLeft;
          [headerView addSubview:label];
          }
         }
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView ;
  
}

/****************设置右侧索引栏目*****************/
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    
     if(self.searchDc.active)
    {
        return nil;
    }
    else
    {
         return keys;
    }
}


#pragma mark - searchController delegate
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [_searchResults removeAllObjects];
    NSPredicate *searchString = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", self.searchDc.searchBar.text];
    searchResultsCity = [[_volue  filteredArrayUsingPredicate:searchString] mutableCopy];
    _searchResults=[NSMutableArray arrayWithCapacity:30];
    
    for (NSString *object in searchResultsCity)
    {
        [_searchResults addObject:object];
    }
    dispatch_async(dispatch_get_main_queue(), ^{  [self.tableView reloadData];  });
}


- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.searchDc];
}


-(void)ArrayTransformar:(NSArray *)volues TO:(NSMutableArray *)volue
{
    
    for (NSArray *object1 in volues)
    { for (NSArray *object2 in object1)
    {
        [volue addObject:object2];
        
    }
    }
    
}


- (void)goToSearch:(id)sender
{
    
    // Note that if you didn't hide your search bar, you should probably not include this, as it would be redundant
    [self.searchDc.searchBar becomeFirstResponder];
}


#pragma mark - Table view delegate--select
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /**********使用系统自带的 check mark ***************/
    //clear previous
    NSIndexPath *prevIndexPath = [NSIndexPath indexPathForRow:curRow inSection:curSection];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:prevIndexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    curSection = indexPath.section;
    curRow = indexPath.row;
    //add new check mark
    cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    /**********使用自定义的 check mark ***************/
    //     //clear previous selection first
    //     [checkImgView removeFromSuperview];
    //
    //     //add new check mark
    //     UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    //
    //     //make sure the image size is fit for cell height;
    //
    //     CGRect cellRect = cell.bounds;
    //     float imgHeight = cellRect.size.height * 2 / 3; // 2/3 cell height
    //     float imgWidth = 20.0; //hardcoded
    //
    //
    //     checkImgView.frame = CGRectMake(cellRect.origin.x + cellRect.size.width - 100, //shift for index width plus image width
    //     cellRect.origin.y + cellRect.size.height / 2 - imgHeight / 2,
    //     imgWidth,
    //     imgHeight);
    //
    //     [cell.contentView addSubview:checkImgView];
    //     checkImgView.hidden = false;
    
    
    /**********Navigation logic may go here. Create and push another view controller*************/
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
     
    
     //pop to the previous view
   [self ReturnSelectCity];
}



- (void)ReturnSelectCity {
    //带前一页面默认标记功能时，需要判断curRow，若是没找到，而且没选择新的 city 就返回，那就不返回city 值。
    
    if(self.searchDc.active){
        [delegate citySelectionUpdate:[_searchResults objectAtIndex:curRow]];
    }
    else{ NSString* key = [keys objectAtIndex:curSection];
        [delegate citySelectionUpdate:[[cities objectForKey:key] objectAtIndex:curRow]];
    }
    //  [self.navigationController didMoveToParentViewController:];
       [self.navigationController popToRootViewControllerAnimated:YES];//返回根目录。
    
}
@end



