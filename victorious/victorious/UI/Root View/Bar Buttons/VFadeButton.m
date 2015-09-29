//
//  VFadeButton.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFadeButton.h"

@interface VFadeButton ()

@end

@implementation VFadeButton

- (void)setHighlighted:(BOOL)highlighted
{
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^
    {
        self.alpha = highlighted ? 0.3f : 1.0f;
    } completion:nil];
}

@end
