//
//  VSwipeTableViewCell.m
//  SwipeCell
//
//  Created by Patrick Lynch on 12/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSwipeTableViewCell.h"

@implementation VSwipeTableViewCell 

- (void)setupSwipeView
{
    if ( self.swipeViewController != nil )
    {
        return;
    }
    
    self.clipsToBounds = NO;
    
    self.swipeViewController = [[VSwipeViewController alloc] initWithFrame:self.bounds];
    [self.contentView addSubview:self.swipeViewController.view];
    [self.contentView sendSubviewToBack:self.swipeViewController.view];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ( !self.clipsToBounds && self.swipeViewController != nil && !self.hidden && self.alpha > 0 )
    {
        CGPoint subPoint = [self.swipeViewController.utilityButtonsContainer convertPoint:point fromView:self];
        UIView *result = [self.swipeViewController.utilityButtonsContainer hitTest:subPoint withEvent:event];
        if ( result != nil )
        {
            return result;
        }
    }
    
    return [super hitTest:point withEvent:event];
}

#pragma mark - VCommentCellUtilitiesDelegate

- (void)commentRemoved:(VComment *)comment
{
    [self.commentsUtilitiesDelegate commentRemoved:comment];
}

- (void)editComment:(VComment *)comment
{
    [self.commentsUtilitiesDelegate editComment:comment];
}

- (void)didSelectActionRequiringLogin
{
    [self.commentsUtilitiesDelegate didSelectActionRequiringLogin];
}

@end
