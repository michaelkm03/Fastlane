//
//  VActionSheetTransitioningDelegate.m
//  victorious
//
//  Created by Michael Sena on 9/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VActionSheetTransitioningDelegate.h"

#import "VActionSheetViewController.h"
#import "VActionSheetPresentationAnimator.h"

#import <objc/runtime.h>

static const char kAssociatedObjectKey;

@interface VActionSheetTransitioningDelegate ()

@property (nonatomic, strong) VActionSheetPresentationAnimator *actionSheetPresentationAnimator;

@end

@implementation VActionSheetTransitioningDelegate

+ (instancetype)addNewTransitioningDelegateToActionSheetController:(VActionSheetViewController *)actionSheetViewController
{
    VActionSheetTransitioningDelegate *transitioningDelegate = [[self alloc] init];
    objc_setAssociatedObject(actionSheetViewController, &kAssociatedObjectKey, transitioningDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    transitioningDelegate.actionSheetPresentationAnimator = [[VActionSheetPresentationAnimator alloc] init];

    actionSheetViewController.transitioningDelegate = transitioningDelegate;
    actionSheetViewController.modalPresentationStyle = UIModalPresentationCustom;
    
    return transitioningDelegate;
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    self.actionSheetPresentationAnimator.presenting = YES;
    return self.actionSheetPresentationAnimator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.actionSheetPresentationAnimator.presenting = NO;
    return self.actionSheetPresentationAnimator;
}

@end
