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
#import "UIAlertView+VBlocks.h"
#import "UIActionSheet+VBlocks.h"

#import "VVideoToolController.h"
#import "VImageToolController.h"
#import "VCanvasView.h"
#import "VCoachmarkDisplayer.h"

@interface VWorkspaceViewController() <VCoachmarkDisplayer>

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
                                                          andDuration:0.5f];
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
        [welf.blurredBackgroundImageView blurAndAnimateImageToVisible:snapshotImage
                                                        withTintColor:[[UIColor blackColor] colorWithAlphaComponent:0.5f]
                                                          andDuration:0.5f];
    };
    self.toolController.mediaURL = mediaURL;
    self.toolController.delegate = self;
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
    
    __weak typeof(self) welf = self;
    [self.toolController exportWithSourceAsset:self.mediaURL
                                withCompletion:^(BOOL finished, NSURL *renderedMediaURL, UIImage *previewImage, NSError *error)
     {
         [hudForView hide:YES];
         if (error != nil)
         {
             UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Render failure", @"")
                                                                  message:error.localizedDescription
                                                        cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                           onCancelButton:nil
                                               otherButtonTitlesAndBlocks:nil, nil];
             [errorAlert show];
         }
         else
         {
             [welf callCompletionWithSuccess:YES
                                previewImage:previewImage
                            renderedMediaURL:renderedMediaURL];
         }
     }];
}

- (IBAction)close:(id)sender
{
    if (self.shouldConfirmCancels)
    {
        __weak typeof(self) welf = self;
        UIActionSheet *confirmExitActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"This will discard any content from the camera", @"")
                                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                                      onCancelButton:nil
                                                              destructiveButtonTitle:NSLocalizedString(@"Discard", nil)
                                                                 onDestructiveButton:^
                                                 {
                                                     [welf callCompletionWithSuccess:NO
                                                                        previewImage:nil
                                                                    renderedMediaURL:nil];
                                                 }
                                                          otherButtonTitlesAndBlocks:nil, nil];
        [confirmExitActionSheet showInView:self.view];
        return;
    }
    [self callCompletionWithSuccess:NO
                       previewImage:nil
                   renderedMediaURL:nil];
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

#pragma mark - VCoachmarkDisplayer

- (NSString *)screenIdentifier
{
    return [self.dependencyManager stringForKey:VScreenIdentifierKey];
}

@end
