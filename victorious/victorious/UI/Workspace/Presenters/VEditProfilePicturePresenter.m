//
//  VEditProfilePicturePresenter.m
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEditProfilePicturePresenter.h"

// Dependencies
#import "VDependencyManager.h"

// Creation
#import "VImageCreationFlowController.h"

@interface VEditProfilePicturePresenter () <VCreationFlowControllerDelegate>

@end

@implementation VEditProfilePicturePresenter

- (void)present
{
    VImageCreationFlowController *imageCreationFlowController = [self.dependencyManager templateValueOfType:[VImageCreationFlowController class]
                                                                                                     forKey:VImageCreationFlowControllerKey];
    imageCreationFlowController.creationFlowDelegate = self;
    imageCreationFlowController.context = self.isRegistration ? VWorkspaceFlowControllerContextProfileImageRegistration : VWorkspaceFlowControllerContextProfileImage;
    
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
