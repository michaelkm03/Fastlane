//
//  VPublishPresenter.m
//  victorious
//
//  Created by Michael Sena on 7/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPublishPresenter.h"

#import "VPublishViewController.h"
#import "VPublishBlurOverAnimator.h"

@interface VPublishPresenter () <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) VPublishBlurOverAnimator *animator;
@property (nonatomic, strong, readwrite) VPublishViewController *publishViewController;

@end

@implementation VPublishPresenter

- (instancetype)initWithViewControllerToPresentOn:(UIViewController *)viewControllerToPresentOn dependencymanager:(VDependencyManager *)dependencyManager
{
    self = [super initWithViewControllerToPresentOn:viewControllerToPresentOn
                                  dependencymanager:dependencyManager];
    if (self != nil)
    {
        _animator = [[VPublishBlurOverAnimator alloc] init];
        _publishViewController = [dependencyManager newPublishViewController];
        _publishViewController.transitioningDelegate = self;
        _publishViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

#pragma mark - VAbstractPresenter

- (void)present
{
    [self.viewControllerToPresentOn presentViewController:self.publishViewController
                                                 animated:YES
                                               completion:nil];
}

#pragma mark - PropertyAccessors

- (void)setPublishParameters:(VPublishParameters *)publishParameters
{
    self.publishViewController.publishParameters = publishParameters;
}

- (VPublishParameters *)publishParameters
{
    return self.publishViewController.publishParameters;
}

- (void)setCompletion:(void (^)(BOOL))completion
{
    _completion = completion;
    __weak typeof(self) welf = self;
    self.publishViewController.completion = ^void(BOOL success)
    {
        __strong typeof(welf) strongSelf = welf;
        if (!success)
        {
            [strongSelf.viewControllerToPresentOn dismissViewControllerAnimated:YES completion:nil];
        }
        strongSelf.publishViewController.completion = nil;
        completion(success);
    };
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
