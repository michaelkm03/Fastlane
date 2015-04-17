//
//  VProfileHeaderCell.m
//  victorious
//
//  Created by Will Long on 10/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileHeaderCell.h"
#import "UIView+AutoLayout.h"

@implementation VProfileHeaderCell

- (void)setHeaderView:(VUserProfileHeaderView *)headerView
{
    self.clipsToBounds = NO;
    [_headerView.view removeFromSuperview];
    _headerView = headerView;
    _headerView.view.frame = self.bounds;//Make sure the header view is set to an origin of 0 0
    [self addSubview:_headerView.view];
#warning IMplement view controller containment
    [self v_addFitToParentConstraintsToSubview:_headerView.view];
}

@end
