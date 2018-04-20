//
//  RJViewController.m
//  RJPageView
//
//  Created by RylanJIN on 03/13/2017.
//  Copyright (c) 2017 RylanJIN. All rights reserved.
//

#import "RJViewController.h"
#import "RJPageViewController.h"
#import "Masonry.h"

@interface RJViewController () <RJPageDataSource>

@property (nonatomic, strong) NSMutableArray       *shopContents;
@property (nonatomic, strong) RJPageViewController *pageViewController;
@property (nonatomic, strong) NSMutableArray       *categoryDisplayNames;

@end

@implementation RJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor redColor]];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.categoryDisplayNames = @[@"RYAN", @"NICO", @"STEPHEN", @"MICHAEL", @"ERIC"].mutableCopy;
    
    RJPageViewController *pageViewController = [RJPageViewController new];
    pageViewController.dataSource = self;
    pageViewController.tabFont    = [UIFont fontWithName:@"HelveticaNeue" size:14.f];
    
    [self addChildViewController:pageViewController];
    [self.view addSubview:pageViewController.view];
    
    [pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [pageViewController didMoveToParentViewController:self];
    
    [self setPageViewController:pageViewController];
    
    [self.view layoutIfNeeded]; // huge trick here!!!
    
    self.shopContents = [NSMutableArray array];
    
    for (int i = 0; i < [self.categoryDisplayNames count]; i++) {
        UIViewController *shopContent = [UIViewController new];
        [shopContent.view setBackgroundColor:[self randomColor]];
        [self.shopContents addObject:shopContent];
    }
    [self.pageViewController reloadData];
}

- (NSUInteger)defaultIndex:(RJPageViewController *)viewPage{
    return 4;
}

- (NSUInteger)numberOfTabsForViewPage:(RJPageViewController *)viewPage
{
    return self.categoryDisplayNames.count;
}

- (NSString *)viewPage:(RJPageViewController *)viewPage titleForTabAtIndex:(NSUInteger)index
{
    if (index >= self.categoryDisplayNames.count){
        return nil;
    }
    
    return self.categoryDisplayNames[index];
}

- (UIViewController *)viewPage:(RJPageViewController *)viewPage contentViewControllerForTabAtIndex:(NSUInteger)index
{
    if (index >= self.shopContents.count) {
        return nil;
    }
    
    return self.shopContents[index];
}

- (UIColor *)randomColor
{
    float hue        = ( arc4random() % 256 / 256.0 );        //  0.0 to 1.0
    float saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    float brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
