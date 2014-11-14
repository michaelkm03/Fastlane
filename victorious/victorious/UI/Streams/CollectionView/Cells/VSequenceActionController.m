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
#import "VUserProfileViewController.h"
#import "VCommentsContainerViewController.h"

#pragma mark-  Views
#import "VNoContentView.h"
#import "VFacebookActivity.h"

#pragma mark - Managers
#import "VObjectManager+Login.h"
#import "VObjectManager+ContentCreation.h"
#import "VObjectManager+Sequence.h"
#import "VThemeManager.h"

#pragma mark - Categories
#import "NSString+VParseHelp.h"
#import "UIActionSheet+VBlocks.h"

@implementation VSequenceActionController

#pragma mark - Comments

- (void)showCommentsFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence
{
    VCommentsContainerViewController *commentsTable = [VCommentsContainerViewController commentsContainerView];
    commentsTable.sequence = sequence;
    [viewController.navigationController pushViewController:commentsTable animated:YES];
}

#pragma mark - User

- (BOOL)showPosterProfileFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence
{
    if ( !viewController || !viewController.navigationController || !sequence )
    {
        return NO;
    }
    
    if ( [viewController isKindOfClass:[VUserProfileViewController class]] &&
        [((VUserProfileViewController *)viewController).profile isEqual:sequence.user] )
    {
        return NO;
    }
    
    VUserProfileViewController *profileViewController = [VUserProfileViewController userProfileWithUser:sequence.user];
    [viewController.navigationController pushViewController:profileViewController animated:YES];
    
    return YES;
}

#pragma mark - Remix

- (void)videoRemixActionFromViewController:(UIViewController *)viewController asset:(VAsset *)asset node:(VNode *)node sequence:(VSequence *)sequence
{
    NSAssert(![sequence isPoll], @"You cannot remix polls.");
    if (![VObjectManager sharedManager].authorized)
    {
        [viewController presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }

    UIViewController *remixVC = [VRemixSelectViewController remixViewControllerWithURL:[asset.data mp4UrlFromM3U8]
                                                                            sequenceID:[sequence.remoteId integerValue]
                                                                                nodeID:node.remoteId.integerValue];
    
    [viewController presentViewController:remixVC  animated:YES completion:nil];
}

- (void)imageRemixActionFromViewController:(UIViewController *)viewController previewImage:(UIImage *)previewImage sequence:(VSequence *)sequence
{
    [self imageRemixActionFromViewController:viewController previewImage:previewImage sequence:sequence completion:nil];
}

- (void)imageRemixActionFromViewController:(UIViewController *)viewController previewImage:(UIImage *)previewImage sequence:(VSequence *)sequence completion:(void(^)(BOOL))completion
{
    NSAssert(![sequence isPoll], @"You cannot remix polls.");
    if (![VObjectManager sharedManager].authorized)
    {
        [viewController presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }
    
    VCameraPublishViewController *publishViewController = [VCameraPublishViewController cameraPublishViewController];
    publishViewController.parentSequenceID = [sequence.remoteId integerValue];
    publishViewController.parentNodeID = [sequence.firstNode.remoteId integerValue];
    publishViewController.previewImage = previewImage;
    if ( completion == nil )
    {
        publishViewController.completion = ^(BOOL complete)
        {
            [viewController dismissViewControllerAnimated:YES completion:nil];
        };
    }
    else
    {
        publishViewController.completion = completion;
    }
    
    UINavigationController *remixNav = [[UINavigationController alloc] initWithRootViewController:publishViewController];
    
    void(^writeBlock)(void) = ^void(void)
    {
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
    };
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                                       onCancelButton:nil
                                               destructiveButtonTitle:nil
                                                  onDestructiveButton:nil
                                           otherButtonTitlesAndBlocks:NSLocalizedString(@"Meme", nil),  ^(void)
                                  {
                                      publishViewController.captionType = VCaptionTypeMeme;
                                      writeBlock();
                                  },
                                  NSLocalizedString(@"Quote", nil),  ^(void)
                                  {
                                      publishViewController.captionType = VCaptionTypeQuote;
                                      writeBlock();
                                  }, nil];
    
    [actionSheet showInView:viewController.view];
}

- (void)showRemixStreamFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence
{
    VStream *stream = [VStream remixStreamForSequence:sequence];
    VStreamCollectionViewController  *streamCollection = [VStreamCollectionViewController streamViewControllerForDefaultStream:stream andAllStreams:@[stream] title:NSLocalizedString(@"Remixes", nil)];
    
    VNoContentView *noRemixView = [VNoContentView noContentViewWithFrame:streamCollection.view.bounds];
    noRemixView.titleLabel.text = NSLocalizedString(@"NoRemixersTitle", @"");
    noRemixView.messageLabel.text = NSLocalizedString(@"NoRemixersMessage", @"");
    noRemixView.iconImageView.image = [UIImage imageNamed:@"noRemixIcon"];
    streamCollection.noContentView = noRemixView;
    
    [viewController.navigationController pushViewController:streamCollection animated:YES];
}

#pragma mark - Repost

- (BOOL)repostActionFromViewController:(UIViewController *)viewController node:(VNode *)node
{
    return [self repostActionFromViewController:viewController node:node completion:nil];
}

- (BOOL)repostActionFromViewController:(UIViewController *)viewController node:(VNode *)node completion:(void(^)(BOOL))completion
{
    if (![VObjectManager sharedManager].authorized)
    {
        [viewController presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return NO;
    }
    
    [[VObjectManager sharedManager] repostNode:node
                                      withName:nil
                                  successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         if ( completion != nil )
         {
             node.sequence.repostCount = @( node.sequence.repostCount.integerValue + 1 );
             completion( YES );
         }
     }
                                     failBlock:^(NSOperation *operation, NSError *error)
     {
         if ( completion != nil )
         {
             completion( NO );
         }
     }];
    
    return YES;
}

- (void)showRepostersFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence
{
    VReposterTableViewController *vc = [[VReposterTableViewController alloc] init];
    vc.sequence = sequence;
    [viewController.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Share

- (void)shareFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence node:(VNode *)node
{
    //Remove the styling for the mail view.
    [[VThemeManager sharedThemeManager] removeStyling];
    
    VFacebookActivity *fbActivity = [[VFacebookActivity alloc] init];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[sequence ?: [NSNull null],
                                                                                                                 [self shareTextForSequence:sequence],
                                                                                                                 [NSURL URLWithString:node.shareUrlPath] ?: [NSNull null]]
                                                                                         applicationActivities:@[fbActivity]];
    
    NSString *emailSubject = [NSString stringWithFormat:NSLocalizedString(@"EmailShareSubjectFormat", nil), [[VThemeManager sharedThemeManager] themedStringForKey:kVChannelName]];
    [activityViewController setValue:emailSubject forKey:@"subject"];
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook];
    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed)
    {
        if (activityType != nil)
        {
            NSDictionary *params = @{ VTrackingKeySequenceCategory : sequence.category, VTrackingKeyActivityType : activityType };
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidShare parameters:params];
        }
        
        [[VThemeManager sharedThemeManager] applyStyling];
        [viewController reloadInputViews];
    };
    
    [viewController presentViewController:activityViewController
                                 animated:YES
                               completion:nil];
}

