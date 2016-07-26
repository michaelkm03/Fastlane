//
//  VTableViewStreamFocusHelper.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTableViewStreamFocusHelper.h"

@interface VTableViewStreamFocusHelper ()

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation VTableViewStreamFocusHelper

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self != nil)
    {
        _tableView = tableView;
    }
    return self;
}

#pragma mark - Overrides

- (UIScrollView *)scrollView
{
    return self.tableView;
}

- (NSArray *)visibleCells
{
    return self.tableView.visibleCells;
}

@end
