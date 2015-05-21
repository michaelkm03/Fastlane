//
//  VCoachmarkView.h
//  victorious
//
//  Created by Sharif Ahmed on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPassthroughContainerView.h"
#import "VBackgroundContainer.h"

#warning DOCS, TESTS INCOMPLETE

typedef NS_ENUM( NSUInteger, VCoachmarkArrowDirection )
{
    VCoachmarkArrowDirectionUp,
    VCoachmarkArrowDirectionDown,
    VCoachmarkArrowDirectionInvalid
};

@class VCoachmark;

@interface VCoachmarkView : VPassthroughContainerView <VBackgroundContainer>

+ (instancetype)toastCoachmarkViewWithCoachmark:(VCoachmark *)coachmark
                                    andMaxWidth:(CGFloat)maxWidth;

+ (instancetype)tooltipCoachmarkViewWithCoachmark:(VCoachmark *)coachmark
                                         maxWidth:(CGFloat)maxWidth
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
