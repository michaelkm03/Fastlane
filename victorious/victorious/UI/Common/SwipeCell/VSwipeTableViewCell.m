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
    BOOL shouldHitTestSubviewsOutSideBounds = !self.hidden && self.alpha > 0;
    BOOL shouldHitTestSubviewsAtAll = !self.clipsToBounds && self.swipeViewController != nil;
    if ( shouldHitTestSubviewsOutSideBounds && shouldHitTestSubviewsAtAll )
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

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.swipeViewController reset];
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

@end
