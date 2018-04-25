//
//  RJTabView.m
//  TabPageDemo
//
//  Created by Ryan Jin on 1/5/16.
//  Copyright © 2016 ArcSoft. All rights reserved.
//

#import "RJTabView.h"
#import "RJTabCell.h"
#import "UIColor+RJExtension.h"
#import "UIView+RJAutoLayout.h"

NSString * const CELL_ID = @"TabCell";

static const NSUInteger MIN_ITEM_WIDHT = 90;

@interface RJTabView() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *tabs;
@property (nonatomic, strong) UIView  *indicator;
@property (nonatomic, assign) CGFloat oriOffsetX;
@property (nonatomic, assign) CGFloat oriIndicateX;
@property (nonatomic, assign) BOOL    userDragged;

@end

@implementation RJTabView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self =  [super initWithCoder:aDecoder];
    if (self) {
        [self setupViewComponents];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViewComponents];
    }
    return self;
}

- (void)setupViewComponents
{
    self.backgroundColor = [UIColor colorWithValue:@"#ffffff" alpha:1.f];
    
    [self addSubview:self.collectionView];
    [self addSubview:self.indicator];
    
    [self layoutPageSubviews];
}

- (void)layoutPageSubviews
{
    // collectionView autolayout
    [self addConstraints:[self.collectionView constraintsTopInContainer:0]];
    [self addConstraints:[self.collectionView constraintsLeftInContainer:0]];
    [self addConstraints:[self.collectionView constraintsRightInContainer:0]];
    [self addConstraints:[self.collectionView constraintsBottomInContainer:0]];
}

#pragma mark - TabView Selection
- (void)setTabs:(NSArray *)tabs defalutIndex:(NSUInteger)index
{
    self.tabs          = [NSArray arrayWithArray:tabs];
    self.selectedIndex = index;
    
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];

    NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
    [self.collectionView selectItemAtIndexPath:path
                                      animated:NO
                                scrollPosition:(UICollectionViewScrollPositionNone)];
    UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout
                                                    layoutAttributesForItemAtIndexPath:path];
    BOOL plainMode = self.tabStyle == RJTabStylePlain;
    CGFloat tabY   = plainMode ? 30. : 41;
    CGFloat tabH   = plainMode ? 1.5 : 3.;
    CGFloat tabX   = CGRectGetMinX (attributes.frame);
    CGFloat tabW   = CGRectGetWidth(attributes.frame);
    
    if (plainMode) {
        CGFloat fontWidth = [self stringSize:self.tabs[index]
                                       frame:CGSizeMake(CGRectGetWidth(self.bounds), 44)
                                        font:self.tabFont].width;
        tabW              = MIN(fontWidth, tabW);
        tabX             += (CGRectGetWidth(attributes.frame) - tabW) / 2.f;
    }
    self.indicator.frame = CGRectMake(tabX, tabY, tabW, tabH);
    if ([self.delegate respondsToSelector:@selector(tabView:didSelectedAtIndex:)]) {
        [self.delegate tabView:self didSelectedAtIndex:self.selectedIndex];
    }
}

- (void)selectTabAtIndex:(NSUInteger)index
{
    NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
    [self.collectionView selectItemAtIndexPath:path
                                      animated:NO
                                scrollPosition:(UICollectionViewScrollPositionNone)];

    [self scrollTabAndIndicatorToIndex:index animate:NO];
    
    if ([self.delegate respondsToSelector:@selector(tabView:didSelectedAtIndex:)]) {
        [self.delegate tabView:self didSelectedAtIndex:self.selectedIndex];
    }
}

