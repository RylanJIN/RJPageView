//
//  RJTabView.h
//  TabPageDemo
//
//  Created by Ryan Jin on 1/5/16.
//  Copyright © 2016 ArcSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RJTabView;

@protocol RJTabViewDelegate <NSObject>

- (void)tabView:(RJTabView *)tabView didSelectedAtIndex:(NSUInteger)index;

@end

@interface RJTabView : UIView 

@property (nonatomic,   weak) id<RJTabViewDelegate> delegate;
@property (nonatomic, strong)            UIFont     *tabFont;
@property (nonatomic, assign, readwrite) NSUInteger selectedIndex;

- (void)setTabs:(NSArray *)tabs defalutIndex:(NSUInteger)index;
/**
 A convenience method to select a tab manually.
 This method will not invoke 'didSelectedAtIndex' delegate.
 */
- (void)selectTabAtIndex:(NSUInteger)index;
/**
 Call this method when your content view is scrolling and thus causing the tab view to move accordingly.
 This function also update the indicator view's frame.
 */
- (void)offsetTabViewWithPage:(NSUInteger)index forward:(BOOL)forward ratio:(CGFloat)ratio;

@end
