//
//  DeviceTableViewController+RotationMethods.m
//  victorious
//
//  Created by Josh Hinman on 5/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "DeviceTableViewController+RotationMethods.h"

@implementation DeviceTableViewController (RotationMethods)

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
