//
//  VPermissionAlertPresentationController.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPermissionAlertPresentationController.h"
#import "UIView+AutoLayout.h"

static const CGFloat kDimmingViewAlpha = 0.7f;

@interface VPermissionAlertPresentationController ()

@property (nonatomic, strong) UIView *dimmingView;

@end

@implementation VPermissionAlertPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController
                                         source:(UIViewController *)source
{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self != nil)
    {
        _dimmingView = [UIView new];
        _dimmingView.backgroundColor = [UIColor blackColor];
        _dimmingView.alpha = 0.0f;
    }
    return self;
}

#pragma  mark - Presentation

- (void)presentationTransitionWillBegin
{
    self.dimmingView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.containerView addSubview:self.dimmingView];
    [self.containerView v_addFitToParentConstraintsToSubview:self.dimmingView];
    
    [self.presentingViewController.transitionCoordinator
     animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
    {
        self.dimmingView.alpha = kDimmingViewAlpha;
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
    [self.presentingViewController.transitionCoordinator
     animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
    {
        self.dimmingView.alpha = 0.0f;
    } completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed
{
    if (completed == YES)
    {
        [self.dimmingView removeFromSuperview];
    }
}

@end
