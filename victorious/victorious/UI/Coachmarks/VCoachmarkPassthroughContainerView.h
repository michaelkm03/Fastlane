//
//  VCoachmarkPassthroughContainerView.h
//  victorious
//
//  Created by Sharif Ahmed on 5/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPassthroughContainerView.h"

@class VCoachmarkView;

/**
    A view that allows touches to pass through it
    while sending a message to its delegate, can be
    thought of much like an invisible button.
 */
@interface VCoachmarkPassthroughContainerView : VPassthroughContainerView

/**
    Creates a new Coachmark Passthrough Container View and assigns
    the coachmarkView and delegate properties to the provided values.
    This call also adds the coachmark view as a subview.
 
    @param coachmarkView The coachmark view that this Coachmark Passthrough Container View will display.
    @param delegate The delegate that will respond to touch events.
 
    @return A ready-for-display Coachmark Passthrough Container View.
 */
+ (instancetype)coachmarkPassthroughContainerViewWithCoachmarkView:(VCoachmarkView *)coachmarkView
                                                       andDelegate:(id <VPassthroughContainerViewDelegate>)delegate;

/**
    The coachmark view that is being displayed within this Coachmark
    Passthrough Container View. This must be provided via the
    coachmarkPassthroughContainerViewWithCoachmarkView:frame:andDelegate
    class method.
 */
@property (nonatomic, readonly) VCoachmarkView *coachmarkView;

@end
