//
//  VMediaAttachmentPresenter.m
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VMediaAttachmentPresenter.h"

// Creation
#import "VImageCreationFlowController.h"

// Dependencies
#import "VDependencyManager.h"

@interface VMediaAttachmentPresenter () <VCreationFlowControllerDelegate>

@end

@implementation VMediaAttachmentPresenter

- (void)present
{
#warning Add an action sheet to pick between image/video/GIF?
    VImageCreationFlowController *imageCreationFlowController = [self.dependencyManager templateValueOfType:[VImageCreationFlowController class]
                                                                                                     forKey:VImageCreationFlowControllerKey];
    imageCreationFlowController.creationFlowDelegate = self;
    [self.viewControllerToPresentOn presentViewController:imageCreationFlowController
                                                 animated:YES
                                               completion:nil];
}

#pragma mark - VCreationFlowControllerDelegate

- (void)creationFLowController:(VCreationFlowController *)creationFlowController
      finishedWithPreviewImage:(UIImage *)previewImage
              capturedMediaURL:(NSURL *)capturedMediaURL
{
    if (self.completion != nil)
    {
        self.completion(YES, previewImage, capturedMediaURL);
    }
    [self.viewControllerToPresentOn dismissViewControllerAnimated:YES
                                                       completion:nil];
}

- (void)creationFlowControllerDidCancel:(VCreationFlowController *)creationFlowController
{
    if (self.completion != nil)
    {
        self.completion(NO, nil, nil);
    }
}

- (BOOL)shouldShowPublishScreenForFlowController
{
    return NO;
}

@end
