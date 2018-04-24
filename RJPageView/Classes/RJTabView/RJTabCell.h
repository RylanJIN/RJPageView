//
//  RJTabCell.h
//  TabPageDemo
//
//  Created by Ryan Jin on 1/5/16.
//  Copyright © 2016 ArcSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SeparateLineShow) {
    SeparateLineShowNone    = 0x00000000,
    SeparateLineShowLeft    = 0x00000001,
    SeparateLineShowRight   = 0x00000010,
};

@interface RJTabCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;

- (void)showSeparatorLine:(SeparateLineShow)flag bottomLine:(BOOL)show;

@end
