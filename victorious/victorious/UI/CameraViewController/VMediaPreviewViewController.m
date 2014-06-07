//
//  VMediaPreviewViewController.m
//  victorious
//
//  Created by Josh Hinman on 4/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSURL+MediaType.h"
#import "VAnalyticsRecorder.h"
#import "VConstants.h"
#import "VImagePreviewViewController.h"
#import "VMediaPreviewViewController.h"
#import "VVideoPreviewViewController.h"

@implementation VMediaPreviewViewController

+ (VMediaPreviewViewController *)previewViewControllerForMediaAtURL:(NSURL *)mediaURL
{
    VMediaPreviewViewController *previewViewController = nil;
    if ([mediaURL v_hasImageExtension])
    {
        previewViewController = [VImagePreviewViewController imagePreviewViewController];
    }
    else if ([mediaURL v_hasVideoExtension])
    {
        previewViewController = [VVideoPreviewViewController videoPreviewViewController];
    }
    
    if (previewViewController)
    {
        previewViewController->_mediaURL = mediaURL;
    }
    return previewViewController;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:@"Camera Preview"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] finishAppView];
}

@end
