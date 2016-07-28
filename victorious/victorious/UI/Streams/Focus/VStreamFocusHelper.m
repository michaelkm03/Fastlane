//
//  VStreamFocusHelper.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamFocusHelper.h"
#import "VFocusable.h"

static const CGFloat VDefaultFocusVisibilityRatio = 0.8f;

@implementation VStreamFocusHelper

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _visibilityRatio = VDefaultFocusVisibilityRatio;
        _focusAreaInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (void)updateFocus
{
    for ( id<VFocusable> focusCell in [self visibleCells] )
    {
        if ( ![focusCell conformsToProtocol:@protocol(VFocusable)] || [focusCell isEqual:self.selectedCell] )
        {
            continue;
        }
        
        // Calculate visible ratio for just the media content of the cell
        const CGRect contentFrameInCell = [focusCell contentArea];
        
        if ( CGRectGetHeight( contentFrameInCell ) > 0.0 )
        {
            // Convert media view's frame to parent view of scroll view
            CGRect mediaVisibility = [(UIView *)focusCell convertRect:[focusCell contentArea] toView:self.scrollView.superview];
            
            // Inset the focus area
            CGRect focusFrame = UIEdgeInsetsInsetRect(self.scrollView.frame, self.focusAreaInsets);
            
            // Determine intersect with the scroll view's frame
            CGRect intersectWithScrollview = CGRectIntersection(focusFrame, mediaVisibility);
            
            // Determine if we see enough of the content to put it in focus
            const float mediaContentVisibleRatio = CGRectGetHeight(intersectWithScrollview) / CGRectGetHeight([focusCell contentArea]);
            
            if ( mediaContentVisibleRatio >= self.visibilityRatio )
            {
                [focusCell setFocusType:VFocusTypeStream];
            }
            else
            {
                [focusCell setFocusType:VFocusTypeNone];
            }
        }
    }
}

- (void)endFocusOnCell:(UIView *)cell
{
    if ( [cell conformsToProtocol:@protocol(VFocusable)] && cell != self.selectedCell )
    {
        id<VFocusable> focusCell = (id <VFocusable>)cell;
        [focusCell setFocusType:VFocusTypeNone];
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
