//
//  VNewContentViewController+Actions.m
//  victorious
//
//  Created by Michael Sena on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNewContentViewController+Actions.h"
#import "UIActionSheet+VBlocks.h"
#import "UIActionSheet+VBlocks.h"
#import "VStream.h"
#import "VStream+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VNode.h"
#import "VSequence+Fetcher.h"
#import "VUser.h"
#import "VSequence+Fetcher.h"
#import "VNoContentView.h"
#import "VActionSheetViewController.h"
#import "VActionSheetTransitioningDelegate.h"
#import "VUserProfileViewController.h"
#import "VStreamCollectionViewController.h"
#import "VSequenceActionController.h"
#import "VHashtagStreamCollectionViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "VDownloadManager.h"
#import "VDownloadTaskInformation.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"
#import "VAsset+Fetcher.h"
#import "VAsset+VCachedData.h"
#import "VAsset+VAssetCache.h"
#import "victorious-Swift.h"

@interface VNewContentViewController ()

@property VSequenceActionController *sequenceActionController;

@end

@implementation VNewContentViewController (Actions)

- (IBAction)pressedMore:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectMoreActions parameters:nil];
    
    NSMutableArray *actionItems = [[NSMutableArray alloc] init];
    
    [self disableEndcardAutoplay];
    
    VActionSheetViewController *actionSheetViewController = [VActionSheetViewController actionSheetViewController];
    actionSheetViewController.dependencyManager = self.dependencyManager;
    VNewContentViewController *contentViewController = self;
    
    [VActionSheetTransitioningDelegate addNewTransitioningDelegateToActionSheetController:actionSheetViewController];
    
    VActionItem *userItem = [VActionItem userActionItemUserWithTitle:self.viewModel.authorName
                                                                user:self.viewModel.user
                                                          detailText:self.viewModel.authorCaption];
    userItem.selectionHandler = ^(VActionItem *item)
    {
        [contentViewController dismissViewControllerAnimated:YES completion:^
         {
             [self.sequenceActionController showPosterProfileFromViewController:contentViewController sequence:self.viewModel.sequence];
         }];
    };
    [actionItems addObject:userItem];
    
    VActionItem *descriptionItem = [VActionItem descriptionActionItemWithText:self.viewModel.name
                                                      hashTagSelectionHandler:^(NSString *hashTag)
                                    {
                                        VHashtagStreamCollectionViewController *vc = [self.dependencyManager hashtagStreamWithHashtag:hashTag];
                                        
                                        [contentViewController dismissViewControllerAnimated:YES completion:^
                                         {
                                             [contentViewController.navigationController pushViewController:vc animated:YES];
                                         }];
                                    }];

    [actionItems addObject:descriptionItem];
    
    [self addRemixToActionItems:actionItems contentViewController:contentViewController actionSheetViewController:actionSheetViewController];
    
#ifdef V_ALLOW_VIDEO_DOWNLOADS
    if (self.viewModel.type == VContentViewTypeVideo)
    {
        BOOL assetIsCached = [[self.viewModel.currentNode mp4Asset] assetDataIsCached];
        
        VActionItem *downloadItem = [VActionItem defaultActionItemWithTitle:assetIsCached ? @"Downloaded" : @"Download"
                                                                 actionIcon:nil
                                                                 detailText:nil
                                                                    enabled:!assetIsCached];
        downloadItem.selectionHandler = ^(VActionItem *item)
        {
            VDownloadManager *downloadManager = [[VDownloadManager alloc] init];
            VAsset *mp4Asset = [self.viewModel.sequence.firstNode mp4Asset];
            NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:mp4Asset.data]];
            urlRequest.HTTPMethod = RKStringFromRequestMethod(RKRequestMethodGET);
            VDownloadTaskInformation *downloadTask = [[VDownloadTaskInformation alloc] initWithRequest:urlRequest downloadLocation:[mp4Asset cacheURLForAsset]];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view
                                                      animated:YES];
            hud.mode = MBProgressHUDModeAnnularDeterminate;
            hud.labelText = @"Downloading...";
            [downloadManager enqueueDownloadTask:downloadTask
                                    withProgress:^(CGFloat progress)
             {
                 hud.progress = progress;
                 hud.labelText = [NSString stringWithFormat:@"Downloading... %.2f%%", progress*100];
                 VLog(@"progress: %@", @(progress));
             }
                                      onComplete:^(NSURL *downloadFileLocation, NSError *error)
             {
                 [hud hide:YES];
                 VLog(@"Video Downloaded! at location: %@, error: %@", downloadFileLocation, error);
                 [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
             }];
            VLog(@"download video");
            
            [self dismissViewControllerAnimated:YES
                                     completion:nil];
        };
        [actionItems addObject:downloadItem];
    }
