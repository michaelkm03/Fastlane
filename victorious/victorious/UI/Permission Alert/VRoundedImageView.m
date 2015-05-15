//
//  VRoundedImageView.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VRoundedImageView.h"

@implementation VRoundedImageView

- (void)layoutSubviews
{
    [super layoutSubviews];
    // Update corner radius after we've been laid out
    self.layer.cornerRadius = CGRectGetHeight(self.bounds) / 2;
}

@end
