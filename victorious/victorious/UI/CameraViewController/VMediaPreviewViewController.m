//
//  VMediaPreviewViewController.m
//  victorious
//
//  Created by Josh Hinman on 4/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConstants.h"
#import "VImagePreviewViewController.h"
#import "VMediaPreviewViewController.h"
#import "VVideoPreviewViewController.h"

@implementation VMediaPreviewViewController

+ (VMediaPreviewViewController *)previewViewControllerForMediaAtURL:(NSURL *)mediaURL
{
    NSString *mediaExtension = [mediaURL pathExtension];
    VMediaPreviewViewController *previewViewController = nil;
    if ([@"png"  isEqualToString:mediaExtension] ||
        [@"jpg"  isEqualToString:mediaExtension] ||
        [@"jpeg" isEqualToString:mediaExtension])
    {
        previewViewController = [VImagePreviewViewController imagePreviewViewController];
    }
    else if ([@"mov" isEqualToString:mediaExtension] ||
             [@"mp4" isEqualToString:mediaExtension])
    {
        previewViewController = [VVideoPreviewViewController videoPreviewViewController];
    }
    
    if (previewViewController)
    {
        previewViewController->_mediaURL = mediaURL;
    }
    return previewViewController;
}

@end
