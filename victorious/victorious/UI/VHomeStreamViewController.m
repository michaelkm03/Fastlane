//
//  VHomeStreamViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAnalyticsRecorder.h"
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:@"Home Stream"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] finishAppView];
}

- (NSString*)streamName
{
    return @"home";
}

- (NSArray*)sequenceCategories
{
    return [VUGCCategories() arrayByAddingObjectsFromArray:VOwnerCategories()];
}

@end
