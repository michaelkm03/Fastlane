//
//  VLightboxTransitioningDelegate.m
//  victorious
//
//  Created by Josh Hinman on 5/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLightboxDismissAnimator.h"
#import "VLightboxDisplayAnimator.h"
#import "VLightboxTransitioningDelegate.h"
#import "VLightboxViewController.h"

#import <objc/runtime.h>

static const char kAssociatedObjectKey;

@implementation VLightboxTransitioningDelegate

+ (instancetype)addNewTransitioningDelegateToLightboxController:(VLightboxViewController *)lightboxController referenceView:(UIView *)referenceView
{
    VLightboxTransitioningDelegate *transitioningDelegate = [[self alloc] initWithReferenceView:referenceView];
    objc_setAssociatedObject(lightboxController, &kAssociatedObjectKey, transitioningDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    lightboxController.transitioningDelegate = transitioningDelegate;
    lightboxController.modalPresentationStyle = UIModalPresentationFullScreen;
    return transitioningDelegate;
}

- (instancetype)initWithReferenceView:(UIView *)referenceView
{
    self = [super init];
    if (self)
    {
        self.referenceView = referenceView;
    }
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[VLightboxDisplayAnimator alloc] initWithReferenceView:self.referenceView];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[VLightboxDismissAnimator alloc] initWithReferenceView:self.referenceView];
}

- (void)setReferenceView:(UIView *)referenceView
{
    _referenceView = referenceView;
}

@end
