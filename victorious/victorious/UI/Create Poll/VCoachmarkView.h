//
//  VCoachmarkView.h
//  victorious
//
//  Created by Sharif Ahmed on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPassthroughContainerView.h"
#import "VBackgroundContainer.h"

@class VCoachmark;

@interface VCoachmarkView : VPassthroughContainerView <VBackgroundContainer>

+ (instancetype)coachmarkViewWithCoachmark:(VCoachmark *)coachmark
                                    center:(CGPoint)center
                               targetPoint:(CGPoint)targetPoint;

@end
