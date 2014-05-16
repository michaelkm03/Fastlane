//
//  VOwnerStreamViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VOwnerStreamViewController.h"
#import "VConstants.h"

@interface VOwnerStreamViewController ()

@end

@implementation VOwnerStreamViewController

+ (VOwnerStreamViewController *)sharedInstance
{
    static  VOwnerStreamViewController*   sharedInstance;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        sharedInstance = (VOwnerStreamViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kOwnerStreamStoryboardID];
    });
    
    return sharedInstance;
}

- (NSString*)streamName
{
    return @"owner";
}

- (NSArray*)sequenceCategories
{
    return @[kVOwnerPollCategory, kVOwnerImageCategory, kVOwnerVideoCategory, kVOwnerRemixCategory];
}
@end
