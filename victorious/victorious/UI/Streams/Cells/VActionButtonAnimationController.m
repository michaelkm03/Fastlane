//
//  VRepostButtonController.m
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VActionButtonAnimationController.h"

static CGFloat const kScaleActive   = 1.0f;
static CGFloat const kScaleScaledUp = 1.4f;

@implementation VActionButtonAnimationController

- (void)setButton:(UIButton *)button selected:(BOOL)selected
{
    const BOOL wasSelected = button.selected;
    button.selected = selected;
    
    const BOOL shouldAnimate = !wasSelected && selected;
    if ( !shouldAnimate )
    {
        return;
    }
    
    [UIView animateWithDuration:0.15f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.8f
                        options:kNilOptions
                     animations:^
     {
         button.transform = CGAffineTransformMakeScale( kScaleScaledUp, kScaleScaledUp );
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
                          completion:nil];
     }];
}

@end
