//
//  UIActivityViewController+VStatusBarHandling.m
//  victorious
//
//  Created by Will Long on 7/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIActivityViewController+VStatusBarHandling.h"

@implementation UIActivityViewController (VStatusBarHandling)

- (BOOL)prefersStatusBarHidden
{
    return [self.presentingViewController prefersStatusBarHidden];
}

@end
