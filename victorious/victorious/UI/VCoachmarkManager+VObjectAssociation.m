//
//  VCoachmarkManager+VObjectAssociation.m
//  victorious
//
//  Created by Sharif Ahmed on 5/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCoachmarkManager+VObjectAssociation.h"
#import <objc/runtime.h>

static const char kPassthroughViewKey;

@implementation VCoachmarkManager (VObjectAssociation)

- (void)associateView:(UIView *)view withCoachmarkPassthroughContainerView:(VCoachmarkPassthroughContainerView *)coachmarkPassthroughContainerView
{
    objc_setAssociatedObject(view, &kPassthroughViewKey, coachmarkPassthroughContainerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (VCoachmarkPassthroughContainerView *)coachmarkPassthroughContainerViewAssociatedWithView:(UIView *)view
{
    return objc_getAssociatedObject(view, &kPassthroughViewKey);
}

- (void)removeAssociationForCoachmarkPassthroughContainerView:(VCoachmarkPassthroughContainerView *)coachmarkPassthroughContainerView
{
    objc_setAssociatedObject(coachmarkPassthroughContainerView, &kPassthroughViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
