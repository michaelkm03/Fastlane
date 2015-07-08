//
//  VStreamFocusHelper.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamFocusHelper.h"
#import "VStreamCellFocus.h"

static const CGFloat VDefaultFocusVisibilityRatio = 0.8f;

@implementation VStreamFocusHelper

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _visibilityRatio = VDefaultFocusVisibilityRatio;
    }
    return self;
}

- (void)updateFocus
{
    const CGRect streamVisibleRect = [self scrollView].bounds;
    
    [[self visibleCells] enumerateObjectsUsingBlock:^(UIView *cell, NSUInteger idx, BOOL *stop)
     {
         if ( ![cell conformsToProtocol:@protocol(VCellFocus)] )
         {
             return;
         }
         
         id <VCellFocus>focusCell;
         if ( [cell conformsToProtocol:@protocol(VCellFocus)] )
         {
             focusCell = (id <VCellFocus>)cell;
         }
         
         // Calculate visible ratio for just the media content of the cell
         const CGRect contentFrameInCell = [focusCell contentArea];
         
         if ( CGRectGetHeight( contentFrameInCell ) > 0.0 )
         {
             const CGRect contentIntersection = CGRectIntersection( streamVisibleRect, cell.frame );
             const float mediaContentVisibleRatio = CGRectGetHeight( contentIntersection ) / CGRectGetHeight( contentFrameInCell );
             if ( mediaContentVisibleRatio >= self.visibilityRatio )
             {
                 if ( [cell conformsToProtocol:@protocol(VCellFocus)] )
                 {
                     [(id <VCellFocus>)cell setHasFocus:YES];
                 }
             }
             else
             {
                 if ( [cell conformsToProtocol:@protocol(VCellFocus)] )
                 {
                     [(id <VCellFocus>)cell setHasFocus:NO];
                 }
             }
         }
     }];
}

- (void)endFocusOnCell:(UIView *)cell
{
    if ( [cell conformsToProtocol:@protocol(VCellFocus)] )
    {
        [(id <VCellFocus>)cell setHasFocus:NO];
    }
}

- (void)endFocusOnAllCells
{
    for (UIView *cell in [self visibleCells])
    {
        [self endFocusOnCell:cell];
    }
}

- (CGFloat)visibilityRatio
{
    CGFloat clamped = MIN(_visibilityRatio, 1);
    return MAX(clamped, 0);
}

#pragma mark - Overrides

- (NSArray *)visibleCells
{
    NSAssert(false, @"visibleCells must be implemented by subclasses of VStreamFocusHelper");
    return @[];
}

- (UIScrollView *)scrollView
{
    NSAssert(false, @"scrollView must be implemented by subclasses of VStreamFocusHelper");
    return nil;
}

@end
