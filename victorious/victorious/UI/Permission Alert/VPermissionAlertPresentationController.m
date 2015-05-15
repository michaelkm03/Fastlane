//
//  VPermissionAlertPresentationController.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPermissionAlertPresentationController.h"
#import "UIView+AutoLayout.h"

@interface VPermissionAlertPresentationController ()

@property (nonatomic, strong) UIView *dimmingView;

@end

@implementation VPermissionAlertPresentationController

#pragma  mark - Presentation

- (void)presentationTransitionWillBegin
{
    self.dimmingView = [UIView new];
    self.dimmingView.backgroundColor = [UIColor darkGrayColor];
    self.dimmingView.alpha = 0.0f;
    self.dimmingView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.containerView addSubview:self.dimmingView];
    [self.containerView v_addFitToParentConstraintsToSubview:self.dimmingView];
    
    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
    {
        self.dimmingView.alpha = 0.6f;
    } completion:nil];
}

- (void)presentationTransitionDidEnd:(BOOL)completed
{
    if (completed == NO)
    {
        [self.dimmingView removeFromSuperview];
    }
}

#pragma mark - Dismissal

- (void)dismissalTransitionWillBegin
{
    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
    {
        self.dimmingView.alpha = 0.0f;
    } completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed
{
    if (completed == NO)
    {
        [self.dimmingView removeFromSuperview];
    }
}

@end
