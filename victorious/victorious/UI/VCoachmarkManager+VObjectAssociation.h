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

- (void)associateView:(UIView *)view withCoachmarkPassthroughContainerView:(VCoachmarkPassthroughContainerView *)coachmarkPassthroughContainerView;

- (VCoachmarkPassthroughContainerView *)coachmarkPassthroughContainerViewAssociatedWithView:(UIView *)view;

- (void)removeAssociationForCoachmarkPassthroughContainerView:(VCoachmarkPassthroughContainerView *)coachmarkPassthroughContainerView;

@end
