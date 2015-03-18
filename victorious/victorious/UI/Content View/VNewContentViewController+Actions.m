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
#import "VUserProfileViewController.h"
#import "VLoginViewController.h"
#import "VStreamCollectionViewController.h"
#import "VSequenceActionController.h"
#import "VHashtagStreamCollectionViewController.h"
#import "VAuthorizedAction.h"

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
    VNewContentViewController *contentViewController = self;
    
    [VActionSheetTransitioningDelegate addNewTransitioningDelegateToActionSheetController:actionSheetViewController];
    
    VActionItem *userItem = [VActionItem userActionItemUserWithTitle:self.viewModel.authorName
                                                           avatarURL:self.viewModel.avatarForAuthor
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
                                        VHashtagStreamCollectionViewController *vc = [VHashtagStreamCollectionViewController instantiateWithHashtag:hashTag];
                                        
                                        [contentViewController dismissViewControllerAnimated:YES completion:^
                                         {
                                             [contentViewController.navigationController pushViewController:vc animated:YES];
                                         }];
                                    }];

    [actionItems addObject:descriptionItem];
    
    [self addRemixToActionItems:actionItems contentViewController:contentViewController actionSheetViewController:actionSheetViewController];
    
    if (self.viewModel.sequence.canRepost)
    {
        NSString *localizedRepostRepostedText = self.viewModel.hasReposted ? NSLocalizedString(@"Reposted", @"") : NSLocalizedString(@"Repost", @"");
        VActionItem *repostItem = [VActionItem defaultActionItemWithTitle:localizedRepostRepostedText
                                                               actionIcon:[UIImage imageNamed:@"icon_repost"]
                                                               detailText:self.viewModel.repostCountText
                                                                  enabled:!self.viewModel.hasReposted];
        repostItem.selectionHandler = ^(VActionItem *item)
        {
            VAuthorizedAction *authorizedAction = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                                 dependencyManager:self.dependencyManager];
            [authorizedAction performFromViewController:actionSheetViewController context:VAuthorizationContextRepost completion:^
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
             }];
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
    
    if ([self.viewModel.sequence canDelete])
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
                                                                [[VObjectManager sharedManager] removeSequence:self.viewModel.sequence
                                                                                                  successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
                                                                 {
                                                                     [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidDeletePost];
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
        flagItem.selectionHandler = ^(VActionItem *item)
        {
            
            [contentViewController dismissViewControllerAnimated:YES
                                                      completion:^
             {
                 [self.sequenceActionController flagSheetFromViewController:contentViewController sequence:self.viewModel.sequence];
             }];
        };
        [actionItems addObject:flagItem];
    }
    
    [actionSheetViewController addActionItems:actionItems];
    
    [self presentViewController:actionSheetViewController animated:YES completion:nil];
}

- (void)addRemixToActionItems:(NSMutableArray *)actionItems
        contentViewController:(UIViewController *)contentViewController
    actionSheetViewController:(VActionSheetViewController *)actionSheetViewController
{
    if ([self.viewModel.sequence canRemix])
    {
        NSString *remixActionTitle = NSLocalizedString(@"Remix", @"");
        if ([self.viewModel.sequence isVideo])
        {
            remixActionTitle = NSLocalizedString(@"GIF", @"");
        }
        VActionItem *remixItem = [VActionItem defaultActionItemWithTitle:remixActionTitle
                                                              actionIcon:[UIImage imageNamed:@"icon_remix"]
                                                              detailText:self.viewModel.remixCountText];
        remixItem.selectionHandler = ^(VActionItem *item)
        {
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectRemix];
            
            VAuthorizedAction *authorizedAction = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                                 dependencyManager:self.dependencyManager];
            [authorizedAction performFromViewController:actionSheetViewController context:VAuthorizationContextRemix completion:^
             {
                 [contentViewController dismissViewControllerAnimated:YES
                                                           completion:^
                  {
                      VSequence *sequence = self.viewModel.sequence;
                      if ([sequence isVideo])
                      {
                          [self.sequenceActionController showRemixOnViewController:self
                                                                      withSequence:sequence
                                                              andDependencyManager:self.dependencyManager
                                                                    preloadedImage:nil
                                                                  defaultVideoEdit:VDefaultVideoEditGIF
                                                                        completion:nil];
                      }
                      else
                      {
                          [self.sequenceActionController showRemixOnViewController:self
                                                                      withSequence:sequence
                                                              andDependencyManager:self.dependencyManager
                                                                    preloadedImage:nil
                                                                        completion:nil];
                      }
                  }];
             }];
        };
        remixItem.detailSelectionHandler = ^(VActionItem *item)
        {
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectShowRemixes];
            
            [contentViewController dismissViewControllerAnimated:YES
                                                      completion:^
             {
                 [self.sequenceActionController showRemixersOnnNavigationController:contentViewController.navigationController
                                                                           sequence:self.viewModel.sequence
                                                               andDependencyManager:self.dependencyManager];
             }];
        };
        [actionItems addObject:remixItem];
    }
}

@end
