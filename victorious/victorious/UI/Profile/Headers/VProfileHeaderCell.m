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

- (void)setHeaderViewController:(UIViewController *)headerViewController
{
    if ( _headerViewController != nil && _headerViewController == headerViewController  )
    {
        return;
    }
    else if ( _headerViewController != nil )
    {
        [_headerViewController.view removeFromSuperview];
    }
    else
    {
        _headerViewController = headerViewController;
        _headerViewController.view.frame = self.bounds;
        [self addSubview:_headerViewController.view];
        [self v_addFitToParentConstraintsToSubview:_headerViewController.view];
    }
}

@end
