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
    self.frame = CGRectMake(self.frame.origin.x,
                            newYOrigin,
                            self.frame.size.width,
                            self.frame.size.height);
}
- (void) setXOrigin:(CGFloat)newXOrigin
{
    self.frame = CGRectMake(newXOrigin,
                            self.frame.origin.y,
                            self.frame.size.width,
                            self.frame.size.height);
}

- (void)setSize:(CGSize)newSize
{
    self.frame = CGRectMake(self.frame.origin.y,
                        self.frame.origin.y,
                        newSize.width,
                        newSize.height);
}

@end
