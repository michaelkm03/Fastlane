//
//  VCreateSheetAnimator.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreateSheetAnimator.h"
#import "VCreateSheetPresentationController.h"
#import "VCreateSheetViewController.h"

static const CGFloat kCellPresentTime = 0.6;
static const CGFloat kCellPresentDelay = 0.1;
static const CGFloat kDismissTotalTime = 0.4;

@implementation VCreateSheetAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    VCreateSheetViewController *animatingViewController = (VCreateSheetViewController *)toViewController;
    
    if ([self isPresentation])
    {
        // Calculate total animation time depending on cells
        return kCellPresentTime + (animatingViewController.menuItems.count - 1) * kCellPresentDelay;
    }
    
    return kDismissTotalTime;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    BOOL isPresentation = [self isPresentation];
    
    VCreateSheetViewController *animatingViewController = isPresentation ? (VCreateSheetViewController *)toViewController : (VCreateSheetViewController *)fromViewController;
    
    if (isPresentation)
    {
        CGAffineTransform transitionDownTransform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(fromViewController.view.bounds));
        
        [containerView addSubview:animatingViewController.view];
        
        // Layout collection view so we can animate cells
        UICollectionView *collectionView = animatingViewController.collectionView;
        [collectionView layoutIfNeeded];
        
        // Animate each cell seperately with small delay
        for (UICollectionViewCell *cell in collectionView.visibleCells)
        {
            NSUInteger item = [animatingViewController.collectionView indexPathForCell:cell].item;
            
            cell.transform = transitionDownTransform;

            [UIView animateWithDuration:kCellPresentTime
                                  delay:kCellPresentDelay * item
                 usingSpringWithDamping:0.7f
                  initialSpringVelocity:0.0f
                                options:0
                             animations:^
             {
                 cell.transform = CGAffineTransformIdentity;
                 cell.alpha = 1.0f;
             } completion:^(BOOL finished)
             {
                 if (item == collectionView.visibleCells.count - 1)
                 {
                     [transitionContext completeTransition:YES];
                 }
             }];
        }
        
        UIButton *dismissButton = animatingViewController.dismissButton;
        dismissButton.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(dismissButton.bounds));
        
        // Animate button from bottom without spring
        [UIView animateWithDuration:0.3 delay:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^
        {
            dismissButton.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
    else
    {
        UIView *animatingView = animatingViewController.view;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0f
             usingSpringWithDamping:0.75f
              initialSpringVelocity:0.0f
                            options:0
                         animations:^
         {
             animatingView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(animatingViewController.view.bounds));
             animatingView.alpha = 0.0f;
         } completion:^(BOOL finished)
         {
             [transitionContext completeTransition:YES];
         }];
    }
}

@end

@interface VCreateSheetTransitionDelegate ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VCreateSheetTransitionDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    VCreateSheetAnimator *animatedTransitioner = [[VCreateSheetAnimator alloc] init];
    animatedTransitioner.presentation = YES;
    return animatedTransitioner;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    VCreateSheetAnimator *animatedTransitioner = [[VCreateSheetAnimator alloc] init];
    animatedTransitioner.presentation = NO;
    return animatedTransitioner;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source
{
    VCreateSheetPresentationController *presentationController = [[VCreateSheetPresentationController alloc] initWithPresentedViewController:presented
                                                                                                                    presentingViewController:presenting
                                                                                                                                      source:source];
    [presentationController setDependencyManager:self.dependencyManager];
    return presentationController;
}

@end
