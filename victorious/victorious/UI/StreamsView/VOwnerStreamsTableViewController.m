//
//  VOwnerStreamsTableViewController.m
//  victorious
//
//  Created by Will Long on 1/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VOwnerStreamsTableViewController.h"
#import "VStreamsTableViewController+Protected.h"

@implementation VOwnerStreamsTableViewController

- (NSPredicate*)forumPredicate
{
    return [NSPredicate predicateWithFormat:@"category == 'owner_forum'"];
}

- (NSPredicate*)imagePredicate
{
    return [NSPredicate predicateWithFormat:@"category == 'owner_image'"];
}

- (NSPredicate*)pollPredicate
{
    return [NSPredicate predicateWithFormat:@"category == 'owner_poll'"];
}

- (NSPredicate*)videoPredicate
{
    return [NSPredicate predicateWithFormat:@"category == 'owner_video'"];
}

@end
