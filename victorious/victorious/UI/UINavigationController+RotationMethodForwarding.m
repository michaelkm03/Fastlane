//
//  UINavigationController+RotationMethodForwarding.m
//  victorious
//
//  Created by Josh Hinman on 5/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UINavigationController+RotationMethodForwarding.h"

@implementation UINavigationController (RotationMethodForwarding)

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

@end
