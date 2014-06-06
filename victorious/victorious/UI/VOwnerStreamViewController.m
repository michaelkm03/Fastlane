//
//  VOwnerStreamViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAnalyticsRecorder.h"
#import "VOwnerStreamViewController.h"
#import "VThemeManager.h"
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
        
        sharedInstance.title = [[VThemeManager sharedThemeManager] themedStringForKey:kVChannelName];
    });
    
    return sharedInstance;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:@"Owner Stream"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] finishAppView];
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
