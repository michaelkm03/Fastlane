//
//  VPerfectCircleView.m
//  victorious
//
//  Created by Josh Hinman on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPerfectCircleView.h"

@implementation VPerfectCircleView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat newCornerRadius = CGRectGetHeight(self.bounds) * 0.5f;
    
    if (newCornerRadius != self.layer.cornerRadius)
    {
        self.layer.cornerRadius = newCornerRadius;
    }
}

@end
