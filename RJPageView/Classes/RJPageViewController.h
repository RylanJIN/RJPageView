//
//  RJPageViewController.h
//  FlawlessFace
//
//  Created by Ryan Jin on 1/8/16.
//
//

#import <UIKit/UIKit.h>
#import "RJTabView.h"

@class RJPageViewController;

#pragma mark - RJPageDataSource

@protocol RJPageDataSource <NSObject>

- (NSUInteger)numberOfTabsForViewPage:(RJPageViewController *)viewPage;

- (NSString *)viewPage:(RJPageViewController *)viewPage titleForTabAtIndex:(NSUInteger)index;

@optional

- (NSUInteger)defaultIndex:(RJPageViewController *)viewPage;

- (UIView *)viewPage:(RJPageViewController *)viewPage contentViewForTabAtIndex:(NSUInteger)index;

- (UIViewController *)viewPage:(RJPageViewController *)viewPage contentViewControllerForTabAtIndex:(NSUInteger)index;

// Cover view on top of page
- (UIView *)coverViewForviewPage:(RJPageViewController *)viewPage;

- (CGRect)viewPage:(RJPageViewController *)viewPage rectForCoverView:(UIView *)coverView;

@end

#pragma mark - RJPageDelegate

@protocol RJPageDelegate <NSObject>

@optional

- (void)viewPage:(RJPageViewController *)viewPage didSelectedAtIndex:(NSUInteger)index;

@end

#pragma mark - RJPageContentConfiguration

@protocol RJPageContentConfiguration <NSObject>

@optional

- (UIScrollView *)coverScrollView;

@end


@interface RJPageViewController : UIViewController

@property (nonatomic, weak) id<RJPageDataSource> dataSource;
@property (nonatomic, weak) id<RJPageDelegate>   delegate;

@property (nonatomic, assign)           BOOL        preLoad; // default YES
@property (nonatomic, assign)           RJTabStyle  tabStyle;
@property (nonatomic, strong)           UIFont     *tabFont;
@property (nonatomic, assign, readonly) NSUInteger selectedIndex;

- (void)reloadData; // reload all tabs and contents
- (void)selectPageAtIndex:(NSUInteger)index;

@end
