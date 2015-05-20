//
//  VCoachmarkView.h
//  victorious
//
//  Created by Sharif Ahmed on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPassthroughContainerView.h"
#import "VBackgroundContainer.h"

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

@property (nonatomic, readonly) VCoachmark *coachmark;
@property (nonatomic, readonly) VCoachmarkArrowDirection arrowDirection;
@property (nonatomic, assign) BOOL hasBeenShown;

@end
