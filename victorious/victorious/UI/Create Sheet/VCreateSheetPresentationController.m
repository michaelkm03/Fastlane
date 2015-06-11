//
//  VCreateSheetPresentationController.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreateSheetPresentationController.h"
#import "VBackgroundContainer.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "UIView+AutoLayout.h"

static const CGFloat kBackgroundFinalAlpha = 0.9f;

@interface VCreateSheetPresentationController () <VBackgroundContainer>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) UIView *backgroundContainer;

@end

@implementation VCreateSheetPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController
                                         source:(UIViewController *)source
{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self != nil)
    {
        _backgroundContainer = [UIView new];
        _backgroundContainer.alpha = 0;
    }
    return self;
}

#pragma mark - properties

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    [self.dependencyManager addBackgroundToBackgroundHost:self];
}

#pragma  mark - Presentation

- (void)presentationTransitionWillBegin
{
    self.backgroundContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.containerView addSubview:self.backgroundContainer];
    [self.containerView v_addFitToParentConstraintsToSubview:self.backgroundContainer];
    
    CGAffineTransform translateDown = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.containerView.bounds));
    self.backgroundContainer.transform = translateDown;
    
    [UIView animateWithDuration:0.2 animations:^
    {
        self.backgroundContainer.transform = CGAffineTransformIdentity;
        self.backgroundContainer.alpha = kBackgroundFinalAlpha;
    } completion:nil];
}

- (void)presentationTransitionDidEnd:(BOOL)completed
{
    if (completed == NO)
    {
        [self.backgroundContainer removeFromSuperview];
    }
}

#pragma mark - Dismissal

- (void)dismissalTransitionWillBegin
{
    CGAffineTransform translateDown = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.containerView.bounds));

    [self.presentingViewController.transitionCoordinator
     animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         self.backgroundContainer.alpha = 0.0f;
         self.backgroundContainer.transform = translateDown;
     } completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed
{
    if (completed == YES)
    {
        [self.backgroundContainer removeFromSuperview];
    }
}

#pragma mark - Background

- (UIView *)backgroundContainerView
{
    return self.backgroundContainer;
}

@end
