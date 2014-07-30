//
//  VCommunityStreamViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAnalyticsRecorder.h"
#import "VCommunityStreamViewController.h"
#import "VConstants.h"

#import "VStreamTableViewController+ContentCreation.h"

@implementation VCommunityStreamViewController

+ (VCommunityStreamViewController *)sharedInstance
{
    static  VCommunityStreamViewController*   sharedInstance;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        sharedInstance = (VCommunityStreamViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kCommunityStreamStoryboardID];
    });
    
    return sharedInstance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addCreateButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:@"Community Stream"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] finishAppView];
}

- (NSString*)streamName
{
    return @"ugc";
}

- (NSArray*)sequenceCategories
{
    return VUGCCategories();
}

@end
