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
#import "VNode.h"
#import "VObjectManager+Sequence.h"
#import "VSequence+Fetcher.h"
#import "VUser+Fetcher.h"

// Activities
#import "VFacebookActivity.h"

//Views
#import "VNoContentView.h"

// ViewControllers
#import "VActionSheetViewController.h"
#import "VActionSheetTransitioningDelegate.h"
#import "VCameraPublishViewController.h"
#import "VRemixSelectViewController.h"
#import "VUserProfileViewController.h"
#import "VReposterTableViewController.h"
#import "VLoginViewController.h"
#import "VStreamCollectionViewController.h"

#import "VSequenceActionController.h"


@implementation VNewContentViewController (Actions)

- (IBAction)pressedMore:(id)sender
{
    static VSequenceActionController *sequenceActionController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sequenceActionController = [[VSequenceActionController alloc] init];
    });
    
    
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
             [sequenceActionController showPosterProfileFromViewController:contentViewController sequence:self.viewModel.sequence];
         }];
    };
    [actionItems addObject:userItem];
    
    VActionItem *descripTionItem = [VActionItem descriptionActionItemWithText:self.viewModel.name
                                                      hashTagSelectionHandler:^(NSString *hashTag)
                                    {
                                        VStreamCollectionViewController *stream = [VStreamCollectionViewController hashtagStreamWithHashtag:hashTag];
                                        
                                        [contentViewController dismissViewControllerAnimated:YES
                                                                 completion:^
                                         {
                                             [contentViewController.navigationController pushViewController:stream
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
            
            [contentViewController dismissViewControllerAnimated:YES
                                                      completion:^
             {
                 VSequence *sequence = self.viewModel.sequence;
                 if ([sequence isVideo])
                 {
                     [sequenceActionController videoRemixActionFromViewController:contentViewController
                                                                            asset:[self.viewModel.sequence firstNode].assets.firstObject
                                                                             node:[sequence firstNode]
                                                                         sequence:sequence];
                 }
                 else
                 {
                     [sequenceActionController imageRemixActionFromViewController:self previewImage:self.placeholderImage sequence: sequence];
                 }
             }];
        };
        remixItem.detailSelectionHandler = ^(void)
        {
            [contentViewController dismissViewControllerAnimated:YES
                                     completion:^
             {
                 [sequenceActionController showRemixStreamFromViewController:contentViewController sequence:self.viewModel.sequence];
             }];
        };
        [actionItems addObject:remixItem];
    }
    
    NSString *localizedRepostRepostedText = self.viewModel.hasReposted ? NSLocalizedString(@"Reposted", @"") : NSLocalizedString(@"Repost", @"");
    VActionItem *repostItem = [VActionItem defaultActionItemWithTitle:localizedRepostRepostedText
                                                           actionIcon:[UIImage imageNamed:@"icon_repost"]
                                                           detailText:self.viewModel.repostCountText
                                                              enabled:self.viewModel.hasReposted ? NO : YES];
    repostItem.selectionHandler = ^(void)
    {
        [contentViewController dismissViewControllerAnimated:YES
                                 completion:^
         {
             if (contentViewController.viewModel.hasReposted)
             {
                 return;
             }
             [sequenceActionController repostActionFromViewController:contentViewController node:contentViewController.viewModel.currentNode];
         }];
    };
    repostItem.detailSelectionHandler = ^(void)
    {
        [self dismissViewControllerAnimated:YES
                                 completion:^
         {
             [sequenceActionController showRepostersFromViewController:contentViewController sequence:self.viewModel.sequence];
         }];
    };
    [actionItems addObject:repostItem];
    
    VActionItem *shareItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"Share", @"")
                                                          actionIcon:[UIImage imageNamed:@"icon_share"]
                                                          detailText:self.viewModel.shareCountText];
    
    void (^shareHandler)(void) = ^void(void)
    {
        [contentViewController dismissViewControllerAnimated:YES
                                 completion:^
         {
             [sequenceActionController shareFromViewController:contentViewController
                                                      sequence:contentViewController.viewModel.sequence
                                                          node:contentViewController.viewModel.currentNode];
         }];
    };
    shareItem.selectionHandler = shareHandler;
    shareItem.detailSelectionHandler = shareHandler;
    [actionItems addObject:shareItem];
    
    if ([self.viewModel.sequence canDelete])
    {
        VActionItem *deleteItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"Delete", @"")
                                                               actionIcon:nil
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
            
            [contentViewController dismissViewControllerAnimated:YES
                                                      completion:^
             {
                 [sequenceActionController flagSheetFromViewController:contentViewController sequence:self.viewModel.sequence];
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
        publishViewController.parentSequenceID = [self.viewModel.sequence.remoteId integerValue];
        publishViewController.parentNodeID = [self.viewModel.sequence.firstNode.remoteId integerValue];
        publishViewController.completion = nil;
        publishViewController.captionType = buttonIndex == 0 ? VCaptionTypeMeme : VCaptionTypeQuote;
        publishViewController.mediaURL = tempFile;
        
        UINavigationController *remixNav = [[UINavigationController alloc] initWithRootViewController:publishViewController];
        [self presentViewController:remixNav animated:YES completion:nil];
    }
}

@end
