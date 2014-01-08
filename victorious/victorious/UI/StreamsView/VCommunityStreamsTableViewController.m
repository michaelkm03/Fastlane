//
//  VCommunityStreamsTableViewController.m
//  victorious
//
//  Created by Will Long on 1/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommunityStreamsTableViewController.h"
#import "VStreamsTableViewController+Protected.h"

@implementation VCommunityStreamsTableViewController

+ (instancetype)sharedStreamsTableViewController
{
    static  VCommunityStreamsTableViewController*   streamsTableViewController;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        streamsTableViewController = (VCommunityStreamsTableViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"communitystream"];
    });
    
    return streamsTableViewController;
}

- (NSArray*)imageCategories
{
    return @[kVUGCImageCategory];
}

- (NSArray*)videoCategories
{
    return @[kVUGCVideoCategory];
}

- (NSArray*)pollCategories
{
    return @[kVUGCPollCategory];
}

- (NSArray*)forumCategories
{
    return @[kVUGCForumCategory];
}


@end
