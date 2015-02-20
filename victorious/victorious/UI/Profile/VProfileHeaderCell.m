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
    self.clipsToBounds = NO;
    [_headerView removeFromSuperview];
    _headerView = headerView;
    _headerView.frame = self.bounds;//Make sure the header view is set to an origin of 0 0
    [self addSubview:_headerView];
    /*_headerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = @{ @"header":_headerView };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[header]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[header]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];*/
    /*self.headerViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_headerView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0
                                                                    constant:self.bounds.size.height];*/
    //[_headerView addConstraint:self.headerViewHeightConstraint];
}

@end
