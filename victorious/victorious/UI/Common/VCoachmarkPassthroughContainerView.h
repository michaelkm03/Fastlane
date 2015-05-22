//
//  VCoachmarkPassthroughContainerView.h
//  victorious
//
//  Created by Sharif Ahmed on 5/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCoachmarkPassthroughContainerViewDelegate.h"

@class VCoachmarkView;

@interface VCoachmarkPassthroughContainerView : UIView

/**
    Creates a new Coachmark Passthrough Container View with the provided frame.
    This method will also add the provided coachmarkView as a subview.
 
    @param coachmarkView The coachmark view that this Coachmark Passthrough Container View will display.
    @param frame The desired frame of the newly created Coachmark Passthrough Container View.
    @param delegate The delegate that will respond to touch events.
 
    @return A ready-for-display Coachmark Passthrough Container View.
 */
+ (instancetype)coachmarkPassthroughContainerViewWithCoachmarkView:(VCoachmarkView *)coachmarkView
                                                             frame:(CGRect)frame
                                                       andDelegate:(id <VCoachmarkPassthroughContainerViewDelegate>)delegate;

/**
    The delegate that will respond to touch events that occur
    in this Coachmark Passthrough Container View
 */
@property (nonatomic, weak) id <VCoachmarkPassthroughContainerViewDelegate> delegate;

/**
    The coachmark view that is being displayed within this Coachmark
    Passthrough Container View. This must be provided via the
    coachmarkPassthroughContainerViewWithCoachmarkView:frame:andDelegate
    class method.
 */
@property (nonatomic, readonly) VCoachmarkView *coachmarkView;

@end
