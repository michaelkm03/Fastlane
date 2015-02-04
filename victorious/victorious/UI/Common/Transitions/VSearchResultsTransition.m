//
//  VSearchResultsTransition.m
//  victorious
//
//  Created by Lawrence Leach on 2/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSearchResultsTransition.h"
#import "VUsersAndTagsSearchViewController.h"

// The position of the search bar in the from view controller on transition in adjusted for the status bar
const static CGFloat kStartTopOffset = 36.0f;

@implementation VSearchResultsTransition

- (BOOL)canPerformPushTransitionFrom:(UIViewController *)fromViewController to:(UIViewController *)toViewController
{
    return [toViewController isKindOfClass:[VUsersAndTagsSearchViewController class]] || [fromViewController isKindOfClass:[VUsersAndTagsSearchViewController class]];
}

- (void)prepareForTransitionIn:(VTransitionModel *)model
{
    VUsersAndTagsSearchViewController *toViewController = (VUsersAndTagsSearchViewController *)model.toViewController;
    
    toViewController.searchResultsContainerView.alpha = 0.0f;
    toViewController.opaqueBackgroundView.alpha = 0.0f;
    toViewController.searchBarTopConstraint.constant = kStartTopOffset;
    toViewController.headerTopConstraint.constant = -toViewController.searchBarViewHeightConstraint.constant;
    
    [toViewController.searchBarTopConstraint.firstItem layoutIfNeeded];
    [toViewController.headerTopConstraint.firstItem layoutIfNeeded];
    [toViewController.searchResultsTableBottomCosntraint.firstItem layoutIfNeeded];
    [toViewController.view layoutIfNeeded];
}

- (void)performTransitionIn:(VTransitionModel *)model completion:(void (^)(BOOL))completion
{
    VUsersAndTagsSearchViewController *toViewController = (VUsersAndTagsSearchViewController *)model.toViewController;
    
    [UIView animateWithDuration:model.animationDuration
                          delay:0.0f
         usingSpringWithDamping:0.9f
          initialSpringVelocity:0.1f
                        options:kNilOptions
                     animations:^
     {
         
         toViewController.searchBarTopConstraint.constant = 0.0f;
         toViewController.headerTopConstraint.constant = 0.0f;
         toViewController.searchResultsContainerView.alpha = 1.0f;
         toViewController.searchBarTopHorizontalRule.alpha = 0.0f;
         toViewController.opaqueBackgroundView.alpha = 1.0f;
         
         [toViewController.searchBarTopConstraint.firstItem layoutIfNeeded];
         [toViewController.headerTopConstraint.firstItem layoutIfNeeded];
         [toViewController.searchResultsTableBottomCosntraint.firstItem layoutIfNeeded];
         [toViewController.view layoutIfNeeded];
    }
                     completion:^(BOOL finished)
    {
        completion( YES );
    }];
}

- (void)prepareForTransitionOut:(VTransitionModel *)model
{
    VUsersAndTagsSearchViewController *fromViewController = (VUsersAndTagsSearchViewController *)model.fromViewController;
    
    fromViewController.searchResultsContainerView.alpha = 1.0f;
    fromViewController.opaqueBackgroundView.alpha = 1.0f;
    
    [fromViewController.searchBarTopConstraint.firstItem layoutIfNeeded];
    [fromViewController.headerTopConstraint.firstItem layoutIfNeeded];
    [fromViewController.searchResultsTableBottomCosntraint.firstItem layoutIfNeeded];
    [fromViewController.view layoutIfNeeded];
}

- (void)performTransitionOut:(VTransitionModel *)model completion:(void (^)(BOOL))completion
{
    VUsersAndTagsSearchViewController *fromViewController = (VUsersAndTagsSearchViewController *)model.fromViewController;
    
    [UIView animateWithDuration:model.animationDuration
                          delay:0.0f
         usingSpringWithDamping:0.9f
          initialSpringVelocity:0.1f
                        options:kNilOptions
                     animations:^
     {
         fromViewController.searchResultsContainerView.alpha = 0.0f;
         fromViewController.searchBarTopHorizontalRule.alpha = 1.0f;
         fromViewController.opaqueBackgroundView.alpha = 0.0f;
         
         fromViewController.searchBarTopConstraint.constant = kStartTopOffset;
         fromViewController.headerTopConstraint.constant = -fromViewController.searchBarViewHeightConstraint.constant;
         
         [fromViewController.searchBarTopConstraint.firstItem layoutIfNeeded];
         [fromViewController.headerTopConstraint.firstItem layoutIfNeeded];
         [fromViewController.searchResultsTableBottomCosntraint.firstItem layoutIfNeeded];
         [fromViewController.view layoutIfNeeded];
     }
                     completion:^(BOOL finished)
     {
         completion( YES );
     }];
}

- (BOOL)requiresImageViewFromOriginViewController
{
    return YES;
}

- (NSTimeInterval)transitionInDuration
{
    return 0.5f;
}

- (NSTimeInterval)transitionOutDuration
{
    return 0.5;
}

@end
