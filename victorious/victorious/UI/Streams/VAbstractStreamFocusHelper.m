//
//  VStreamFocusHelper.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractStreamFocusHelper.h"
#import "VStreamCellFocus.h"

static const CGFloat VFocusVisibilityRatio = 0.9f;

@implementation VAbstractStreamFocusHelper

- (void)updateFocusWithScrollView:(UIScrollView *)scrollView visibleCells:(NSArray *)visibleCells
{
    const CGRect streamVisibleRect = scrollView.bounds;
    
    [visibleCells enumerateObjectsUsingBlock:^(UIView *cell, NSUInteger idx, BOOL *stop)
     {
         if ( ![cell conformsToProtocol:@protocol(VStreamCellFocus)] )
         {
             return;
         }
         
         id <VStreamCellFocus>focusCell;
         if ( [cell conformsToProtocol:@protocol(VStreamCellFocus)] )
         {
             focusCell = (id <VStreamCellFocus>)cell;
         }
         
         // Calculate visible ratio for just the media content of the cell
         const CGRect contentFrameInCell = [focusCell contentArea];
         
         if ( CGRectGetHeight( contentFrameInCell ) > 0.0 )
         {
             const CGRect contentIntersection = CGRectIntersection( streamVisibleRect, cell.frame );
             const float mediaContentVisibleRatio = CGRectGetHeight( contentIntersection ) / CGRectGetHeight( contentFrameInCell );
             if ( mediaContentVisibleRatio >= VFocusVisibilityRatio )
             {
                 if ( [cell conformsToProtocol:@protocol(VStreamCellFocus)] )
                 {
                     [(id <VStreamCellFocus>)cell setHasFocus:YES];
                 }
             }
             else
             {
                 if ( [cell conformsToProtocol:@protocol(VStreamCellFocus)] )
                 {
                     [(id <VStreamCellFocus>)cell setHasFocus:NO];
                 }
             }
         }
     }];
}

- (void)manuallyEndFocusOnCell:(UIView *)cell
{
    if ( ![cell conformsToProtocol:@protocol(VStreamCellFocus)] )
    {
        return;
    }
    
    [(id <VStreamCellFocus>)cell setHasFocus:NO];
}

@end
