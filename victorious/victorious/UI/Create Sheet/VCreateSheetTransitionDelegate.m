//
//  VCreateSheetAnimator.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreateSheetTransitionDelegate.h"
#import "VCreateSheetPresentationController.h"
#import "VCreateSheetViewController.h"
#import "VDependencyManager.h"

static const NSTimeInterval kCellPresentTime = 0.8;
static const NSTimeInterval kCellPresentDelay = 0.1;
static const NSTimeInterval kDismissTotalTime = 0.4;
static const NSTimeInterval kButtonUpTime = 0.7;
static const NSTimeInterval kButtonUpDelay = 0.3;

/**
 The animator object that conforms to UIViewControllerAnimatedTransitioning
 to be returned in the UIViewControllerTransitioningDelegate protocol methods
 */
@interface VCreateSheetAnimator : NSObject <UIViewControllerAnimatedTransitioning>

/**
 If the animation is presenting or dismissing
 */
@property (nonatomic, assign, getter=isPresentation) BOOL presentation;

/**
 Determines whether or not the presentation animation should start from the top
 */
@property (nonatomic, assign) BOOL fromTop;

@end

@implementation VCreateSheetAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return [self isPresentation] ? kButtonUpTime + kButtonUpDelay : kDismissTotalTime;
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
        // Layout collection view so we can animate cells
        UICollectionView *collectionView = animatingViewController.collectionView;
        [collectionView layoutIfNeeded];
        
        [containerView addSubview:animatingViewController.view];
        
        CGFloat yTransition = CGRectGetHeight(animatingViewController.view.bounds);
        CGAffineTransform transitionTransform = CGAffineTransformMakeTranslation(0, self.fromTop ? -yTransition : yTransition);
        
        // Sort our array of visible index paths so that the animation is always in order
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"item" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *sortedArray = [collectionView.indexPathsForVisibleItems sortedArrayUsingDescriptors:sortDescriptors];
        
        // Animate each cell seperately with small delay
        for (NSUInteger x = 0; x < collectionView.indexPathsForVisibleItems.count; x++)
        {
            NSUInteger adjustedIndex = self.fromTop ? sortedArray.count - (x + 1) : x;
            NSIndexPath *cellIndexPath = [sortedArray objectAtIndex:adjustedIndex];
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:cellIndexPath];
            
            cell.transform = transitionTransform;
            
            [UIView animateWithDuration:kCellPresentTime
                                  delay:kCellPresentDelay * x
                 usingSpringWithDamping:0.6f
                  initialSpringVelocity:0
                                options:0
                             animations:^
             {
                 cell.transform = CGAffineTransformIdentity;
             } completion:nil];
        }
        
        UIButton *dismissButton = animatingViewController.dismissButton;
        dismissButton.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(dismissButton.bounds));
        
        // Animate button from bottom
        [UIView animateWithDuration:kButtonUpTime
                              delay:kButtonUpDelay
             usingSpringWithDamping:0.9f
              initialSpringVelocity:0
                            options:0
                         animations:^
         {
             dismissButton.transform = CGAffineTransformIdentity;
         } completion:^(BOOL finished) {
             [transitionContext completeTransition:YES];
         }];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCreationSheetWillHide object:nil];
        
        UIView *animatingView = animatingViewController.view;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.0f
                            options:0
                         animations:^
         {
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
    NSNumber *animateFromTopNumber = [self.dependencyManager numberForKey:kAnimateFromTopKey];
    animatedTransitioner.fromTop = animateFromTopNumber != nil ? [animateFromTopNumber boolValue] : NO;
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
