//
//  UIViewController+ForceOrientationChange.m
//  victorious
//
//  Created by Josh Hinman on 5/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIViewController+ForceOrientationChange.h"

@implementation UIViewController (ForceOrientationChange)

+ (void)v_forceOrientationChange
{
    UIViewController *rootVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    UIViewController *vc = [[UIViewController alloc] init];
    [rootVC presentViewController:vc animated:NO completion:^(void)
    {
        [rootVC dismissViewControllerAnimated:NO completion:nil];
    }];
}

@end
