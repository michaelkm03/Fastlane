//
//  VSequenceActionController.m
//  victorious
//
//  Created by Will Long on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSequenceActionController.h"

#pragma mark - Models
#import "VAsset.h"
#import "VNode.h"
#import "VSequence+Fetcher.h"
#import "VStream+Fetcher.h"

#pragma mark - Controllers
#import "VRemixSelectViewController.h"
#import "VCameraPublishViewController.h"
#import "VStreamCollectionViewController.h"
#import "VAuthorizationViewControllerFactory.h"

#pragma mark-  Views
#import "VNoContentView.h"

#pragma mark - Managers
#import "VObjectManager+Login.h"

#pragma mark - Categories
#import "NSString+VParseHelp.h"
#import "UIActionSheet+VBlocks.h"

@implementation VSequenceActionController

- (void)remixActionFromViewController:(UIViewController *)viewController asset:(VAsset *)asset node:(VNode *)node
{
    if (![VObjectManager sharedManager].authorized)
    {
        [viewController presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }

    UIViewController *remixVC = [VRemixSelectViewController remixViewControllerWithURL:[asset.data mp4UrlFromM3U8]
                                                                            sequenceID:[self.sequence.remoteId integerValue]
                                                                                nodeID:node.remoteId.integerValue];
    
    [viewController presentViewController:remixVC  animated:YES completion:nil];
}

- (void)imageRemixActionFromViewController:(UIViewController *)viewController previewImage:(UIImage *)previewImage
{
    if (![VObjectManager sharedManager].authorized)
    {
        [viewController presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }
    
    VCameraPublishViewController *publishViewController = [VCameraPublishViewController cameraPublishViewController];
    publishViewController.parentID = [self.sequence.remoteId integerValue];
    publishViewController.previewImage = previewImage;
    publishViewController.completion = ^(BOOL complete)
    {
        [viewController dismissViewControllerAnimated:YES completion:nil];
    };
    
    UINavigationController *remixNav = [[UINavigationController alloc] initWithRootViewController:publishViewController];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                                       onCancelButton:nil
                                               destructiveButtonTitle:nil
                                                  onDestructiveButton:nil
                                           otherButtonTitlesAndBlocks:NSLocalizedString(@"Meme", nil),  ^(void)
                                  {
                                      publishViewController.captionType = VCaptionTypeMeme;
                                      
                                      NSData *filteredImageData = UIImageJPEGRepresentation(previewImage, VConstantJPEGCompressionQuality);
                                      NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
                                      NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionJPG];
                                      if ([filteredImageData writeToURL:tempFile atomically:NO])
                                      {
                                          publishViewController.mediaURL = tempFile;
                                          [viewController presentViewController:remixNav
                                                                       animated:YES
                                                                     completion:nil];
                                      }
                                  },
                                  NSLocalizedString(@"Quote", nil),  ^(void)
                                  {
                                      publishViewController.captionType = VCaptionTypeQuote;
                                      
                                      NSData *filteredImageData = UIImageJPEGRepresentation(previewImage, VConstantJPEGCompressionQuality);
                                      NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
                                      NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionJPG];
                                      if ([filteredImageData writeToURL:tempFile atomically:NO])
                                      {
                                          publishViewController.mediaURL = tempFile;
                                          [viewController presentViewController:remixNav
                                                                       animated:YES
                                                                     completion:nil];
                                      }
                                  }, nil];
    
    [actionSheet showInView:viewController.view];
}

- (void)showRemixStreamFromViewController:(UIViewController *)viewController
{
    
    VStream *stream = [VStream remixStreamForSequence:self.sequence];
    VStreamCollectionViewController  *streamCollection = [VStreamCollectionViewController streamViewControllerForDefaultStream:stream andAllStreams:@[stream] title:NSLocalizedString(@"Remixes", nil)];
    
    VNoContentView *noRemixView = [[VNoContentView alloc] initWithFrame:streamCollection.view.bounds];
    noRemixView.titleLabel.text = NSLocalizedString(@"NoRemixersTitle", @"");
    noRemixView.messageLabel.text = NSLocalizedString(@"NoRemixersMessage", @"");
    noRemixView.iconImageView.image = [UIImage imageNamed:@"noRemixIcon"];
    [viewController.navigationController pushViewController:streamCollection animated:YES];
}

@end
