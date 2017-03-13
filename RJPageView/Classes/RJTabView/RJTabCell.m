//
//  RJTabCell.m
//  TabPageDemo
//
//  Created by Ryan Jin on 1/5/16.
//  Copyright © 2016 ArcSoft. All rights reserved.
//

#import "RJTabCell.h"
#import "UIColor+RJExtension.h"

@interface RJTabCell()

@property (nonatomic, strong) UIView *lineL;
@property (nonatomic, strong) UIView *lineR;
@property (nonatomic, strong) UIView *lineB;

@end

@implementation RJTabCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
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

#pragma mark - View Setup
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = self.bounds;
    self.lineL.frame = CGRectMake(0, 10, 1, CGRectGetHeight(self.bounds)-20);
    self.lineR.frame = CGRectMake(CGRectGetWidth(self.bounds), 10, 1, CGRectGetHeight(self.bounds)-20);
    self.lineB.frame = CGRectMake(0, CGRectGetHeight(self.bounds)-1, CGRectGetWidth(self.bounds), 1);
}

- (void)setupViewComponents
{
    [self addSubview:self.titleLabel];
    
    [self addSubview:self.lineL];
    [self addSubview:self.lineR];
    [self addSubview:self.lineB];
}

- (void)setSelected:(BOOL)selected {
    [self.titleLabel setHighlighted:selected];
}

#pragma mark - Separate Line
- (void)showSeparatorLine:(SeparateLineShow)flag
{
    self.lineL.hidden = !(flag & SeparateLineShowLeft);
    self.lineR.hidden = !(flag & SeparateLineShowRight);
}

#pragma mark - Getters & Setters
- (UIView *)lineL
{
    if (!_lineL) {
        _lineL = [[UIView alloc] initWithFrame:CGRectZero];
        [_lineL setBackgroundColor:[UIColor colorWithValue:@"#d9d9d9" alpha:1.f]];
    }
    return _lineL;
}

- (UIView *)lineR
{
    if (!_lineR) {
        _lineR = [[UIView alloc] initWithFrame:CGRectZero];
        [_lineR setBackgroundColor:[UIColor colorWithValue:@"#d9d9d9" alpha:1.f]];
    }
    return _lineR;
}

- (UIView *)lineB
{
    if (!_lineB) {
        _lineB = [[UIView alloc] initWithFrame:CGRectZero];
        [_lineB setBackgroundColor:[UIColor colorWithValue:@"#d9d9d9" alpha:1.f]];
    }
    return _lineB;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:self.bounds];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont systemFontOfSize:14.f]];
        [_titleLabel setTextColor:[UIColor colorWithValue:@"#3d3c3f" alpha:1.f]];
        [_titleLabel setHighlightedTextColor:[UIColor colorWithValue:@"#9583fb" alpha:1.f]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _titleLabel;
}

@end
