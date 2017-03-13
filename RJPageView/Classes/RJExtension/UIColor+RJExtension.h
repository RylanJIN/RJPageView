//
//  UIColor+RJExtension.h
//  TabPageDemo
//
//  Created by Ryan Jin on 1/6/16.
//  Copyright © 2016 ArcSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (RJExtension)

+ (UIColor *)randomColor;
+ (UIColor *)colorWithValue:(NSString *)hexColorNum alpha:(float)mAlpha;

@end
