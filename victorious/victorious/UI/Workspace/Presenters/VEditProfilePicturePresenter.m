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

- (void)presentOnViewController:(UIViewController *)viewControllerToPresentOn
{
    VAbstractImageVideoCreationFlowController *imageCreationFlowController = [self.dependencyManager templateValueOfType:[VAbstractImageVideoCreationFlowController class]
                                                                                                     forKey:VImageCreationFlowControllerKey];
    imageCreationFlowController.creationFlowDelegate = self;
    imageCreationFlowController.context = self.isRegistration ? VCameraContextProfileImageRegistration : VCameraContextProfileImage;
    
    [viewControllerToPresentOn presentViewController:imageCreationFlowController
                                            animated:YES
                                          completion:nil];
}

#pragma mark - VCreationFlowControllerDelegate

- (void)creationFlowController:(VCreationFlowController *)creationFlowController
      finishedWithPreviewImage:(UIImage *)previewImage
              capturedMediaURL:(NSURL *)capturedMediaURL
{
    if (self.resultHandler != nil)
    {
        self.resultHandler(YES, previewImage, capturedMediaURL);
    }
}

- (void)creationFlowControllerDidCancel:(VCreationFlowController *)creationFlowController
{
    if (self.resultHandler != nil)
    {
        self.resultHandler(NO, nil, nil);
    }
}

- (BOOL)shouldShowPublishScreenForFlowController
{
    return NO;
}

@end