#endif

    if (self.viewModel.sequence.permissions.canRepost)
    {
        NSString *localizedRepostRepostedText = [self.viewModel.sequence.hasReposted boolValue] ? NSLocalizedString(@"Reposted", @"") : NSLocalizedString(@"Repost", @"");
        VActionItem *repostItem = [VActionItem defaultActionItemWithTitle:localizedRepostRepostedText
                                                               actionIcon:[UIImage imageNamed:@"icon_repost"]
                                                               detailText:self.viewModel.repostCountText
                                                                  enabled:![self.viewModel.sequence.hasReposted boolValue]];
        repostItem.selectionHandler = ^(VActionItem *item)
        {
            if ( !contentViewController.viewModel.hasReposted)
            {
                [actionSheetViewController setLoading:YES forItem:item];
                
                [self.sequenceActionController repostActionFromViewController:contentViewController
                                                                         node:contentViewController.viewModel.currentNode
                                                                   completion:^(BOOL didSucceed)
                 {
                     if ( didSucceed )
                     {
                         contentViewController.viewModel.hasReposted = YES;
                     }
                     
                     [contentViewController dismissViewControllerAnimated:YES completion:nil];
                 }];
            }
        };
        repostItem.detailSelectionHandler = ^(VActionItem *item)
        {
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectShowReposters];
            
            [self dismissViewControllerAnimated:YES
                                     completion:^
             {
                 [self.sequenceActionController showRepostersFromViewController:contentViewController sequence:self.viewModel.sequence];
             }];
        };
        [actionItems addObject:repostItem];
    }
    
    VActionItem *shareItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"Share", @"")
                                                          actionIcon:[UIImage imageNamed:@"icon_share"]
                                                          detailText:self.viewModel.shareCountText];
    
    void (^shareHandler)(VActionItem *item) = ^void(VActionItem *item)
    {
        [contentViewController dismissViewControllerAnimated:YES
                                 completion:^
         {
             [self.sequenceActionController shareFromViewController:contentViewController
                                                      sequence:contentViewController.viewModel.sequence
                                                          node:contentViewController.viewModel.currentNode];
         }];
    };
    shareItem.selectionHandler = shareHandler;
    shareItem.detailSelectionHandler = shareHandler;
    [actionItems addObject:shareItem];
    
    if ( self.viewModel.sequence.permissions.canDelete )
    {
        VActionItem *deleteItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"Delete", @"")
                                                               actionIcon:[UIImage imageNamed:@"delete-icon"]
                                                               detailText:nil];
        
        deleteItem.selectionHandler = ^(VActionItem *item)
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
                                                                [self.presentingViewController dismissViewControllerAnimated:YES completion:^
                                                                 {
                                                                     [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidDeletePost];
                                                                     [self deleteSequence:self.viewModel.sequence completion:nil];
                                                                }];
                                                            }
                                                                     otherButtonTitlesAndBlocks:nil, nil];
                 [confirmDeleteActionSheet showInView:self.view];
             }];
        };
        [actionItems addObject:deleteItem];
    }
    
    BOOL canFlag = self.viewModel.sequence.permissions.canFlagSequence;
    
    if ( canFlag )
    {
        VActionItem *flagItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"Report/Flag", @"")
                                                             actionIcon:[UIImage imageNamed:@"icon_flag"]
                                                             detailText:nil];
        flagItem.selectionHandler = ^(VActionItem *item)
        {
            
            [contentViewController dismissViewControllerAnimated:YES
                                                      completion:^
             {
                 [self.sequenceActionController flagSheetFromViewController:contentViewController sequence:self.viewModel.sequence completion:^(UIAlertAction *action)
                 {
                     [self flagSequence:self.viewModel.sequence completion:^void(NSError *error)
                      {
                          [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                      }];
                 }];
             }];
        };
        [actionItems addObject:flagItem];
    }
    
    [actionSheetViewController addActionItems:actionItems];
    
    // Pause video when presenting action sheet
    if (self.viewModel.type == VContentViewTypeVideo)
    {
        [self.videoPlayer pause];
    }
    
    [self presentViewController:actionSheetViewController animated:YES completion:nil];
}

