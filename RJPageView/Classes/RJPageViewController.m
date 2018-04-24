//
//  RJPageViewController.m
//  FlawlessFace
//
//  Created by Ryan Jin on 1/8/16.
//
//

#import "RJPageViewController.h"
#import "RJTabView.h"
#import "UIView+RJAutoLayout.h"

static const NSUInteger TAB_VIEW_HEIGHT  = 44;
// static const NSUInteger REUSE_VIEWS_NUM  = 3;

@interface RJPageViewController () <RJTabViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) RJTabView      *tabView;
@property (nonatomic, strong) UIScrollView   *scrollView;
@property (nonatomic, assign) NSInteger      currentPage;
@property (nonatomic, assign) NSUInteger     tabCount;
@property (nonatomic, assign) BOOL           userDragged;
@property (nonatomic, strong) NSMutableArray *pageViews;
@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) UIView         *coverView;

@end

@implementation RJPageViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.preLoad = YES;
        self.tabFont = [UIFont systemFontOfSize:14.f];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.parentViewController) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(coverViewForviewPage:)]) {
        self.coverView   = [self.dataSource coverViewForviewPage:self];
        [self.view addSubview:self.coverView];
    }
    [self.view addSubview:self.tabView];
    [self.view addSubview:self.scrollView];
    
    // [self reloadData];
}

- (void)dealloc {
    [self clearCoverScrollObserver];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    UIViewController *calcVC = self.parentViewController?:self;
    CGFloat overlayLength    = [calcVC.topLayoutGuide length];
    
    CGFloat sWidth  = CGRectGetWidth (self.view.frame);
    CGFloat sHeight = CGRectGetHeight(self.view.frame);
    
    if (calcVC.edgesForExtendedLayout != UIRectEdgeNone) {
        sHeight -= overlayLength;
    }

    if (self.coverView) {
        CGRect rect = CGRectZero;
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(viewPage:rectForCoverView:)]) {
            rect    = [self.dataSource viewPage:self rectForCoverView:self.coverView];
        }
        if (!CGRectEqualToRect(rect, CGRectZero)) {
            [self.coverView setFrame:rect];
            // [self.view addSubview:self.coverView];
            overlayLength += rect.size.height;
        }
    }
    
    CGRect tabRect  = self.tabView.frame;
    if (CGRectEqualToRect(tabRect, CGRectZero)) {
        [self.tabView setFrame:CGRectMake(0,      overlayLength,
                                          sWidth, TAB_VIEW_HEIGHT)];
    }
    
    [self.scrollView setFrame:CGRectMake(0,      overlayLength + TAB_VIEW_HEIGHT,
                                         sWidth, sHeight       - TAB_VIEW_HEIGHT)];
    [self.scrollView setContentSize:CGSizeMake(sWidth  * self.tabCount,
                                               sHeight - TAB_VIEW_HEIGHT)];
    
    CGFloat xOffset = self.currentPage * self.scrollView.frame.size.width;
    self.scrollView.contentOffset               = CGPointMake(xOffset, 0);
    
    if (self.preLoad) {
        [self.pageViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            CGFloat pageHeight     = CGRectGetHeight(self.scrollView.frame);
            [view setFrame:CGRectMake(idx * sWidth, 0, sWidth, pageHeight)];
        }];
    }
}

- (void)reloadData
{
    // dispatch_async(dispatch_get_main_queue(), ^{
    [self.contents removeAllObjects]; [self.pageViews removeAllObjects];
    
    [self.childViewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        [vc willMoveToParentViewController:nil];
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }];
    [self clearCoverScrollObserver];

    self.tabCount  = [self.dataSource numberOfTabsForViewPage:self];
    self.contents  = [NSMutableArray arrayWithCapacity:self.tabCount];
    self.pageViews = [NSMutableArray arrayWithCapacity:self.tabCount];
    
    NSMutableArray *tabTitles = [NSMutableArray array];
    
    for (int i = 0; i < self.tabCount; i++) {
        [self.contents addObject:[NSNull null]];
        [tabTitles addObject:[self.dataSource viewPage:self titleForTabAtIndex:i]];
    }
    
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.width = CGRectGetWidth (self.view.frame)*self.tabCount;
    [self.scrollView setContentSize:contentSize];
    
    if ([self.dataSource respondsToSelector:@selector(defaultIndex:)]) {
        [self.tabView setTabs:tabTitles defalutIndex:[self.dataSource defaultIndex:self]];
    }else{
        [self.tabView setTabs:tabTitles defalutIndex:0];
    }
    // [self reuseTableViewWithID:self.currentPage];
    
    if (self.preLoad) {
        for (int i = 0; i < self.tabCount; i ++) {
            [self loadContentViewControllerAtIndex:i];
        }
        [self.view setNeedsLayout];
    } else {
        [self loadContentViewControllerAtIndex:self.currentPage];
    }
    // });
}

- (void)selectPageAtIndex:(NSUInteger)index
{
    if (index >= self.tabCount) return;
    
    [self.tabView selectTabAtIndex:index];
}

