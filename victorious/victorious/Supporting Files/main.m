
//
//  main.m
//  victorious
//
//  Created by Will Long on 12/23/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VAppDelegate.h"

#import <ADEUMInstrumentation/ADEUMInstrumentation.h>

int main(int argc, char *argv[])
{
    [ADEumInstrumentation initWithKey:@"AD-AAB-AAA-JWA"];
    @autoreleasepool
    {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([VAppDelegate class]));
    }
}

