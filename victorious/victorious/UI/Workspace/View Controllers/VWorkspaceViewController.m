//
//  VWorkspaceViewController.m
//  victorious
//
//  Created by Patrick Lynch on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWorkspaceViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>

#import "VDependencyManager+VWorkspace.h"
#import "CIImage+VImage.h"
#import "NSURL+MediaType.h"
#import "UIImageView+Blurring.h"

#import "VVideoToolController.h"
#import "VImageToolController.h"
#import "VCanvasView.h"

#import "VAbstractImageVideoCreationFlowController.h"

#import "victorious-Swift.h"

@interface VWorkspaceViewController() 

@property (nonatomic, weak) IBOutlet UIImageView *blurredBackgroundImageView;

@end

@implementation VWorkspaceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.previewImage != nil)
    {
        [self.blurredBackgroundImageView blurAndAnimateImageToVisible:self.previewImage
                                                        withTintColor:[[UIColor blackColor] colorWithAlphaComponent:0.5f]
                                                          andDuration:0.5f
                                             withConcurrentAnimations:nil];
    }
    
    if ([self.toolController isKindOfClass:[VImageToolController class]])
    {
        [self.canvasView setSourceURL:self.mediaURL
                   withPreloadedImage:self.previewImage];
    }
}

- (void)setMediaURL:(NSURL *)mediaURL
{
    _mediaURL = mediaURL;
    if (self.supportsTools)
    {
        if (self.creationFlowController.mediaType == MediaTypeImage)
        {
            VImageToolController *imageToolController = [[VImageToolController alloc] initWithTools:[self.dependencyManager workspaceTools]];
            NSNumber *initalEditState = [self.dependencyManager numberForKey:VImageToolControllerInitialImageEditStateKey];
            if (initalEditState != nil)
            {
                imageToolController.defaultImageTool = [initalEditState integerValue];
            }
            self.toolController = imageToolController;
        }
        else if (self.creationFlowController.mediaType == MediaTypeVideo)
        {
            VVideoToolController *videoToolController = [[VVideoToolController alloc] initWithTools:[self.dependencyManager workspaceTools]];
            NSNumber *initalEditState = [self.dependencyManager numberForKey:VVideoToolControllerInitalVideoEditStateKey];
            if (initalEditState != nil)
            {
                videoToolController.defaultVideoTool = [initalEditState integerValue];
            }
            self.toolController = videoToolController;
        }
        __weak typeof(self) welf = self;
        self.toolController.canRenderAndExportChangeBlock = ^void(BOOL canRenderAndExport)
        {
            welf.continueButton.enabled = canRenderAndExport;
        };
        self.toolController.snapshotImageBecameAvailable = ^void(UIImage *snapshotImage)
        {
            if (welf.blurredBackgroundImageView.image != nil)
            {
                return;
            }
            welf.previewImage = snapshotImage;
            [welf.blurredBackgroundImageView blurAndAnimateImageToVisible:snapshotImage
                                                            withTintColor:[[UIColor blackColor] colorWithAlphaComponent:0.5f]
                                                              andDuration:0.5f
                                                 withConcurrentAnimations:nil];
        };
        self.toolController.mediaURL = mediaURL;
        self.toolController.delegate = self;
    }
    else
    {
        self.continueButton.enabled = true;
    }
}

- (BOOL)supportsTools
{
    return YES;
}

#pragma mark - Target/Action

- (IBAction)publish:(id)sender
{
    [self publishContent];
}

- (void)publishContent
{
    MBProgressHUD *hudForView = [MBProgressHUD showHUDAddedTo:self.view
                                                     animated:YES];
    hudForView.labelText = self.activityText;
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidFinishWorkspaceEdits];
    
    if (self.supportsTools)
    {
        __weak typeof(self) welf = self;
        [self.toolController exportWithSourceAsset:self.mediaURL
                                    withCompletion:^(BOOL finished, NSURL *renderedMediaURL, UIImage *previewImage, NSError *error)
         {
             VWorkspaceViewController *strongSelf = self;
             if (strongSelf == nil)
             {
                 return;
             }
             
             [hudForView hide:YES];
             if (error != nil)
             {
                 [strongSelf v_showAlertWithTitle:NSLocalizedString(@"Render failure", @"") message:error.localizedDescription completion:nil];
             }
             else
             {
                 [welf callCompletionWithSuccess:YES
                                    previewImage:previewImage
                                renderedMediaURL:renderedMediaURL];
             }
         }];
    }
    
}

#pragma mark - VCoachmarkDisplayer

- (NSString *)screenIdentifier
{
    return [self.dependencyManager stringForKey:VDependencyManagerIDKey];
}

@end
