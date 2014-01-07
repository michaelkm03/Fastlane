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

- (NSPredicate*)forumPredicate
{
    return [NSPredicate predicateWithFormat:@"category == %@", kVUGCForumCategory];
}

- (NSPredicate*)imagePredicate
{
    return [NSPredicate predicateWithFormat:@"category == %@", kVUGCImageCategory];
}

- (NSPredicate*)pollPredicate
{
    return [NSPredicate predicateWithFormat:@"category == %@", kVUGCPollCategory];
}

- (NSPredicate*)videoPredicate
{
    return [NSPredicate predicateWithFormat:@"category == %@", kVUGCVideoCategory];
}

@end
