//
//  VCollectionListPresentationController.m
//  victorious
//
//  Created by Michael Sena on 7/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCollectionListPresentationController.h"

@interface VCollectionListPresentationController ()

@property (nonatomic, strong) UIView *dimmingView;

@end

@implementation VCollectionListPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController
{
    self = [super initWithPresentedViewController:presentedViewController
                         presentingViewController:presentingViewController];
    if (self != nil)
    {
        _dimmingView = [[UIView alloc] init];
        _dimmingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return self;
}

- (BOOL)shouldRemovePresentersView
{
    return NO;
}

- (void)presentationTransitionWillBegin
{
    [super presentationTransitionWillBegin];
    
    [self.containerView addSubview:self.dimmingView];
    self.dimmingView.alpha = 0.0f;
    
    [[[self presentedViewController] transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         self.dimmingView.alpha = 1.0f;
     }
                                                                            completion:nil];
}

- (void)dismissalTransitionWillBegin
{
    [[[self presentedViewController] transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         self.dimmingView.alpha = 0.0f;
     }
                                                                            completion:nil];
}

- (void)containerViewDidLayoutSubviews
{
    self.dimmingView.frame = self.containerView.frame;
}

@end
