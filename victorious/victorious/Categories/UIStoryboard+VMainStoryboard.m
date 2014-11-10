//
//  UIStoryboard+VMainStoryboard.m
//  victorious
//
//  Created by Josh Hinman on 11/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIStoryboard+VMainStoryboard.h"
#import "VConstants.h"
#import "VRootViewController.h"

@implementation UIStoryboard (VMainStoryboard)

+ (UIStoryboard *)v_mainStoryboard
{
    UIViewController *rootViewController = [VRootViewController rootViewController];
    
    if (rootViewController != nil)
    {
        return rootViewController.storyboard;
    }
    else
    {
        return [UIStoryboard storyboardWithName:kMainStoryboardName bundle:nil];
    }
}

@end
