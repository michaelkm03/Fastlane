//
//  VEndCardBannerButton.m
//  AutoplayNext
//
//  Created by Patrick Lynch on 1/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEndCardBannerButton.h"

@implementation VEndCardBannerButton

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn animations:^
     {
         self.backgroundColor = [self.backgroundColor colorWithAlphaComponent:highlighted ? 0.3f : 0.0f];
     }
                     completion:nil];
}

@end