#pragma mark - Flag

- (void)flagSheetFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                                       onCancelButton:nil
                                               destructiveButtonTitle:nil
                                                  onDestructiveButton:nil
                                           otherButtonTitlesAndBlocks:NSLocalizedString(@"Report/Flag", nil),  ^(void)
                                  {
                                      [self flagActionForSequence:sequence];
                                  }, nil];
    [actionSheet showInView:viewController.view];
}

- (void)flagActionForSequence:(VSequence *)sequence
{
    [[VObjectManager sharedManager] flagSequence:sequence
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
         VLog(@"Failed to flag sequence %@", sequence);
         
         UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WereSorry", @"")
                                                                message:NSLocalizedString(@"ErrorOccured", @"")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                      otherButtonTitles:nil];
         [alert show];
     }];
}

#pragma mark - Helpers

//TODO: this is a duplicate of the action item class.  That class should eventually be refactored to utilize a VSequenceActionController, and should clean up the duplicate method.
- (NSString *)shareTextForSequence:(VSequence *)sequence
{
    NSString *shareText = @"";
    
    if ([sequence.user isOwner])
    {
        if ([sequence isPoll])
        {
            shareText = [NSString stringWithFormat:NSLocalizedString(@"OwnerSharePollFormat", nil), sequence.user.name];
        }
        else if ([sequence isVideo])
        {
            shareText = [NSString stringWithFormat:NSLocalizedString(@"OwnerShareVideoFormat", nil), sequence.name, sequence.user.name];
        }
        else
        {
            shareText = [NSString stringWithFormat:NSLocalizedString(@"OwnerShareImageFormat", nil), sequence.user.name];
        }
    }
    else
    {
        if ([sequence isPoll])
        {
            shareText = [NSString stringWithFormat:NSLocalizedString(@"UGCSharePollFormat", nil), sequence.user.name];
        }
        else if ([sequence isVideo])
        {
            shareText = [NSString stringWithFormat:NSLocalizedString(@"UGCShareVideoFormat", nil), sequence.name, sequence.user.name];
        }
        else
        {
            shareText = [NSString stringWithFormat:NSLocalizedString(@"UGCShareImageFormat", nil), sequence.user.name];
        }
    }
    
    return shareText;
}

@end
