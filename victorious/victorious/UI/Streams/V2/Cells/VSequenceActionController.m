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
#import "VUser+Fetcher.h"

#pragma mark - Controllers
#import "VRemixSelectViewController.h"
#import "VCameraPublishViewController.h"
#import "VStreamCollectionViewController.h"
#import "VReposterTableViewController.h"
#import "VAuthorizationViewControllerFactory.h"

#pragma mark-  Views
#import "VNoContentView.h"
#import "VFacebookActivity.h"

#pragma mark - Managers
#import "VObjectManager+Login.h"
#import "VObjectManager+ContentCreation.h"
#import "VObjectManager+Sequence.h"
#import "VThemeManager.h"
#import "VAnalyticsRecorder.h"

#pragma mark - Categories
#import "NSString+VParseHelp.h"
#import "UIActionSheet+VBlocks.h"

@implementation VSequenceActionController

#pragma mark - Remix

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

#pragma mark - Repost

- (void)repostActionFromViewController:(UIViewController *)viewController node:(VNode *)node
{
    if (![VObjectManager sharedManager].authorized)
    {
        [viewController presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }
    
    [[VObjectManager sharedManager] repostNode:node
                                      withName:nil
                                  successBlock:nil
                                     failBlock:nil];
}

- (void)showRepostersFromViewController:(UIViewController *)viewController
{
    VReposterTableViewController *vc = [[VReposterTableViewController alloc] init];
    vc.sequence = self.sequence;
    [viewController.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Share
- (void)shareFromViewController:(UIViewController *)viewController node:(VNode *)node
{
    //Remove the styling for the mail view.
    [[VThemeManager sharedThemeManager] removeStyling];
    
    VFacebookActivity *fbActivity = [[VFacebookActivity alloc] init];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.sequence ?: [NSNull null],
                                                                                                                 [self shareText],
                                                                                                                 [NSURL URLWithString:node.shareUrlPath] ?: [NSNull null]]
                                                                                         applicationActivities:@[fbActivity]];
    
    NSString *emailSubject = [NSString stringWithFormat:NSLocalizedString(@"EmailShareSubjectFormat", nil), [[VThemeManager sharedThemeManager] themedStringForKey:kVChannelName]];
    [activityViewController setValue:emailSubject forKey:@"subject"];
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook];
    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed)
    {
        [[VThemeManager sharedThemeManager] applyStyling];
        [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:[NSString stringWithFormat:@"Shared %@, via %@", self.sequence.category, activityType]
                                                                     action:nil
                                                                      label:nil
                                                                      value:nil];
        [viewController reloadInputViews];
    };
}

//TODO: this is a duplicate of the action item class.  That class should eventually be refactored to utilize a VSequenceActionController, and should clean up the duplicate method.
- (NSString *)shareText
{
    NSString *shareText = @"";
    
    if ([self.sequence.user isOwner])
    {
        if ([self.sequence isPoll])
        {
            shareText = [NSString stringWithFormat:NSLocalizedString(@"OwnerSharePollFormat", nil), self.sequence.user.name];
        }
        else if ([self.sequence isVideo])
        {
            shareText = [NSString stringWithFormat:NSLocalizedString(@"OwnerShareVideoFormat", nil), self.sequence.name, self.sequence.user.name];
        }
        else
        {
            shareText = [NSString stringWithFormat:NSLocalizedString(@"OwnerShareImageFormat", nil), self.sequence.user.name];
        }
    }
    else
    {
        if ([self.sequence isPoll])
        {
            shareText = [NSString stringWithFormat:NSLocalizedString(@"UGCSharePollFormat", nil), self.sequence.user.name];
        }
        else if ([self.sequence isVideo])
        {
            shareText = [NSString stringWithFormat:NSLocalizedString(@"UGCShareVideoFormat", nil), self.sequence.name, self.sequence.user.name];
        }
        else
        {
            shareText = [NSString stringWithFormat:NSLocalizedString(@"UGCShareImageFormat", nil), self.sequence.user.name];
        }
    }
    
    return shareText;
}

- (void)flagFromViewController:(UIViewController *)viewController
{
    [[VObjectManager sharedManager] flagSequence:self.sequence
                                    successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ReportedTitle", @"")
                                                                message:NSLocalizedString(@"ReportContentMessage", @"")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                      otherButtonTitles:nil];
         [alert show];
         
     }
                                       failBlock:^(NSOperation *operation, NSError *error)
     {
         VLog(@"Failed to flag sequence %@", self.sequence);
         
         UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WereSorry", @"")
                                                                message:NSLocalizedString(@"ErrorOccured", @"")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                      otherButtonTitles:nil];
         [alert show];
     }];
}

@end
