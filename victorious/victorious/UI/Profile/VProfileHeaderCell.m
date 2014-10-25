//
//  VProfileHeaderCell.m
//  victorious
//
//  Created by Will Long on 10/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileHeaderCell.h"

@implementation VProfileHeaderCell

- (void)setHeaderView:(VUserProfileHeaderView *)headerView
{
    [_headerView removeFromSuperview];
    _headerView = headerView;
    _headerView.frame = _headerView.bounds;//Make sure the header view is set to an origin of 0 0
    [self addSubview:_headerView];
}

@end
