//
//  VNewContentViewController+Actions.m
//  victorious
//
//  Created by Michael Sena on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNewContentViewController+Actions.h"

// Theme
#import "VThemeManager.h"

// View Categories
#import "UIActionSheet+VBlocks.h"
#import "UIActionSheet+VBlocks.h"

//TODO: abstract this out of VC
#import "VStream.h"
#import "VStream+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VObjectManager+Sequence.h"
#import "VSequence+Fetcher.h"
#import "VUser+Fetcher.h"

// Activities
#import "VFacebookActivity.h"

// ViewControllers
#import "VActionSheetViewController.h"
#import "VActionSheetTransitioningDelegate.h"
#import "VCameraPublishViewController.h"
#import "VRemixSelectViewController.h"
#import "VUserProfileViewController.h"
#import "VStreamContainerViewController.h"
#import "VReposterTableViewController.h"
#import "VLoginViewController.h"

// Analytics
#import "VAnalyticsRecorder.h"


@implementation VNewContentViewController (Actions)

- (IBAction)pressedMore:(id)sender
{
    NSMutableArray *actionItems = [[NSMutableArray alloc] init];
    
    VActionSheetViewController *actionSheetViewController = [VActionSheetViewController actionSheetViewController];
    VNewContentViewController *contentViewController = self;
    
    [VActionSheetTransitioningDelegate addNewTransitioningDelegateToActionSheetController:actionSheetViewController];
    
    VActionItem *userItem = [VActionItem userActionItemUserWithTitle:self.viewModel.authorName
                                                           avatarURL:self.viewModel.avatarForAuthor
                                                          detailText:self.viewModel.authorCaption];
    userItem.selectionHandler = ^(void)
    {
        [contentViewController dismissViewControllerAnimated:YES completion:^
         {
             VUserProfileViewController *profileViewController = [VUserProfileViewController userProfileWithUser:self.viewModel.user];
             [contentViewController.navigationController pushViewController:profileViewController animated:YES];
         }];
    };
    [actionItems addObject:userItem];
    
    VActionItem *descripTionItem = [VActionItem descriptionActionItemWithText:self.viewModel.name
                                                      hashTagSelectionHandler:^(NSString *hashTag)
                                    {
                                        VStreamContainerViewController *container = [VStreamContainerViewController modalContainerForStreamTable:[VStreamTableViewController hashtagStreamWithHashtag:hashTag]];
                                        container.shouldShowHeaderLogo = NO;
                                        
                                        [contentViewController dismissViewControllerAnimated:YES
                                                                 completion:^
                                         {
                                             [contentViewController.navigationController pushViewController:container
                                                                                  animated:YES];
                                         }];
                                    }];

    [actionItems addObject:descripTionItem];
    
    if ([self.viewModel.sequence canRemix])
    {
        VActionItem *remixItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"Remix", @"")
                                                              actionIcon:[UIImage imageNamed:@"icon_remix"]
                                                              detailText:self.viewModel.remixCountText];
        remixItem.selectionHandler = ^(void)
        {
            if (![VObjectManager sharedManager].mainUser)
            {
                [contentViewController dismissViewControllerAnimated:YES
                                         completion:^
                 {
                     [contentViewController presentViewController:[VLoginViewController loginViewController]
                                        animated:YES
                                      completion:NULL];
                 }];
                
                return;
            }
            
            [contentViewController dismissViewControllerAnimated:YES
                                     completion:^
             {
                 NSString *label = [contentViewController.viewModel.sequence.remoteId stringByAppendingPathComponent:contentViewController.viewModel.sequence.name];
                 [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryNavigation action:@"Pressed Remix" label:label value:nil];
                 
                 if (contentViewController.viewModel.type == VContentViewTypeVideo)
                 {
                     UIViewController *remixVC = [VRemixSelectViewController remixViewControllerWithURL:contentViewController.viewModel.sourceURLForCurrentAssetData
                                                                                             sequenceID:[contentViewController.viewModel.sequence.remoteId integerValue]
                                                                                                 nodeID:contentViewController.viewModel.nodeID];
                     [self presentViewController:remixVC animated:YES completion:nil];
                 }
                 else
                 {
                     UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                              delegate:self
                                                                     cancelButtonTitle:NSLocalizedString(@"CancelButton", @"Cancel button")
                                                                destructiveButtonTitle:nil
                                                                     otherButtonTitles:NSLocalizedString(@"Meme", nil), NSLocalizedString(@"Quote", nil), nil];
                     [actionSheet showInView:contentViewController.view];
                 }
             }];
        };
        remixItem.detailSelectionHandler = ^(void)
        {
            [contentViewController dismissViewControllerAnimated:YES
                                     completion:^
             {
                 VStream *stream = [VStream remixStreamForSequence:self.viewModel.sequence];
                 VStreamTableViewController  *streamTableView = [VStreamTableViewController streamWithDefaultStream:stream name:@"remix" title:NSLocalizedString(@"Remixes", nil)];
                 streamTableView.noContentTitle = NSLocalizedString(@"NoRemixersTitle", @"");
                 streamTableView.noContentMessage = NSLocalizedString(@"NoRemixersMessage", @"");
                 streamTableView.noContentImage = [UIImage imageNamed:@"noRemixIcon"];
                 [contentViewController.navigationController pushViewController:[VStreamContainerViewController modalContainerForStreamTable:streamTableView] animated:YES];
                 
             }];
        };
        [actionItems addObject:remixItem];
    }
    
    
    BOOL repostEnabled = (self.viewModel.hasReposted ? NO : YES) && ![self.viewModel.sequence isPoll];
    NSString *localizedRepostRepostedText = self.viewModel.hasReposted ? NSLocalizedString(@"Reposted", @"") : NSLocalizedString(@"Repost", @"");
    VActionItem *repostItem = [VActionItem defaultActionItemWithTitle:localizedRepostRepostedText
                                                           actionIcon:[UIImage imageNamed:@"icon_repost"]
                                                           detailText:self.viewModel.repostCountText
                                                              enabled:repostEnabled];
    repostItem.selectionHandler = ^(void)
    {
        [contentViewController dismissViewControllerAnimated:YES
                                                  completion:^
         {
             if (![VObjectManager sharedManager].mainUser)
             {
                 [contentViewController presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
                 return;
             }
             if (contentViewController.viewModel.hasReposted)
             {
                 return;
             }
             
             [contentViewController.viewModel repost];
         }];
    };
    repostItem.detailSelectionHandler = ^(void)
    {
        [self dismissViewControllerAnimated:YES
                                 completion:^
         {
             VReposterTableViewController *vc = [[VReposterTableViewController alloc] init];
             vc.sequence = self.viewModel.sequence;
             [self.navigationController pushViewController:vc animated:YES];
         }];
    };
    [actionItems addObject:repostItem];
    
    VActionItem *shareItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"Share", @"")
                                                          actionIcon:[UIImage imageNamed:@"icon_share"]
                                                          detailText:self.viewModel.shareCountText];
    
    void (^shareHandler)(void) = ^void(void)
    {
        //Remove the styling for the mail view.
        [[VThemeManager sharedThemeManager] removeStyling];
        
        VFacebookActivity *fbActivity = [[VFacebookActivity alloc] init];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.viewModel.sequence,
                                                                                                                     self.viewModel.shareText,
                                                                                                                     self.viewModel.shareURL]
                                                                                             applicationActivities:@[fbActivity]];
        
        NSString *emailSubject = [NSString stringWithFormat:NSLocalizedString(@"EmailShareSubjectFormat", nil), [[VThemeManager sharedThemeManager] themedStringForKey:kVChannelName]];
        [activityViewController setValue:emailSubject forKey:@"subject"];
        activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook];
        activityViewController.completionHandler = ^(NSString *activityType, BOOL completed)
        {
            [[VThemeManager sharedThemeManager] applyStyling];
            [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:[NSString stringWithFormat:@"Shared %@, via %@", self.viewModel.analyticsContentTypeText, activityType]
                                                                         action:nil
                                                                          label:nil
                                                                          value:nil];
            [self reloadInputViews];
        };
        
        [contentViewController dismissViewControllerAnimated:YES
                                 completion:^
         {
             [contentViewController presentViewController:activityViewController
                                animated:YES
                              completion:nil];
         }];
    };
    shareItem.selectionHandler = shareHandler;
    shareItem.detailSelectionHandler = shareHandler;
    [actionItems addObject:shareItem];
    
    if ([self.viewModel.sequence canDelete])
    {
        VActionItem *deleteItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"Delete", @"")
                                                               actionIcon:[UIImage imageNamed:@"delete-icon"]
                                                               detailText:nil];
        
        deleteItem.selectionHandler = ^(void)
        {
            [self dismissViewControllerAnimated:YES
                                     completion:^
             {
                 UIActionSheet *confirmDeleteActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"AreYouSureYouWantToDelete", @"")
                                                                              cancelButtonTitle:NSLocalizedString(@"CancelButton", @"")
                                                                                 onCancelButton:nil
                                                                         destructiveButtonTitle:NSLocalizedString(@"DeleteButton", @"")
                                                                            onDestructiveButton:^
                                                            {
                                                                [[VObjectManager sharedManager] removeSequenceWithSequenceID:[self.viewModel.sequence.remoteId integerValue]
                                                                                                                successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
                                                                 {
                                                                     [self.delegate newContentViewControllerDidDeleteContent:self];
                                                                 }
                                                                                                                   failBlock:^(NSOperation *operation, NSError *error)
                                                                 {
                                                                     [self.delegate newContentViewControllerDidDeleteContent:self];
                                                                 }];
                                                            }
                                                                     otherButtonTitlesAndBlocks:nil, nil];
                 [confirmDeleteActionSheet showInView:self.view];
             }];
        };
        [actionItems addObject:deleteItem];
    }
    
    if (![[[VObjectManager sharedManager] mainUser] isOwner])
    {
        VActionItem *flagItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"Report/Flag", @"")
                                                             actionIcon:[UIImage imageNamed:@"icon_flag"]
                                                             detailText:nil];
        flagItem.selectionHandler = ^(void)
        {
            [[VObjectManager sharedManager] flagSequence:self.viewModel.sequence
                                            successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
             {
                 [contentViewController dismissViewControllerAnimated:YES
                                          completion:^
                  {
                      UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ReportedTitle", @"")
                                                                             message:NSLocalizedString(@"ReportContentMessage", @"")
                                                                            delegate:nil
                                                                   cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                                   otherButtonTitles:nil];
                      [alert show];
                  }];
             }
                                               failBlock:^(NSOperation *operation, NSError *error)
             {
                 [contentViewController dismissViewControllerAnimated:YES
                                          completion:^
                  {
                      UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WereSorry", @"")
                                                                             message:NSLocalizedString(@"ErrorOccured", @"")
                                                                            delegate:nil
                                                                   cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                                   otherButtonTitles:nil];
                      [alert show];
                      
                  }];
             }];
        };
        [actionItems addObject:flagItem];
    }
    
    [actionSheetViewController addActionItems:actionItems];
    
    [self presentViewController:actionSheetViewController animated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex != 0 && buttonIndex != 1 )
    {
        return;
    }
    
    NSData *filteredImageData = UIImageJPEGRepresentation(self.placeholderImage, VConstantJPEGCompressionQuality);
    NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionJPG];
    
    if ([filteredImageData writeToURL:tempFile atomically:NO])
    {
        VCameraPublishViewController *publishViewController = [VCameraPublishViewController cameraPublishViewController];
        publishViewController.previewImage = self.placeholderImage;
        publishViewController.parentID = [self.viewModel.sequence.remoteId integerValue];
        publishViewController.completion = nil;
        publishViewController.captionType = buttonIndex == 0 ? VCaptionTypeMeme : VCaptionTypeQuote;
        publishViewController.mediaURL = tempFile;
        
        UINavigationController *remixNav = [[UINavigationController alloc] initWithRootViewController:publishViewController];
        [self presentViewController:remixNav animated:YES completion:nil];
    }
}

@end
