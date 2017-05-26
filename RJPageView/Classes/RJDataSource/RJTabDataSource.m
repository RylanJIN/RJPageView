//
//  RJTabDataSource.m
//  TabPageDemo
//
//  Created by Ryan Jin on 1/5/16.
//  Copyright © 2016 ArcSoft. All rights reserved.
//

#import "RJTabDataSource.h"

@implementation RJTabDataSource

- (id)initWithCellIdentifier:(NSString *)cellID
          configureCellBlock:(void (^)(id cell, id item))block
{
    self = [super init];
    if (self) {
        self.cellIdentifier = cellID;
        self.block          = [block copy];
        self.items          = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [self.items count]) return nil;
    
    return self.items[(NSUInteger)indexPath.row];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
}

@end
