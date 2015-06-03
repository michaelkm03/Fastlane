//
//  VNavigationControllerScrollDelegate.m
//  victorious
//
//  Created by Josh Hinman on 2/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VNavigationController.h"
#import "VNavigationControllerScrollDelegate.h"

typedef NS_ENUM(NSInteger, VNavigationControllerScrollDelegateState)
{
    VNavigationControllerScrollDelegateStateInactive,
    VNavigationControllerScrollDelegateStateHiding,
    VNavigationControllerScrollDelegateStateShowing
};

static const NSTimeInterval kAnimationDuration = 0.2;
static const CGFloat kThresholdPercent = 0.25f;

@interface VNavigationControllerScrollDelegate ()

@property (nonatomic) VNavigationControllerScrollDelegateState state;
@property (nonatomic) CGFloat offset;
@property (nonatomic) CGFloat navigationBarHeight;
@property (nonatomic) CGFloat translation;
//@property (nonatomic) BOOL dragging; ///< In order to keep track of whether the user flicked outside of the catch offset

@end

@implementation VNavigationControllerScrollDelegate

- (instancetype)initWithNavigationController:(VNavigationController *)navigationController
{
    self = [super init];
    if ( self != nil )
    {
        _navigationController = navigationController;
        _state = VNavigationControllerScrollDelegateStateInactive;
        _offset = 0;
        _catchOffset = 0;
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ( self.state == VNavigationControllerScrollDelegateStateHiding || self.state == VNavigationControllerScrollDelegateStateShowing )
    {
        self.translation = [self translationWithNewContentOffset:[self adjustedContentOffset:scrollView.contentOffset]];
        [self.navigationController transformNavigationBar:CGAffineTransformMakeTranslation(0, self.translation)];
        
        // If user has released their finger and nav bar has scrolled off screen, set it to hidden and return state to default
        if (fabs(self.translation) >= self.navigationBarHeight && !scrollView.tracking)
        {
            [self.navigationController setNavigationBarHidden:YES];
            [self.navigationController transformNavigationBar:CGAffineTransformIdentity];
            self.state = VNavigationControllerScrollDelegateStateInactive;
        }
    }
}

- (CGFloat)translationWithNewContentOffset:(CGPoint)contentOffset
{
    CGFloat translation = self.offset - contentOffset.y;
    translation = MIN(translation, 0);
    translation = MAX(translation, -self.navigationBarHeight);
    return translation;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ( self.navigationController.innerNavigationController.navigationBarHidden )
    {
        self.state = VNavigationControllerScrollDelegateStateShowing;
        [self.navigationController setNavigationBarHidden:NO];
    }
    else
    {
        self.state = VNavigationControllerScrollDelegateStateHiding;
    }

    // calculate scroll view height
    UINavigationBar *navigationBar = self.navigationController.innerNavigationController.navigationBar;
    CGFloat navigationBarHeight = CGRectGetMaxY([navigationBar.window convertRect:navigationBar.bounds fromCoordinateSpace:navigationBar]);
    navigationBarHeight += CGRectGetHeight(self.navigationController.supplementaryHeaderView.frame);
    self.navigationBarHeight = navigationBarHeight;

    CGFloat threshold = self.catchOffset == 0 ? kThresholdPercent : 0;
    self.offset = MAX([self adjustedContentOffset:scrollView.contentOffset].y, self.navigationBarHeight * threshold);

    if ( self.state == VNavigationControllerScrollDelegateStateShowing )
    {
        [self.navigationController transformNavigationBar:CGAffineTransformMakeTranslation(0, -self.navigationBarHeight)];
        self.offset = [self adjustedContentOffset:scrollView.contentOffset].y - self.navigationBarHeight;
    }
}

- (NSTimeInterval)timeIntervalWithVelocity:(CGFloat)velocity distance:(CGFloat)distance
{
    NSTimeInterval const upperLimit = kAnimationDuration;
    
    if ( velocity == 0 )
    {
        return upperLimit;
    }
    
    NSTimeInterval time = MIN(distance / ABS(velocity) / 1000, upperLimit);
    return time;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat const translation = [self translationWithNewContentOffset:[self adjustedContentOffset:*targetContentOffset]];
    
    switch (self.state)
    {
        case VNavigationControllerScrollDelegateStateHiding:
            
            // Only adjust nav bar on release if we're outside of the catch offset
            if (scrollView.contentOffset.y < self.catchOffset)
            {
                return;
            }
            
            if ( ABS(translation) >= self.navigationBarHeight * kThresholdPercent && (*targetContentOffset).y > self.navigationBarHeight )
            {
                [UIView animateWithDuration:[self timeIntervalWithVelocity:velocity.y distance:(self.navigationBarHeight - ABS(self.translation))]
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^(void)
                 {
                     [self.navigationController transformNavigationBar:CGAffineTransformMakeTranslation(0, -self.navigationBarHeight)];
                 }
                                 completion:^(BOOL finished)
                 {
                     [self.navigationController setNavigationBarHidden:YES];
                     [self.navigationController transformNavigationBar:CGAffineTransformIdentity];
                 }];
            }
            else
            {
                [UIView animateWithDuration:kAnimationDuration
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^(void)
                 {
                     [self.navigationController transformNavigationBar:CGAffineTransformIdentity];
                 }
                                 completion:nil];
            }
            
            break;
            
        case VNavigationControllerScrollDelegateStateShowing:
            if ( ABS(translation) <= self.navigationBarHeight * (1.0f - kThresholdPercent) || (*targetContentOffset).y < self.navigationBarHeight )
            {
                [UIView animateWithDuration:[self timeIntervalWithVelocity:velocity.y distance:ABS(self.translation)]
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^(void)
                 {
                     [self.navigationController transformNavigationBar:CGAffineTransformIdentity];
                 }
                                 completion:nil];
            }
            else
            {
                [UIView animateWithDuration:kAnimationDuration
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^(void)
                 {
                     [self.navigationController transformNavigationBar:CGAffineTransformMakeTranslation(0, -self.navigationBarHeight)];
                 }
                                 completion:^(BOOL finished)
                 {
                     [self.navigationController transformNavigationBar:CGAffineTransformIdentity];
                     [self.navigationController setNavigationBarHidden:YES];
                 }];
            }
            break;
            
        default:
            break;
    }
    
    self.state = VNavigationControllerScrollDelegateStateInactive;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.catchOffset == 0)
    {
        return;
    }
    
    // Hide nav bar if it gets stuck in the middle after flick
    CGRect navBarFrame = self.navigationController.innerNavigationController.navigationBar.frame;
    BOOL semiOffscreen = CGRectGetMaxY(navBarFrame) >= 0 && CGRectGetMaxY(navBarFrame) < self.navigationBarHeight;
    
    if (!self.navigationController.innerNavigationController.navigationBarHidden &&
        scrollView.contentOffset.y > self.catchOffset &&
        semiOffscreen &&
        self.state != VNavigationControllerScrollDelegateStateInactive)
    {
        [UIView animateWithDuration:kAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(void)
         {
             [self.navigationController transformNavigationBar:CGAffineTransformMakeTranslation(0, -self.navigationBarHeight)];
         }
                         completion:^(BOOL finished)
         {
             [self.navigationController setNavigationBarHidden:YES];
             [self.navigationController transformNavigationBar:CGAffineTransformIdentity];
         }];
        
        self.state = VNavigationControllerScrollDelegateStateInactive;
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    // Restore nav bar after user taps the status bar to scroll to top
    [self.navigationController transformNavigationBar:CGAffineTransformIdentity];
    [self.navigationController setNavigationBarHidden:NO];
}

- (CGPoint)adjustedContentOffset:(CGPoint)offset
{
    return CGPointMake(offset.x, offset.y - self.catchOffset);
}

@end
