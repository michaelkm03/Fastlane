//
//  VCameraCoachMarkHelper.m
//  victorious
//
//  Created by Michael Sena on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCameraCoachMarkAnimator.h"

@interface VCameraCoachMarkAnimator ()

@property (nonatomic, strong) UIView *coachView;
@property (nonatomic, assign) BOOL hasReceivedFadeOutMessage;

@end

@implementation VCameraCoachMarkAnimator

- (instancetype)initWithCoachView:(UIView *)coachView
{
    self = [super init];
    if (self)
    {
        _coachView = coachView;
        self.coachView.alpha = 0.0f;
    }
    return self;
}

- (void)fadeIn
{
    self.coachView.alpha = 0.0f;
    [UIView animateWithDuration:0.5f
                          delay:0.5f
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^
     {
         self.coachView.alpha = 1.0f;
     }
                     completion:nil];
}

- (void)fadeOut
{
    self.hasReceivedFadeOutMessage = YES;
    [self.coachView.layer removeAllAnimations];
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^
     {
         self.coachView.alpha = 0.0f;
     }
                     completion:nil];
}

- (void)flash
{
    if (!self.hasReceivedFadeOutMessage)
    {
        return;
    }
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^
     {
         self.coachView.alpha = 1.0f;
     }
                     completion:^(BOOL finished)
    {
        [UIView animateWithDuration:1.0f
                              delay:3.0f
                            options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^
         {
             self.coachView.alpha = 0.0f;
         }
                         completion:nil];
    }];
}

@end
