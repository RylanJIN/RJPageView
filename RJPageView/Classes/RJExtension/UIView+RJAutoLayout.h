//
//  UIView+RJAutoLayout.h
//  TabPageDemo
//
//  Created by Ryan Jin on 1/5/16.
//  Copyright © 2016 ArcSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RJAutoLayout <NSObject>

- (void)addConstraints;

@end

@interface UIView (RJAutoLayout)

// height
- (NSLayoutConstraint *)constraintHeight:(CGFloat)height;
- (NSLayoutConstraint *)constraintHeightEqualToView:(UIView *)view;

// width
- (NSLayoutConstraint *)constraintWidth:(CGFloat)width;
- (NSLayoutConstraint *)constraintWidthEqualToView:(UIView *)view;

// center
- (NSLayoutConstraint *)constraintCenterXEqualToView:(UIView *)view;
- (NSLayoutConstraint *)constraintCenterYEqualToView:(UIView *)view;

// top, bottom, left, right
- (NSArray *)constraintsTop:(CGFloat)top FromView:(UIView *)view;
- (NSArray *)constraintsBottom:(CGFloat)bottom FromView:(UIView *)view;
- (NSArray *)constraintsLeft:(CGFloat)left FromView:(UIView *)view;
- (NSArray *)constraintsRight:(CGFloat)right FromView:(UIView *)view;

- (NSArray *)constraintsTopInContainer:(CGFloat)top;
- (NSArray *)constraintsBottomInContainer:(CGFloat)bottom;
- (NSArray *)constraintsLeftInContainer:(CGFloat)left;
- (NSArray *)constraintsRightInContainer:(CGFloat)right;

- (NSLayoutConstraint *)constraintTopEqualToView:(UIView *)view;
- (NSLayoutConstraint *)constraintBottomEqualToView:(UIView *)view;
- (NSLayoutConstraint *)constraintLeftEqualToView:(UIView *)view;
- (NSLayoutConstraint *)constraintRightEqualToView:(UIView *)view;

// size
- (NSArray *)constraintsSize:(CGSize)size;
- (NSArray *)constraintsSizeEqualToView:(UIView *)view;

// imbue
- (NSArray *)constraintsFillWidth;
- (NSArray *)constraintsFillHeight;
- (NSArray *)constraintsFill;

// assign
- (NSArray *)constraintsAssignLeft;
- (NSArray *)constraintsAssignRight;
- (NSArray *)constraintsAssignTop;
- (NSArray *)constraintsAssignBottom;

@end
