//
//  VAlongsideTransitioner.m
//  victorious
//
//  Created by Michael Sena on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAlongsideTransitioner.h"

#import "VAlongsidePresentationAnimator.h"

@interface VAlongsideTransitioner ()

@property (nonatomic, strong) VAlongsidePresentationAnimator *animator;

@end

@implementation VAlongsideTransitioner

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _animator = [[VAlongsidePresentationAnimator alloc] init];
    }
    return self;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    self.animator.presenting = YES;
    return self.animator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.animator.presenting = NO;
    return self.animator;
}

@end
