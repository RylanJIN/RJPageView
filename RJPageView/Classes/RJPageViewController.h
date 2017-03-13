//
//  RJPageViewController.h
//  FlawlessFace
//
//  Created by Ryan Jin on 1/8/16.
//
//

#import <UIKit/UIKit.h>

@class RJPageViewController;

#pragma mark - RJPageDataSource
@protocol RJPageDataSource <NSObject>

- (NSUInteger)numberOfTabsForViewPage:(RJPageViewController *)viewPage;
- (NSString *)viewPage:(RJPageViewController *)viewPage titleForTabAtIndex:(NSUInteger)index;

@optional
- (NSUInteger)defaultIndex:(RJPageViewController *)viewPage;
- (UIViewController *)viewPage:(RJPageViewController *)viewPage contentViewControllerForTabAtIndex:(NSUInteger)index;
- (UIView *)viewPage:(RJPageViewController *)viewPage contentViewForTabAtIndex:(NSUInteger)index;

@end

#pragma mark - RJPageDelegate
@protocol RJPageDelegate <NSObject>

@optional

- (void)viewPage:(RJPageViewController *)viewPage didSelectedAtIndex:(NSUInteger)index;

@end

@interface RJPageViewController : UIViewController

@property (nonatomic, weak) id<RJPageDataSource> dataSource;
@property (nonatomic, weak) id<RJPageDelegate>   delegate;

@property (nonatomic, strong)           UIFont     *tabFont;
@property (nonatomic, assign, readonly) NSUInteger selectedIndex;

- (void)reloadData; // reload all tabs and contents
- (void)selectPageAtIndex:(NSUInteger)index;

@end
