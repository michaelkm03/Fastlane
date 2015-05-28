//
//  VCoachmarkManager+VObjectAssociation.h
//  victorious
//
//  Created by Sharif Ahmed on 5/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCoachmarkManager.h"

@class VCoachmarkPassthroughContainerView;

@interface VCoachmarkManager (VObjectAssociation)

/**
    Uses the objc runtime to associate a the provided view with the provided coachmark passthrough container view.
 
    @param view The view to associate with the coachmark passthrough container view.
    @param coachmarkPassthroughContainerView The coachmark passthrough container view that will be associated with the view.
 */
- (void)associateView:(UIView *)view withCoachmarkPassthroughContainerView:(VCoachmarkPassthroughContainerView *)coachmarkPassthroughContainerView;

/**
    Returns the coachmark passthrough container view associated with the provided view.
    This should be called after associateView:withCoachmarkPassthroughContainerView:
 
    @param view The view whose associated coachmark passthrough container view we are interested in retrieving.
 
    @return The coachmark passthrough container view associated with the provided view.
 */
- (VCoachmarkPassthroughContainerView *)coachmarkPassthroughContainerViewAssociatedWithView:(UIView *)view;

/**
    Removes the associated view from the provided coachmark passthrough container view.
 
    @param coachmarkPassthroughContainerView The coachmark passthrough container view that should have it's associated
       view unassociated from it. This will NOT remove all associations from the coachmark passthrough container view.
 */
- (void)removeAssociationForCoachmarkPassthroughContainerView:(VCoachmarkPassthroughContainerView *)coachmarkPassthroughContainerView;

@end