- (void)clearCoverScrollObserver
{
    for (UIViewController *vc in self.childViewControllers) {
        if (self.coverView && [vc conformsToProtocol:@protocol(RJPageContentConfiguration)]) {
            UIScrollView *coverScrollView = nil;
            if ([vc respondsToSelector:@selector(coverScrollView)]) {
                coverScrollView = [(id<RJPageContentConfiguration>)vc coverScrollView];
            }
            [coverScrollView removeObserver:self forKeyPath:@"contentOffset"];
        }
    }
}

#pragma mark - RJTabViewDelegate
- (void)tabView:(RJTabView *)tabView didSelectedAtIndex:(NSUInteger)index
{
    [self loadContentViewControllerAtIndex:index];
    
    self.scrollView.contentOffset = CGPointMake(index * self.scrollView.frame.size.width, 0);
    // [self.scrollView setContentOffset:CGPointMake(index * self.scrollView.frame.size.width, 0.)
                             // animated:NO];
    self.currentPage          = index;
    [self reuseTableViewWithID:index];
    
    [self.delegate viewPage:self didSelectedAtIndex:index];
}

- (void)loadContentViewControllerAtIndex:(NSInteger)index
{
    UIViewController *vc = [self viewControllerAtIndex:index];
    
    if (vc && ![self.childViewControllers containsObject:vc]) {
        [self addChildViewController:vc];
        if (vc.view) {
            [self.scrollView addSubview:vc.view];
            [self.pageViews addObject:vc.view];
        }
        CGFloat pageHeight = CGRectGetHeight(self.scrollView.frame);
        CGFloat sWidth     = CGRectGetWidth (self.view.frame);
        
        [vc.view setFrame:CGRectMake(index * sWidth, 0, sWidth, pageHeight)];
        
        [vc didMoveToParentViewController:self];
        
        if (self.coverView && [vc conformsToProtocol:@protocol(RJPageContentConfiguration)]) {
            UIScrollView *coverScrollView = nil;
            if ([vc respondsToSelector:@selector(coverScrollView)]) {
                coverScrollView = [(id<RJPageContentConfiguration>)vc coverScrollView];
            }
            coverScrollView.scrollsToTop = NO;
             coverScrollView.tag         = index;
            [coverScrollView addObserver:self
                              forKeyPath:@"contentOffset"
                                 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                 context:nil];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    UIScrollView *scrollView = object;
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        if (scrollView.tag  != self.currentPage) {
            return;
        }
        if (self.childViewControllers.count == 0) {
            return;
        }
        CGFloat offset      = scrollView.contentOffset.y;
        CGRect coverRect    = [self.dataSource viewPage:self rectForCoverView:self.coverView];
        UIView *coverView   = (UIView *)self.coverView;
        CGRect frame        = coverView.frame;
        CGFloat coverHeight = MAX(coverRect.size.height - offset, 0) ;
        coverHeight         = MIN(coverHeight, CGRectGetHeight(coverRect));
        
        coverView.frame     = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, coverHeight);

        CGRect tabRect      = self.tabView.frame;
        CGRect scrollRect   = self.scrollView.frame;

        [self.tabView setFrame:CGRectMake(0, coverHeight, tabRect.size.width, tabRect.size.height)];
        [self.scrollView setFrame:CGRectMake(0, coverHeight+44, scrollRect.size.width, scrollRect.size.height)];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.userDragged = YES;
    [self.view setUserInteractionEnabled:NO];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        self.userDragged = NO;
        [self.view setUserInteractionEnabled:YES];

        if (![scrollView isEqual:self.scrollView]) return;
        
        [self didScrollOverNewPage];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.userDragged) return;
    
    CGFloat oldX = self.currentPage * CGRectGetWidth(self.scrollView.frame);
    
    if (oldX != self.scrollView.contentOffset.x) {
        BOOL scrollingTowards = (self.scrollView.contentOffset.x > oldX);
        NSInteger targetIndex = (scrollingTowards) ? self.currentPage + 1 : self.currentPage - 1;
        
        if (targetIndex >= 0 && targetIndex < self.tabCount) {
            CGFloat ratio = (self.scrollView.contentOffset.x - oldX) / CGRectGetWidth(self.scrollView.frame);
            [self.tabView offsetTabViewWithPage:self.currentPage forward:scrollingTowards ratio:ratio];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.userDragged = NO;
    [self.view setUserInteractionEnabled:YES];

    if (![scrollView isEqual:self.scrollView]) return;
    
    [self didScrollOverNewPage];
}

#pragma mark - Private Methods
- (void)didScrollOverNewPage
{
    NSUInteger index = self.scrollView.contentOffset.x/self.view.frame.size.width;
    
    if (self.currentPage == index) return;
    
    self.currentPage = index;
    
    [self.tabView selectTabAtIndex:self.currentPage];
    [self.delegate viewPage:self didSelectedAtIndex:self.currentPage];
    // [self reuseTableViewWithID:_currentPage];
}

- (void)reuseTableViewWithID:(NSUInteger)pageNumber
{
    return; // will not apply reuse mechanism at this point
    /**
    NSMutableArray *notTaged = [NSMutableArray arrayWithArray:self.pageViews];
    NSMutableArray *taged = [NSMutableArray arrayWithArray:@[[NSNull null], [NSNull null], [NSNull null]]];
    
    [self.pageViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        // cases of normal 3 views
        if (view.tag == (pageNumber + 1)) {
            [taged replaceObjectAtIndex:2 withObject:view];
            [notTaged removeObject:view];
        }
        if (view.tag == pageNumber) {
            [taged replaceObjectAtIndex:1 withObject:view];
            [notTaged removeObject:view];
        }
        if (view.tag == (pageNumber - 1)) {
            [taged replaceObjectAtIndex:0 withObject:view];
            [notTaged removeObject:view];
        }
    }];
    
    if ([taged objectAtIndex:0] == [NSNull null]) {
        UIView *view = [notTaged lastObject]; [notTaged removeLastObject];
        if (pageNumber == 0) {
            view.tag = pageNumber - 1; view.frame = CGRectZero;
            [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            if (view) [taged replaceObjectAtIndex:0 withObject:view];
        } else {
            CGRect tableNewFrame = CGRectMake((pageNumber - 1) * self.view.frame.size.width, 0,
                                              self.view.frame.size.width,
                                              self.view.frame.size.height - TAB_VIEW_HEIGHT);
            view.frame = tableNewFrame; view.tag = pageNumber - 1;
            UIView *cView = [self viewControllerAtIndex:(pageNumber - 1)].view;
            [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [cView setFrame:view.bounds]; [view addSubview:cView];
            if (view) [taged replaceObjectAtIndex:0 withObject:view];
        }
    }
    
    if ([taged objectAtIndex:1] == [NSNull null]) {
        UIView *view = [notTaged lastObject]; [notTaged removeLastObject];
        CGRect tableNewFrame = CGRectMake(pageNumber * self.view.frame.size.width, 0,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height - TAB_VIEW_HEIGHT);
        view.frame = tableNewFrame; view.tag = pageNumber;
        UIView *cView = [self viewControllerAtIndex:pageNumber].view;
        [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [cView setFrame:view.bounds]; [view addSubview:cView];
        if (view) [taged replaceObjectAtIndex:1 withObject:view];
    }
    
    if ([taged objectAtIndex:2] == [NSNull null]) {
        UIView *view = [notTaged lastObject]; [notTaged removeLastObject];
        if (pageNumber == (self.tabCount - 1)) {
            view.tag = pageNumber + 1; view.frame = CGRectZero;
            [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            if (view) [taged replaceObjectAtIndex:2 withObject:view];
        } else {
            CGRect tableNewFrame = CGRectMake((pageNumber + 1) * self.view.frame.size.width, 0,
                                              self.view.frame.size.width,
                                              self.view.frame.size.height - TAB_VIEW_HEIGHT);
            view.frame = tableNewFrame; view.tag = pageNumber + 1;
            UIView *cView = [self viewControllerAtIndex:pageNumber + 1].view;
            [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [cView setFrame:view.bounds]; [view addSubview:cView];
            if (view) [taged replaceObjectAtIndex:2 withObject:view];
        }
    }

    [self.pageViews removeAllObjects];
    [self.pageViews addObjectsFromArray:taged];
     */
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (index >= self.tabCount) return nil;
    
    if ([[self.contents objectAtIndex:index] isEqual:[NSNull null]]) {
        UIViewController *viewController = nil;
        if ([self.dataSource respondsToSelector:@selector(viewPage:contentViewControllerForTabAtIndex:)]) {
            viewController = [self.dataSource viewPage:self contentViewControllerForTabAtIndex:index];
        } else if ([self.dataSource respondsToSelector:@selector(viewPage:contentViewForTabAtIndex:)]) {
            UIView *view = [self.dataSource viewPage:self contentViewForTabAtIndex:index];
            // Adjust view's bounds to match the pageView's bounds
            view.frame   = self.scrollView.bounds;
            viewController      = [UIViewController new];
            viewController.view = view;
        } else {
            viewController = [[UIViewController alloc] init];
            viewController.view = [[UIView alloc] init];
        }
        if (viewController) {
            [self.contents replaceObjectAtIndex:index withObject:viewController];
        } else {
            return nil; // fetch nil viewController
        }
    }
    return [self.contents objectAtIndex:index];
}

- (NSUInteger)indexForViewController:(UIViewController *)viewController {
    return [self.contents indexOfObject:viewController];
}

#pragma mark - Getters
- (RJTabView *)tabView
{
    if (!_tabView) {
        _tabView          = [RJTabView new];
        _tabView.tabFont  = self.tabFont;
        _tabView.tabStyle = self.tabStyle;
        [_tabView setDelegate:self];
    }
    return _tabView;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.showsHorizontalScrollIndicator = NO;
        [_scrollView setBackgroundColor:[UIColor clearColor]];
        [_scrollView setPagingEnabled:YES];
        [_scrollView setDelegate:self];
        [_scrollView setBounces:NO];
    }
    return _scrollView;
}

- (NSUInteger)selectedIndex {
    return self.currentPage;
}

@end
