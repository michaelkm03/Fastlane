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

@property (nonatomic, weak) UIViewController *viewControllerPresentedOn;
@property (nonatomic, strong) VPublishBlurOverAnimator *animator;
@property (nonatomic, strong, readwrite) VPublishViewController *publishViewController;

@end

@implementation VPublishPresenter

- (instancetype)initWithDependencymanager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencymanager:dependencyManager];
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

- (void)presentOnViewController:(UIViewController *)viewControllerToPresentOn
{
    self.viewControllerPresentedOn = viewControllerToPresentOn;
    [viewControllerToPresentOn presentViewController:self.publishViewController
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

- (void)setPublishActionHandler:(void (^)(BOOL))publishActionHandler
{
    NSParameterAssert(publishActionHandler != nil);
    _publishActionHandler = [publishActionHandler copy];
    
    __weak typeof(self) welf = self;
    self.publishViewController.completion = ^void(BOOL success)
    {
        __strong typeof(welf) strongSelf = welf;
        strongSelf.publishViewController.completion = nil;
        strongSelf.publishActionHandler(success);
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
