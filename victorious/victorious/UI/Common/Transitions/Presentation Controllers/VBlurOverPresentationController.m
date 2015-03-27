//
//  VBlurOverPresentationController.m
//  victorious
//
//  Created by Michael Sena on 3/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBlurOverPresentationController.h"
#import "UIView+AutoLayout.h"

@interface VBlurOverPresentationController ()

@property (nonatomic, weak) UIVisualEffectView *blurView;

@end

@implementation VBlurOverPresentationController

- (void)presentationTransitionWillBegin
{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self.containerView insertSubview:blurView atIndex:0];
    blurView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView v_addFitToParentConstraintsToSubview:blurView];
    self.blurView = blurView;
    
    self.blurView.alpha = 0.0f;
    id <UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         self.blurView.alpha = 1.0f;
     }
                                           completion:nil];
}

- (void)dismissalTransitionWillBegin
{
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         self.blurView.alpha = 0.0f;
     }
                                                                        completion:nil];
}

- (void)containerViewDidLayoutSubviews
{
    [super containerViewDidLayoutSubviews];
}

- (void)containerViewWillLayoutSubviews
{
    [super containerViewWillLayoutSubviews];
    [self.containerView layoutIfNeeded];
}

@end
