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

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *dimmingView;
@property (nonatomic, strong) UIView *snapshotView;

@end

@implementation VPermissionAlertPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController
                                         source:(UIViewController *)source
{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self)
    {
        _backgroundView = [UIView new];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _dimmingView = [UIView new];
        _dimmingView.backgroundColor = [UIColor darkGrayColor];
        _dimmingView.alpha = 0.0f;
        _snapshotView = [source.view snapshotViewAfterScreenUpdates:NO];
    }
    return self;
}

#pragma  mark - Presentation

- (void)presentationTransitionWillBegin
{
    self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    self.snapshotView.translatesAutoresizingMaskIntoConstraints = NO;
    self.dimmingView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.containerView addSubview:self.backgroundView];
    [self.containerView addSubview:self.snapshotView];
    [self.containerView addSubview:self.dimmingView];
    
    [self.containerView v_addFitToParentConstraintsToSubview:self.backgroundView];
    [self.containerView v_addFitToParentConstraintsToSubview:self.snapshotView];
    [self.containerView v_addFitToParentConstraintsToSubview:self.dimmingView];
    
    [self.presentingViewController.transitionCoordinator
     animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
    {
        self.snapshotView.transform = CGAffineTransformMakeScale(0.85f, 0.85f);
        self.dimmingView.alpha = 0.8f;
    } completion:nil];
}

- (void)presentationTransitionDidEnd:(BOOL)completed
{
    if (completed == NO)
    {
        [self.dimmingView removeFromSuperview];
        [self.snapshotView removeFromSuperview];
        [self.backgroundView removeFromSuperview];
    }
}

#pragma mark - Dismissal

- (void)dismissalTransitionWillBegin
{
    [self.presentingViewController.transitionCoordinator
     animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
    {
        self.snapshotView.transform = CGAffineTransformIdentity;
        self.dimmingView.alpha = 0.0f;
    } completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed
{
    if (completed == YES)
    {
        [self.dimmingView removeFromSuperview];
        [self.snapshotView removeFromSuperview];
        [self.backgroundView removeFromSuperview];
    }
}

@end
