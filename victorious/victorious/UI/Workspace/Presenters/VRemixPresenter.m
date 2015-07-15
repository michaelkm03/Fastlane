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

// Dependencies
#import "VDependencyManager.h"
#import "VAbstractImageVideoCreationFlowController.h"

static NSString * const kImageCreationFlowKey = @"imageCreateFlow";

@interface VRemixPresenter () <VCreationFlowControllerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VSequence *sequenceToRemix;

@end

@implementation VRemixPresenter

@synthesize dependencyManager = _dependencyManager;

- (instancetype)initWithViewControllerToPresentOn:(UIViewController *)viewControllerToPresentOn dependencymanager:(VDependencyManager *)dependencyManager
{
    NSAssert(NO, @"Use initWithViewControllerToPresentOn:dependencymanager:sequenceToRemix:");
    return [self initWithViewControllerToPresentOn:viewControllerToPresentOn
                                 dependencymanager:dependencyManager
                                   sequenceToRemix:nil];
}

- (instancetype)initWithViewControllerToPresentOn:(UIViewController *)viewControllerToPresentOn
                                dependencymanager:(VDependencyManager *)dependencyManager
                                  sequenceToRemix:(VSequence *)sequenceToRemix
{
    NSParameterAssert(sequenceToRemix != nil);
    self = [super initWithViewControllerToPresentOn:viewControllerToPresentOn
                                 dependencymanager:dependencyManager];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
        _sequenceToRemix = sequenceToRemix;
    }
    return self;
}

#pragma mark - Overrides

- (void)present
{
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
        VAbstractImageVideoCreationFlowController *flowController = [self.dependencyManager templateValueOfType:[VAbstractImageVideoCreationFlowController class]
                                                                                            forKey:kImageCreationFlowKey];
        flowController.creationFlowDelegate = self;
        [flowController remixWithPreviewImage:nil mediaURL:remixURL];
        [self.viewControllerToPresentOn presentViewController:flowController
                                                     animated:YES
                                                   completion:nil];
    }
}

#pragma mark - VCreationFlowControllerDelegate
                                                             
- (void)creationFLowController:(VCreationFlowController *)creationFlowController
      finishedWithPreviewImage:(UIImage *)previewImage
              capturedMediaURL:(NSURL *)capturedMediaURL
{
    [self.viewControllerToPresentOn dismissViewControllerAnimated:YES completion:nil];
}

- (void)creationFlowControllerDidCancel:(VCreationFlowController *)creationFlowController
{
    [self.viewControllerToPresentOn dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldShowPublishScreenForFlowController
{
    return YES;
}

@end
