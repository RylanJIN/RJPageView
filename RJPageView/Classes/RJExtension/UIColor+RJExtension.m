//
//  UIColor+RJExtension.m
//  TabPageDemo
//
//  Created by Ryan Jin on 1/6/16.
//  Copyright © 2016 ArcSoft. All rights reserved.
//

#import "UIColor+RJExtension.h"

@implementation UIColor (RJExtension)

+ (UIColor *)randomColor
{
    float hue        = ( arc4random() % 256 / 256.0 );        //  0.0 to 1.0
    float saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    float brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.f];
}

+ (UIColor *)colorWithValue:(NSString *)hexColorNum alpha:(float)mAlpha
{
    NSString *cString = [[hexColorNum stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                         uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) return nil;
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"] || [cString hasPrefix:@"0x"]) {
        cString = [cString substringFromIndex:2];
    }
    if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6) return nil;
    
    // Separate into r, g, b substrings
    NSRange range; range.location = 0; range.length = 2;
    
    unsigned int redInt, greenInt, blueInt;
    
    // red
    range.location = 0;
    [[NSScanner scannerWithString:[cString substringWithRange:range]] scanHexInt:&redInt];
    
    // green
    range.location = 2;
    [[NSScanner scannerWithString:[cString substringWithRange:range]] scanHexInt:&greenInt];
    
    // blue
    range.location = 4;
    [[NSScanner scannerWithString:[cString substringWithRange:range]] scanHexInt:&blueInt];
    
    return [UIColor colorWithRed:(redInt/255.0) green:(greenInt/255.0) blue:(blueInt/255.0) alpha:mAlpha];
}

@end
