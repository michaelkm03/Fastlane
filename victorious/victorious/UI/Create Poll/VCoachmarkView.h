//
//  VCoachmarkView.h
//  victorious
//
//  Created by Sharif Ahmed on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPassthroughContainerView.h"
#import "VBackgroundContainer.h"

#warning TESTS INCOMPLETE

typedef NS_ENUM( NSUInteger, VCoachmarkArrowDirection )
{
    VCoachmarkArrowDirectionUp,
    VCoachmarkArrowDirectionDown,
    VCoachmarkArrowDirectionInvalid
};

@class VCoachmark;

@interface VCoachmarkView : VPassthroughContainerView <VBackgroundContainer>

/**
    Creates a new toast Coachmark View.
 
    @param coachmark The coachmark that should be represented by the toast.
    @param width The width of the Coachmark View.
 
    @return A new Coachmark View of the provided width that is displaying
            the currentScreenText of the provided coachmark.
 */
+ (instancetype)toastCoachmarkViewWithCoachmark:(VCoachmark *)coachmark
                                       andWidth:(CGFloat)width;

/**
    Creates a new tooltip Coachmark View.
 
    @param coachmark The coachmark that should be represented by the tooltip.
    @param width The width of the Coachmark View.
    @param horizontalOffset The horizontal offset of the tooltip arrow.
           This value is relative to the x origin of the Coachmark View, not the screen.
    @param arrowDirection The direction that the tooltip arrow should point.
 
    @return A new Coachmark View of the provided width and appropriately located tooltip
            arrow that is displaying the relatedScreenText of the provided coachmark.
 */
+ (instancetype)tooltipCoachmarkViewWithCoachmark:(VCoachmark *)coachmark
                                            width:(CGFloat)width
                            arrowHorizontalOffset:(CGFloat)horizontalOffset
                                andArrowDirection:(VCoachmarkArrowDirection)arrowDirection;

/**
    The coachmark provided by one of the class methods used to create this view.
 */
@property (nonatomic, readonly) VCoachmark *coachmark;

/**
    The arrow direction of the tooltip. This value is VCoachmarkArrowDirectionInvalid
    when the coachmark view is shown as a toast.
 */
@property (nonatomic, readonly) VCoachmarkArrowDirection arrowDirection;

/**
    Allows the reading and setting of the hasBeenShown bool on this instance's coachmark.
 */
@property (nonatomic, assign) BOOL hasBeenShown;

@end