- (void)addRemixToActionItems:(NSMutableArray *)actionItems
        contentViewController:(UIViewController *)contentViewController
    actionSheetViewController:(VActionSheetViewController *)actionSheetViewController
{
    if ( self.viewModel.sequence.permissions.canGIF )
    {
        [actionItems addObject:[self gifItemForContentViewController:contentViewController
                                           actionSheetViewController:actionSheetViewController]];
    }
    if ( self.viewModel.sequence.permissions.canMeme )
    {
        [actionItems addObject:[self memeItemForContentViewController:contentViewController
                                            actionSheetViewController:actionSheetViewController]];
    }
}

- (VActionItem *)gifItemForContentViewController:(UIViewController *)contentViewController
                       actionSheetViewController:(VActionSheetViewController *)actionSheetViewController
{
    VActionItem *gifItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"Create a GIF", @"")
                                                        actionIcon:[UIImage imageNamed:@"D_gifIcon"]
                                                        detailText:self.viewModel.gifCountText];
    [self setupRemixActionItem:gifItem
     withContentViewController:contentViewController
     actionSheetViewController:actionSheetViewController
      withBlock:^
     {
         [self.sequenceActionController showRemixOnViewController:self
                                                     withSequence:self.viewModel.sequence
                                             andDependencyManager:self.dependencyManager
                                                   preloadedImage:nil
                                                 defaultVideoEdit:VDefaultVideoEditGIF
                                                       completion:nil];
         
     }
        dismissCompletionBlock:^
     {
         [self.sequenceActionController showGiffersOnNavigationController:contentViewController.navigationController
                                                                  sequence:self.viewModel.sequence
                                                      andDependencyManager:self.dependencyManager];
     }];
    return gifItem;
}

- (VActionItem *)memeItemForContentViewController:(UIViewController *)contentViewController
                        actionSheetViewController:(VActionSheetViewController *)actionSheetViewController
{
    VActionItem *memeItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"Create a meme", @"")
                                                         actionIcon:[UIImage imageNamed:@"D_memeIcon"]
                                                         detailText:self.viewModel.memeCountText];
    [self setupRemixActionItem:memeItem
     withContentViewController:contentViewController
     actionSheetViewController:actionSheetViewController
      withBlock:^
     {
         [self.sequenceActionController showRemixOnViewController:self
                                                     withSequence:self.viewModel.sequence
                                             andDependencyManager:self.dependencyManager
                                                   preloadedImage:nil
                                                 defaultVideoEdit:VDefaultVideoEditSnapshot
                                                       completion:nil];
         
     }
        dismissCompletionBlock:^
     {
         [self.sequenceActionController showMemersOnNavigationController:contentViewController.navigationController
                                                                  sequence:self.viewModel.sequence
                                                      andDependencyManager:self.dependencyManager];
     }];
    return memeItem;
}

- (void)setupRemixActionItem:(VActionItem *)remixItem
   withContentViewController:(UIViewController *)contentViewController
   actionSheetViewController:(VActionSheetViewController *)actionSheetViewController
                   withBlock:(void (^)(void))block
      dismissCompletionBlock:(void (^)(void))dismissCompletionBlock
{
    NSAssert(block != nil, @"block cannot be nil in setupRemixActionItem:withContentViewController:actionSheetViewController:withAutorizedActionBlock:dismissCompletionBlock: in VNewContentViewController+Actions");
    NSAssert(dismissCompletionBlock != nil, @"dismiss completion block cannot be nil in setupRemixActionItem:withContentViewController:actionSheetViewController:withAutorizedActionBlock:dismissCompletionBlock: in VNewContentViewController+Actions");
    
    remixItem.selectionHandler = ^(VActionItem *item)
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectRemix];
        
        [contentViewController dismissViewControllerAnimated:YES
                                                  completion:^
         {
             block();
         }];
    };
    remixItem.detailSelectionHandler = ^(VActionItem *item)
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectShowRemixes];
        
        [contentViewController dismissViewControllerAnimated:YES
                                                  completion:^
         {
             dismissCompletionBlock();
         }];
    };
}

@end
