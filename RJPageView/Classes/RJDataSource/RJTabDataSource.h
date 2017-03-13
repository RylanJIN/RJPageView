//
//  RJTabDataSource.h
//  TabPageDemo
//
//  Created by Ryan Jin on 1/5/16.
//  Copyright © 2016 ArcSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RJTabDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) void (^block)(id cell, id item);

- (id)initWithCellIdentifier:(NSString *)cellID
          configureCellBlock:(void (^)(id cell, id item))block;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end
