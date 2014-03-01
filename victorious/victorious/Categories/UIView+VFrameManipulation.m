//
//  UIView+VFrameManipulation.m
//  victorious
//
//  Created by Will Long on 2/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIView+VFrameManipulation.h"

@implementation UIView (VFrameManipulation)

- (void) setYOrigin:(CGFloat)newYOrigin
{
    self.frame = CGRectMake(newYOrigin,
                            self.frame.origin.x,
                            self.frame.size.width,
                            self.frame.size.height);
}

@end
