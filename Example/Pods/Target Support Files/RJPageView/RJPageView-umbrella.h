#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "RJTabDataSource.h"
#import "UIColor+RJExtension.h"
#import "UIView+RJAutoLayout.h"
#import "RJPageViewController.h"
#import "RJTabCell.h"
#import "RJTabView.h"

FOUNDATION_EXPORT double RJPageViewVersionNumber;
FOUNDATION_EXPORT const unsigned char RJPageViewVersionString[];

