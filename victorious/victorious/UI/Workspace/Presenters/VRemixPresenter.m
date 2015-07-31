//
//  VRemixPresenter.m
//  victorious
//
//  Created by Michael Sena on 7/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VRemixPresenter.h"

// Remixing
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset+Fetcher.h"
#import "VImageToolController.h"

// Dependencies
#import "VDependencyManager.h"
#import "VAbstractImageVideoCreationFlowController.h"

static NSString * const kImageCreationFlowKey = @"imageCreateFlow";
static NSString * const kGifCreationFlowKey = @"gifCreateFlow";

@interface VRemixPresenter () <VCreationFlowControllerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VSequence *sequenceToRemix;

@property (nonatomic, weak) UIViewController *viewControllerPresentedOn;

@end

@implementation VRemixPresenter

@synthesize dependencyManager = _dependencyManager;

- (instancetype)initWithDependencymanager:(VDependencyManager *)dependencyManager
{
    NSAssert(NO, @"Use initWithViewControllerToPresentOn:dependencymanager:sequenceToRemix:");
    return [self initWithDependencymanager:dependencyManager
                           sequenceToRemix:nil];
}

- (instancetype)initWithDependencymanager:(VDependencyManager *)dependencyManager
                          sequenceToRemix:(VSequence *)sequenceToRemix
{
    NSParameterAssert(sequenceToRemix != nil);
    self = [super initWithDependencymanager:dependencyManager];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
        _sequenceToRemix = sequenceToRemix;
    }
    return self;
}

#pragma mark - Overrides

- (void)presentOnViewController:(UIViewController *)viewControllerToPresentOn
{
    self.viewControllerPresentedOn = viewControllerToPresentOn;
    
    NSURL *remixURL;
    if (self.sequenceToRemix.isImage)
    {
        remixURL = [[[self.sequenceToRemix firstNode] imageAsset] dataURL];
    }
    else if (self.sequenceToRemix.isVideo)
    {
        remixURL = [[[self.sequenceToRemix firstNode] mp4Asset] dataURL];
    }
    if ([self.sequenceToRemix isImage])
    {
        NSDictionary *remixInitialDependencies = @{VImageToolControllerInitialImageEditStateKey:@(VImageToolControllerInitialImageEditStateText)};
        VAbstractImageVideoCreationFlowController *flowController = [self.dependencyManager templateValueOfType:[VAbstractImageVideoCreationFlowController class]
                                                                                                         forKey:kImageCreationFlowKey
                                                                                          withAddedDependencies:remixInitialDependencies];
        flowController.creationFlowDelegate = self;
        [flowController remixWithPreviewImage:nil
                                     mediaURL:remixURL
                                 parentNodeID:[self.sequenceToRemix firstNode].remoteId
                             parentSequenceID:self.sequenceToRemix.remoteId];
        [viewControllerToPresentOn presentViewController:flowController
                                                animated:YES
                                              completion:nil];
    }
    else if ([self.sequenceToRemix isVideo])
    {
        VAbstractImageVideoCreationFlowController *flowController = [self.dependencyManager templateValueOfType:[VAbstractImageVideoCreationFlowController class]
                                                                                                         forKey:kGifCreationFlowKey];
        flowController.creationFlowDelegate = self;
        [flowController remixWithPreviewImage:nil
                                     mediaURL:remixURL
                                 parentNodeID:[self.sequenceToRemix firstNode].remoteId
                             parentSequenceID:self.sequenceToRemix.remoteId];
        [viewControllerToPresentOn presentViewController:flowController
                                                animated:YES
                                              completion:nil];
    }
}

#pragma mark - VCreationFlowControllerDelegate
                                                             
- (void)creationFlowController:(VCreationFlowController *)creationFlowController
      finishedWithPreviewImage:(UIImage *)previewImage
              capturedMediaURL:(NSURL *)capturedMediaURL
{
    [self.viewControllerPresentedOn dismissViewControllerAnimated:YES completion:nil];
}

- (void)creationFlowControllerDidCancel:(VCreationFlowController *)creationFlowController
{
    [self.viewControllerPresentedOn dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldShowPublishScreenForFlowController
{
    return YES;
}

@end
