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
#import "VImageCreationFlowController.h"
#import "VGIFCreationFlowController.h"

// Dependencies
#import "VDependencyManager.h"

@interface VMediaAttachmentPresenter () <VCreationFlowControllerDelegate>

@property (nonatomic, weak) UIViewController *viewControllerPresentedOn;
@property (nonatomic, strong) NSDictionary *addedDependencies;

@end

@implementation VMediaAttachmentPresenter

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
                        addedDependencies:(NSDictionary *)addedDependencies
{
    self = [self initWithDependencyManager:dependencyManager];
    if (self != nil)
    {
        _addedDependencies = addedDependencies;
    }
    return self;
}

- (void)presentOnViewController:(UIViewController *)viewControllerToPresentOn
{
    self.viewControllerPresentedOn = viewControllerToPresentOn;
    UIAlertController *attachmentActionSheet = [UIAlertController alertControllerWithTitle:nil
                                                                                   message:NSLocalizedString(@"Pick an attachment style", nil)
                                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    
    void (^imageActionHandler)(void) = ^void(void)
    {
        VAbstractImageVideoCreationFlowController *imageCreationFlowController = [self.dependencyManager templateValueOfType:[VAbstractImageVideoCreationFlowController class]
                                                                                                                      forKey:VImageCreationFlowControllerKey
                                                                                                       withAddedDependencies:self.addedDependencies];
        imageCreationFlowController.creationFlowDelegate = self;
        [viewControllerToPresentOn presentViewController:imageCreationFlowController
                                                     animated:YES
                                                   completion:nil];
    };
    void (^videoActionHandler)(void) = ^void(void)
    {
        VVideoCreationFlowController *videoCreationFlowController = [self.dependencyManager templateValueOfType:[VVideoCreationFlowController class]
                                                                                                         forKey:VVideoCreationFlowControllerKey
                                                                                          withAddedDependencies:self.addedDependencies];
        videoCreationFlowController.creationFlowDelegate = self;
        [viewControllerToPresentOn presentViewController:videoCreationFlowController
                                                     animated:YES
                                                   completion:nil];
    };
    void (^gifActionHandler)(void) = ^void(void)
    {
        VGIFCreationFlowController *gifCreationFlowController = [self.dependencyManager templateValueOfType:[VGIFCreationFlowController class]
                                                                                                     forKey:VGIFCreationFlowControllerKey
                                                                                      withAddedDependencies:self.addedDependencies];
        gifCreationFlowController.creationFlowDelegate = self;
        [viewControllerToPresentOn presentViewController:gifCreationFlowController
                                                animated:YES
                                              completion:nil];
    };
    
    if (self.attachmentTypes & VMediaAttachmentOptionsImage)
    {
        // Image
        UIAlertAction *imageAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Image", nil)
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action)
                                      {
                                          imageActionHandler();
                                      }];
        [attachmentActionSheet addAction:imageAction];
    }
    
    if (self.attachmentTypes & VMediaAttachmentOptionsVideo)
    {
        // Video
        UIAlertAction *videoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Video", nil)
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action)
                                      {
                                          videoActionHandler();
                                      }];
        [attachmentActionSheet addAction:videoAction];
    }
    
    if (self.attachmentTypes & VMediaAttachmentOptionsGIF)
    {
        // GIF
        UIAlertAction *gifAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"GIF", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action)
                                    {
                                        gifActionHandler();
                                    }];
        [attachmentActionSheet addAction:gifAction];
    }
    
    // If we only have one option then just show it.
    if (attachmentActionSheet.actions.count == 1)
    {
        if (self.attachmentTypes & VMediaAttachmentOptionsImage)
        {
            imageActionHandler();
        }
        else if (self.attachmentTypes & VMediaAttachmentOptionsVideo)
        {
            videoActionHandler();
        }
        else if (self.attachmentTypes & VMediaAttachmentOptionsGIF)
        {
            gifActionHandler();
        }
    }
    else if (attachmentActionSheet.actions.count > 1)
    {
        // Cancel
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        [attachmentActionSheet addAction:cancelAction];
        [viewControllerToPresentOn presentViewController:attachmentActionSheet animated:YES completion:nil];
    }
    else // Invalid state
    {
        NSAssert(false, @"Invalid attachment types!");
    }
}

#pragma mark - VCreationFlowControllerDelegate

- (void)creationFlowController:(VCreationFlowController *)creationFlowController
      finishedWithPreviewImage:(UIImage *)previewImage
              capturedMediaURL:(NSURL *)capturedMediaURL
{
    if (self.resultHandler != nil)
    {
        self.resultHandler(YES, creationFlowController.publishParameters);
    }
    else
    {
        [self.viewControllerPresentedOn dismissViewControllerAnimated:YES
                                                           completion:nil];
    }
}

- (void)creationFlowControllerDidCancel:(VCreationFlowController *)creationFlowController
{
    if (self.resultHandler != nil)
    {
        self.resultHandler(NO, nil);
    }
}

- (BOOL)shouldShowPublishScreenForFlowController
{
    return NO;
}

@end
