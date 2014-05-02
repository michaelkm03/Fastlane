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
    if ([VConstantMediaExtensionPNG isEqualToString:mediaExtension]  ||
        [VConstantMediaExtensionJPEG isEqualToString:mediaExtension] ||
        [VConstantMediaExtensionJPG isEqualToString:mediaExtension])
    {
        previewViewController = [VImagePreviewViewController imagePreviewViewController];
    }
    else if ([VConstantMediaExtensionMOV isEqualToString:mediaExtension] ||
             [VConstantMediaExtensionMP4 isEqualToString:mediaExtension])
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
