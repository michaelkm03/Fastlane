//
//  VAbstractCrossFadingView.h
//  victorious
//
//  Created by Sharif Ahmed on 7/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    Describes the curve that the alpha values should follow
    when the value of the offset property changes.
 */
typedef NS_ENUM(NSUInteger, VCrossFadingCurve)
{
    VCrossFadingCurveLinear,
    VCrossFadingCurveQuadratic,
    VCrossFadingCurveInverseQuadratic
};

/**
    A view that fades between an array of subviews based on the
        provided offset, visibility span, and curve values.
 */
@interface VAbstractCrossFadingView : UIView

/**
    Returns the array of views that can be cross faded between
        one another. Must be overridden by subclasses.
 */
- (NSArray *)crossFadingViews;

/**
    Updates the alpha values of visible views based on the current offset value.
 */
- (void)refresh;

/**
    When set to yes, the value of offset is bounded to [0, numberOfCrossFadingViews - 1] which causes
        this view to display at full-opacity even when an outside class attempts to set "offset"
        to a value outside this normalized range. Defaults to NO, allowing for offset values outside
        the [0, numberOfCrossFadingViews - 1] range to cause a partially transparent view to be shown.
 */
@property (nonatomic, assign) BOOL opaqueOutsideArrayRange;

/**
    Determines the alpha of the visible views.
 */
@property (nonatomic, assign) CGFloat offset;

/**
    A value from 0 - x where x represents the length of
        offset range where a view is visible.
 
    Ex: with visibilitySpan 2, the first view has an alpha value of 1
        for offset 0 and decreases to alpha value 0 at offset 1.
        with visibilitySpan 1, the first view has an alpha value of 1
        for offset 0 and decreases to alpha value 0 at offset 0.5.
 */
@property (nonatomic, assign) CGFloat visibilitySpan;

/**
    What curve the alpha of cross fading views should follow when the
        offset property changes. Defaults to VCrossFadingCurveLinear.
 */
@property (nonatomic, assign) VCrossFadingCurve fadingCurve;

@end
