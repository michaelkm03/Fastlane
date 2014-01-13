//
//  VOwnerStreamsTableViewController.m
//  victorious
//
//  Created by Will Long on 1/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VOwnerStreamsTableViewController.h"
#import "VStreamsTableViewController+Protected.h"

#import "VConstants.h"

@implementation VOwnerStreamsTableViewController

+ (instancetype)sharedStreamsTableViewController
{
    static  VOwnerStreamsTableViewController*   streamsTableViewController;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        streamsTableViewController = (VOwnerStreamsTableViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"ownerstream"];
    });
    
    return streamsTableViewController;
}

- (NSArray*)imageCategories
{
    return @[kVOwnerImageCategory];
}

- (NSArray*)videoCategories
{
    return @[kVOwnerVideoCategory];
}

- (NSArray*)pollCategories
{
    return @[kVOwnerPollCategory];
}

- (NSArray*)forumCategories
{
    return @[kVOwnerForumCategory];
}

@end
