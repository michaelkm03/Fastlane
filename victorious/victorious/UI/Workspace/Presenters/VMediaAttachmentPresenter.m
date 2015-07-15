//
//  VMediaAttachmentPresenter.m
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VMediaAttachmentPresenter.h"

// Creation
#import "VAbstractImageVideoCreationFlowController.h"
#import "VVideoCreationFlowController.h"

// Dependencies
#import "VDependencyManager.h"

static NSString * const kVideoCreateFlow = @"videoCreateFlow";

@interface VMediaAttachmentPresenter () <VCreationFlowControllerDelegate>

@end

@implementation VMediaAttachmentPresenter

- (instancetype)initWithViewControllerToPresentOn:(UIViewController *)viewControllerToPresentOn dependencymanager:(VDependencyManager *)dependencyManager
{
    self = [super initWithViewControllerToPresentOn:viewControllerToPresentOn
                                  dependencymanager:dependencyManager];
    if (self != nil)
    {
        _attachmentTypes = VMediaAttachmentTypeImage | VMediaAttachmentTypeVideo ;
    }
    return self;
}

- (void)present
{
    UIAlertController *attachmentActionSheet = [UIAlertController alertControllerWithTitle:nil
                                                                                   message:NSLocalizedString(@"Pick an attachment style", nil)
                                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    if (self.attachmentTypes & VMediaAttachmentTypeImage)
    {
        // Image
        UIAlertAction *imageAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Image", nil)
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action)
                                      {
                                          VAbstractImageVideoCreationFlowController *imageCreationFlowController = [self.dependencyManager templateValueOfType:[VAbstractImageVideoCreationFlowController class]
                                                                                                                                           forKey:VImageCreationFlowControllerKey];
                                          imageCreationFlowController.creationFlowDelegate = self;
                                          [self.viewControllerToPresentOn presentViewController:imageCreationFlowController
                                                                                       animated:YES
                                                                                     completion:nil];
                                      }];
        [attachmentActionSheet addAction:imageAction];
    }
    
    if (self.attachmentTypes & VMediaAttachmentTypeVideo)
    {
        // Video
        UIAlertAction *videoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Video", nil)
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action)
                                      {
                                          // Video
                                          VVideoCreationFlowController *videoCreationFlowController = [self.dependencyManager templateValueOfType:[VVideoCreationFlowController class]
                                                                                                                                           forKey:kVideoCreateFlow];
                                          videoCreationFlowController.creationFlowDelegate = self;
                                          [self.viewControllerToPresentOn presentViewController:videoCreationFlowController
                                                                                       animated:YES
                                                                                     completion:nil];
                                      }];
        [attachmentActionSheet addAction:videoAction];
    }
    
    // Cancel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [attachmentActionSheet addAction:cancelAction];
    
    [self.viewControllerToPresentOn presentViewController:attachmentActionSheet animated:YES completion:nil];
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
    else
    {
        [self.viewControllerToPresentOn dismissViewControllerAnimated:YES
                                                           completion:nil];
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