- (void)scrollTabAndIndicatorToIndex:(NSInteger)idx animate:(BOOL)animate
{
    NSUInteger oriIdx  = self.selectedIndex; self.selectedIndex = idx;
    
    [UIView animateWithDuration:animate?.3f:0.f animations:^{
        NSInteger targetIndex = idx; NSInteger index = oriIdx;
        
        CGFloat previousItemContentOffsetX = [self contentOffsetForSelectedItemAtIndex:index].x;
        CGFloat nextItemContentOffsetX     = [self contentOffsetForSelectedItemAtIndex:targetIndex].x;
        CGFloat previousItemPageIndicatorX = [self centerForSelectedItemAtIndex:index].x;
        CGFloat nextItemPageIndicatorX     = [self centerForSelectedItemAtIndex:targetIndex].x;
        CGFloat previousItemWidth          = [self widthForSelectedItemAtIndex:index];
        CGFloat nextItemWidth              = [self widthForSelectedItemAtIndex:targetIndex];
        
        CGFloat sOffset = (nextItemContentOffsetX - previousItemContentOffsetX);
        self.collectionView.contentOffset = CGPointMake(previousItemContentOffsetX + sOffset , 0.);
        
        CGFloat iWidth   = nextItemWidth - previousItemWidth;
        CGFloat tOffset  = (nextItemContentOffsetX - previousItemContentOffsetX);
        CGRect fRect     = self.indicator.frame;
        CGFloat cOffset  = self.collectionView.contentOffset.x - previousItemContentOffsetX;
        if (tOffset == 0) tOffset = 1;
        fRect.size.width = previousItemWidth + (cOffset * iWidth) / tOffset;

        [self.indicator setFrame:fRect];
        
        CGFloat iOffset = (nextItemPageIndicatorX - previousItemPageIndicatorX);
        self.indicator.center = CGPointMake(previousItemPageIndicatorX + iOffset, self.indicator.center.y);
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.userDragged) return;

    CGFloat center = self.oriIndicateX - (scrollView.contentOffset.x - self.oriOffsetX);
    [self.indicator setCenter:CGPointMake(center, self.indicator.center.y)];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.userDragged  = YES;

    self.oriIndicateX = self.indicator.center.x;
    self.oriOffsetX   = scrollView.contentOffset.x;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) self.userDragged = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.userDragged = NO;
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.tabs count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RJTabCell *cell      = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID
                                                                     forIndexPath:indexPath];
    cell.titleLabel.text = self.tabs[indexPath.item];
    cell.titleLabel.font = self.tabFont;
    BOOL defMode         = self.tabStyle == RJTabStyleDefault;
    BOOL showLine        = indexPath.item && defMode;
    [cell showSeparatorLine:showLine ? SeparateLineShowLeft : SeparateLineShowNone
                 bottomLine:defMode];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat fontWidth = [self stringSize:self.tabs[indexPath.item]
                                   frame:CGSizeMake(CGRectGetWidth(self.bounds), 44)
                                    font:self.tabFont].width;
    CGFloat meanWidht = [UIScreen mainScreen].bounds.size.width/[self.tabs count];
    CGFloat width     = MAX(MAX(MIN_ITEM_WIDHT, fontWidth + 10), meanWidht);
    
    return CGSizeMake(width, 44);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger idx = [indexPath row];
    
    if (idx != self.selectedIndex) {
        [self scrollTabAndIndicatorToIndex:idx animate:YES];

        if ([self.delegate respondsToSelector:@selector(tabView:didSelectedAtIndex:)]) {
            [self.delegate tabView:self didSelectedAtIndex:self.selectedIndex];
        }
    }
}

- (CGSize)stringSize:(NSString*)str frame:(CGSize)size font:(UIFont*)font
{
    if (!str || !str.length) return CGSizeZero;
    
    NSDictionary *attribute = @{NSFontAttributeName:font};
    CGSize actualsize = [str boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine |
                                                               NSStringDrawingUsesLineFragmentOrigin   |
                                                               NSStringDrawingUsesFontLeading
                                       attributes:attribute context:nil].size;
    actualsize.width = actualsize.width + 5;
    
    return actualsize ;
}

