//
//  VWorkspaceViewController.m
//  victorious
//
//  Created by Patrick Lynch on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWorkspaceViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>

#import "VDependencyManager+VWorkspaceTool.h"
#import "CIImage+VImage.h"
#import "NSURL+MediaType.h"
#import "UIImageView+Blurring.h"
#import "UIAlertView+VBlocks.h"
#import "UIActionSheet+VBlocks.h"

#import "VVideoToolController.h"
#import "VImageToolController.h"
#import "VCanvasView.h"

@interface VWorkspaceViewController()

@property (nonatomic, weak) IBOutlet UIImageView *blurredBackgroundImageView;

@end

@implementation VWorkspaceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.previewImage != nil)
    {
        [self.blurredBackgroundImageView setBlurredImageWithClearImage:self.previewImage
                                                      placeholderImage:nil
                                                             tintColor:[[UIColor blackColor] colorWithAlphaComponent:0.5f]];
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
    
    if ([mediaURL v_hasImageExtension])
    {
        VImageToolController *imageToolController = [[VImageToolController alloc] initWithTools:[self.dependencyManager workspaceTools]];
        if (self.initalEditState != nil)
        {
            imageToolController.defaultImageTool = [self.initalEditState integerValue];
        }
        self.toolController = imageToolController;
    }
    else if ([mediaURL v_hasVideoExtension])
    {
        VVideoToolController *videoToolController = [[VVideoToolController alloc] initWithTools:[self.dependencyManager workspaceTools]];
        if (self.initalEditState != nil)
        {
            videoToolController.defaultVideoTool = [self.initalEditState integerValue];
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
        [welf.blurredBackgroundImageView setBlurredImageWithClearImage:snapshotImage
                                                      placeholderImage:nil
                                                             tintColor:[[UIColor blackColor] colorWithAlphaComponent:0.5f]
                                                               animate:YES];
    };
    self.toolController.mediaURL = mediaURL;
    self.toolController.delegate = self;
}

- (void)publishContent
{
    MBProgressHUD *hudForView = [MBProgressHUD showHUDAddedTo:self.view
                                                     animated:YES];
    hudForView.labelText = self.activityText;
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidFinishWorkspaceEdits];
    
    __weak typeof(self) welf = self;
    [self.toolController exportWithSourceAsset:self.mediaURL
                                withCompletion:^(BOOL finished, NSURL *renderedMediaURL, UIImage *previewImage, NSError *error)
     {
         [hudForView hide:YES];
         if (error != nil)
         {
             UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Render failure", @"")
                                                                  message:error.localizedDescription
                                                        cancelButtonTitle:NSLocalizedString(@"ok", @"")
                                                           onCancelButton:nil
                                               otherButtonTitlesAndBlocks:nil, nil];
             [errorAlert show];
         }
         else
         {
             if (welf.completionBlock != nil)
             {
                 welf.completionBlock(YES, previewImage, renderedMediaURL);
             }
         }
     }];
}

- (void)confirmCancel
{
    __weak typeof(self) welf = self;
    UIActionSheet *confirmExitActionSheet = [[UIActionSheet alloc] initWithTitle:self.confirmCancelMessage
                                                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                                  onCancelButton:nil
                                                          destructiveButtonTitle:NSLocalizedString(@"Discard", nil)
                                                             onDestructiveButton:^
                                             {
                                                 welf.completionBlock(NO, nil, nil);
                                             }
                                                      otherButtonTitlesAndBlocks:nil, nil];
    [confirmExitActionSheet showInView:self.view];
}

- (void)bringTopChromeOutOfView
{
    [super bringTopChromeOutOfView];
    
    self.blurredBackgroundImageView.alpha = 0.0f;
}

- (void)bringBottomChromeOutOfView
{
    [super bringBottomChromeOutOfView];
    
    self.blurredBackgroundImageView.alpha = 0.0f;
}

- (void)bringChromeIntoView
{
    // We are returning from being below the top of the nav stack show the image view
    if (self.blurredBackgroundImageView.image != nil)
    {
        self.blurredBackgroundImageView.alpha = 1.0f;
    }
    
    [super bringChromeIntoView];
}

@end
