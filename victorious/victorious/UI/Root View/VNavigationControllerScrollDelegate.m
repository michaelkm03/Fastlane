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
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ( self.state == VNavigationControllerScrollDelegateStateHiding || self.state == VNavigationControllerScrollDelegateStateShowing )
    {
        self.translation = [self translationWithNewContentOffset:scrollView.contentOffset];
        [self.navigationController transformNavigationBar:CGAffineTransformMakeTranslation(0, self.translation)];
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

    self.offset = MAX(scrollView.contentOffset.y, self.navigationBarHeight * kThresholdPercent);

    if ( self.state == VNavigationControllerScrollDelegateStateShowing )
    {
        [self.navigationController transformNavigationBar:CGAffineTransformMakeTranslation(0, -self.navigationBarHeight)];
        self.offset = scrollView.contentOffset.y - self.navigationBarHeight;
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
    CGFloat const translation = [self translationWithNewContentOffset:*targetContentOffset];
    
    switch (self.state)
    {
        case VNavigationControllerScrollDelegateStateHiding:
            if ( ABS(translation) >= self.navigationBarHeight * kThresholdPercent )
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

@end
