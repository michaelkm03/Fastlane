//
//  VRepostAnimator.m
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VRepostAnimator.h"

static CGFloat const kScaleActive               = 1.0f;
static CGFloat const kScaleScaledUp             = 1.4f;
static CGFloat const kRepostedDisabledAlpha     = 0.3f;

@interface VRepostAnimator ()

@property (nonatomic, assign) BOOL isAnimating;

@end

@implementation VRepostAnimator

- (void)updateRepostWithAnimations:(void (^)())animations
                          onButton:(UIButton *)button
                          animated:(BOOL)animated
{
    if (!animated)
    {
        if (animations)
        {
            animations();
        }
        return;
    }
    
    if (self.isAnimating)
    {
        if (animations)
        {
            animations();
        }
        return;
    }
    
    self.isAnimating = YES;
    [UIView animateWithDuration:0.15f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.8f
                        options:kNilOptions
                     animations:^
     {
         if (animations)
         {
             animations();
         }
         button.transform = CGAffineTransformMakeScale( kScaleScaledUp, kScaleScaledUp );
         button.alpha = kRepostedDisabledAlpha;
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.5f
                               delay:0.0f
              usingSpringWithDamping:0.8f
               initialSpringVelocity:0.9f
                             options:kNilOptions
                          animations:^
          {
              button.transform = CGAffineTransformMakeScale( kScaleActive, kScaleActive );
          }
                          completion:^(BOOL finished)
          {
              self.isAnimating = NO;
          }];
     }];
}

@end