#pragma mark - Offset Calculate
- (void)offsetTabViewWithPage:(NSUInteger)index forward:(BOOL)forward ratio:(CGFloat)ratio
{
    NSInteger targetIndex = (forward) ? index + 1 : index - 1;
    
    CGFloat previousItemContentOffsetX = [self contentOffsetForSelectedItemAtIndex:index].x;
    CGFloat nextItemContentOffsetX     = [self contentOffsetForSelectedItemAtIndex:targetIndex].x;
    CGFloat previousItemPageIndicatorX = [self centerForSelectedItemAtIndex:index].x;
    CGFloat nextItemPageIndicatorX     = [self centerForSelectedItemAtIndex:targetIndex].x;
    CGFloat previousItemWidth          = [self widthForSelectedItemAtIndex:index];
    CGFloat nextItemWidth              = [self widthForSelectedItemAtIndex:targetIndex];

    if (forward) {
        CGFloat sOffset = (nextItemContentOffsetX - previousItemContentOffsetX) * ratio;
        self.collectionView.contentOffset = CGPointMake(previousItemContentOffsetX + sOffset , 0.);
        
        CGFloat iOffset = (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio;
        self.indicator.center = CGPointMake(previousItemPageIndicatorX + iOffset, self.indicator.center.y);
    } else {
        CGFloat sOffset = (nextItemContentOffsetX - previousItemContentOffsetX) * ratio;
        self.collectionView.contentOffset = CGPointMake(previousItemContentOffsetX - sOffset , 0.);
        
        CGFloat iOffset = (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio;
        self.indicator.center = CGPointMake(previousItemPageIndicatorX - iOffset, self.indicator.center.y);
    }
    CGFloat iWidth   = nextItemWidth - previousItemWidth;
    CGFloat tOffset  = (nextItemContentOffsetX - previousItemContentOffsetX);
    CGRect fRect     = self.indicator.frame;
    CGFloat cOffset  = self.collectionView.contentOffset.x - previousItemContentOffsetX;
    
    if (tOffset == 0) tOffset = 1;
    
    fRect.size.width = previousItemWidth + (cOffset * iWidth) / tOffset;
    
    [self.indicator setFrame:fRect];
}

- (CGPoint)centerForSelectedItemAtIndex:(NSUInteger)index
{
    NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
    UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout
                                                    layoutAttributesForItemAtIndexPath:path];
    CGPoint center = attributes.center;
    CGPoint offset = [self contentOffsetForSelectedItemAtIndex:index];
    center.x       = center.x - offset.x;
    return center;
}

- (CGPoint)contentOffsetForSelectedItemAtIndex:(NSUInteger)index
{
    if (self.tabs.count < index || self.tabs.count == 1) {
        return CGPointZero;
    } else {
        CGFloat totalOffset = self.collectionView.contentSize.width - CGRectGetWidth(self.collectionView.frame);
        return CGPointMake(index * totalOffset / (self.tabs.count - 1), 0.);
    }
}

- (CGFloat)widthForSelectedItemAtIndex:(NSUInteger)index
{
    if (index >= self.tabs.count) return 0;
    
    NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
    UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout
                                                    layoutAttributesForItemAtIndexPath:path];
    CGFloat itemWidth = attributes.frame.size.width;
    
    if (self.tabStyle == RJTabStylePlain) {
        CGFloat fontWidth = [self stringSize:self.tabs[index]
                                       frame:CGSizeMake(CGRectGetWidth(self.bounds), 44)
                                        font:self.tabFont].width;
        return MIN(fontWidth, itemWidth);
    }
    return itemWidth;
}

#pragma mark - Getters & Setters
- (UIView *)indicator
{
    if (!_indicator) {
        _indicator = [[UIView alloc] init];
        [_indicator setBackgroundColor:[UIColor colorWithValue:@"#9583fb" alpha:1.f]];
        [self.collectionView addSubview:_indicator];
    }
    return _indicator;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:(UICollectionViewScrollDirectionHorizontal)];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                             collectionViewLayout:layout];
        [_collectionView registerClass:[RJTabCell class]
            forCellWithReuseIdentifier:CELL_ID];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing      = 0;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator   = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate   = self;
    }
    return _collectionView;
}

@end
