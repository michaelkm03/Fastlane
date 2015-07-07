//
//  VAbstractCrossFadingView.m
//  victorious
//
//  Created by Sharif Ahmed on 7/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractCrossFadingView.h"

@interface VAbstractCrossFadingView ()

@end

@implementation VAbstractCrossFadingView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self != nil )
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self != nil )
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.visibilitySpan = 1.0f;
    self.offset = 0.0f;
    self.opaqueOutsideArrayRange = YES;
}

- (void)updateVisibleViewsForOffset:(CGFloat)offset
{
    NSArray *currentlyVisibleImageViewContainers = [self visibleImageViewsForOffset:offset];
    if ( currentlyVisibleImageViewContainers == nil )
    {
        //There are no views to update, just get out
        return;
    }
    
    NSArray *crossFadingViews = [self crossFadingViews];
    for ( UIView *view in crossFadingViews )
    {
        CGFloat widthFromVisible = ( ABS(offset - (CGFloat)[crossFadingViews indexOfObject:view]) * 2 ) / self.visibilitySpan;
        CGFloat targetAlpha = 0.0f;
        
        //Check to see if the view we're inspecting is completely hidden given the current offset amount
        if ( widthFromVisible < 1.0f )
        {
            if ( widthFromVisible > 0.0f )
            {
                switch ( self.fadingCurve )
                {
                    case VCrossFadingCurveQuadratic:
                        widthFromVisible = sqrtf(widthFromVisible);
                        break;
                        
                    case VCrossFadingCurveInverseQuadratic:
                        widthFromVisible *= widthFromVisible;
                        break;
                        
                    case VCrossFadingCurveLinear:
                    default:
                        break;
                }
            }
            
            targetAlpha = 1.0f - widthFromVisible;
        }
        view.alpha = targetAlpha;
    }
    
}

- (void)setOffset:(CGFloat)offset
{
    NSArray *currentlyVisibleImageViewContainers = [self visibleImageViewsForOffset:offset];
    if ( currentlyVisibleImageViewContainers == nil )
    {
        //There are no views to update, just get out
        return;
    }
    
    CGFloat maxOffset = (CGFloat)( self.crossFadingViews.count - 1 );
    if ( self.opaqueOutsideArrayRange )
    {
        if ( offset < 0.0f )
        {
            offset = 0.0f;
        }
        else if ( offset >= maxOffset )
        {
            offset = maxOffset;
        }
    }
    
    _offset = offset;
    
    [self updateVisibleViewsForOffset:offset];
}

- (NSArray *)visibleImageViewsForOffset:(CGFloat)offset
{
    NSArray *crossFadingViews = self.crossFadingViews;
    if ( crossFadingViews.count == 0 )
    {
        return nil;
    }
    
    NSInteger lowIndex = floorf(offset);
    NSInteger highIndex = ceilf(offset);
    NSMutableArray *visibleViews = [[NSMutableArray alloc] init];
    
    if ( lowIndex >= 0 && lowIndex < (NSInteger)crossFadingViews.count )
    {
        [visibleViews addObject:crossFadingViews[lowIndex]];
    }
    else if ( lowIndex < 0 )
    {
        return @[[crossFadingViews firstObject]];
    }
    else if ( lowIndex >= (NSInteger)crossFadingViews.count )
    {
        return @[[crossFadingViews lastObject]];
    }
    
    if ( lowIndex != highIndex && highIndex > 0 && highIndex < (NSInteger)crossFadingViews.count )
    {
        [visibleViews addObject:crossFadingViews[highIndex]];
    }
    
    return [NSArray arrayWithArray:visibleViews];
}

- (void)setVisibilitySpan:(CGFloat)visibilitySpan
{
    NSParameterAssert( visibilitySpan >= 0 );
    _visibilitySpan = MAX(visibilitySpan, 0);
}

- (NSArray *)crossFadingViews
{
    NSAssert(false, @"crossFadingViews must be implemented by subclasses of VAbstractCrossFadingView");
    return nil;
}

- (void)refresh
{
    [self updateVisibleViewsForOffset:self.offset];
}

@end
