//
//  VFollowingStreamCollectionViewController.m
//  victorious
//
//  Created by Josh Hinman on 12/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIStoryboard+VMainStoryboard.h"
#import "VDependencyManager+VObjectManager.h"
#import "VFollowingStreamCollectionViewController.h"
#import "VObjectManager.h"
#import "VStream+Fetcher.h"
#import "VNoContentView.h"

@interface VFollowingStreamCollectionViewController ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VFollowingStreamCollectionViewController

#pragma mark VHasManagedDependencies conforming factory method

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VFollowingStreamCollectionViewController *followingStreamViewController = [[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    followingStreamViewController.dependencyManager = dependencyManager;
    VStream *stream = [VStream streamForPath:[dependencyManager stringForKey:VDependencyManagerStreamURLPathKey]
                                   inContext:dependencyManager.objectManager.managedObjectStore.mainQueueManagedObjectContext];
    stream.name = [dependencyManager stringForKey:VDependencyManagerTitleKey];
    followingStreamViewController.currentStream = stream;
    return followingStreamViewController;
}

@end
