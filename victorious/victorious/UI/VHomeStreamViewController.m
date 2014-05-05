//
//  VHomeStreamViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHomeStreamViewController.h"
#import "VConstants.h"

#import "VCreatePollViewController.h"

#import "VStreamTableViewController+ContentCreation.h"

@interface VHomeStreamViewController ()
@end

@implementation VHomeStreamViewController

+ (VHomeStreamViewController *)sharedInstance
{
    static  VHomeStreamViewController*   sharedInstance;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        sharedInstance = (VHomeStreamViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kHomeStreamStoryboardID];
    });
    
    return sharedInstance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCreateButton];
}

- (NSArray*)categoriesForOption:(NSUInteger)searchOption
{
//    return @[kVOwnerPollCategory, kVUGCPollCategory];
    switch (searchOption)
    {
        case VStreamFilterPolls:
            return @[kVOwnerPollCategory, kVUGCPollCategory];
            
        case VStreamFilterImages:
            return @[kVOwnerImageCategory, kVUGCImageCategory];
            
        case VStreamFilterVideos:
            return @[kVOwnerVideoCategory, kVUGCVideoCategory,
                     kVOwnerRemixCategory, kVUGCRemixCategory];
            
        default:
            return @[kVOwnerPollCategory, kVUGCPollCategory,
                     kVOwnerImageCategory, kVUGCImageCategory,
                     kVOwnerVideoCategory, kVUGCVideoCategory,
                     kVOwnerRemixCategory, kVUGCRemixCategory];
    }
}

@end
