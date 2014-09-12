//
//  VConditionalPanningCollectionView.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConditionalPanningCollectionView.h"

#import "VBaseCollectionViewCell.h"

@implementation VConditionalPanningCollectionView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    CGPoint locationInSelf = [touch locationInView:self];
    NSIndexPath *indexPathForItemAtPoint = [self indexPathForItemAtPoint:locationInSelf];
    VBaseCollectionViewCell *cellForIndexPath = (VBaseCollectionViewCell *)[self cellForItemAtIndexPath:indexPathForItemAtPoint];
    if ([cellForIndexPath respondsToSelector:@selector(shouldPan)])
    {
        return [cellForIndexPath shouldPan];
    }
    return YES;
}

@end
