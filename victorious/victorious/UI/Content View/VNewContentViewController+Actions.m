//
//  VNewContentViewController+Actions.m
//  victorious
//
//  Created by Michael Sena on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNewContentViewController+Actions.h"
#import "VStream.h"
#import "VStreamItem+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VNode.h"
#import "VUser.h"
#import "VNoContentView.h"
#import "VActionSheetViewController.h"
#import "VActionSheetTransitioningDelegate.h"
#import "VUserProfileViewController.h"
#import "VStreamCollectionViewController.h"
#import "VSequenceActionController.h"
#import "VHashtagStreamCollectionViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "VNode+Fetcher.h"
#import "VAsset.h"
#import "VAsset+Fetcher.h"
#import "victorious-Swift.h"

@implementation VNewContentViewController (Actions)

- (IBAction)pressedMore:(id)sender
{
    // Pause video when presenting action sheet
    if (self.viewModel.type == VContentViewTypeVideo)
    {
        [self.videoPlayer pause];
    }
    [self.sequenceActionController moreButtonActionWithSequence:self.viewModel.sequence
                                                       streamId:self.viewModel.streamId
                                                     completion:nil];
}

- (void)onSequenceDeleted
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^
     {
         DeleteSequenceOperation *deleteOperation = [[DeleteSequenceOperation alloc] initWithSequenceID:self.viewModel.sequence.remoteId];
         [deleteOperation queueOn:deleteOperation.defaultQueue completionBlock:^(NSArray *_Nullable results, NSError *_Nullable error)
          {
              [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidDeletePost];
              if ([self.delegate respondsToSelector:@selector(contentViewDidDeleteContent:)])
              {
                  [self.delegate contentViewDidDeleteContent:self];
              }
          }];
     }];
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
         [self.sequenceActionController showRemixWithSequence:self.viewModel.sequence
                                                   preloadedImage:nil
                                                 defaultVideoEdit:VDefaultVideoEditGIF
                                                       completion:nil];
         
     }
        dismissCompletionBlock:^
     {
         [self.sequenceActionController showGiffersOnNavigationController:contentViewController.navigationController
                                                                 sequence:self.viewModel.sequence];
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
         [self.sequenceActionController showRemixWithSequence:self.viewModel.sequence
                                               preloadedImage:nil
                                             defaultVideoEdit:VDefaultVideoEditSnapshot
                                                   completion:nil];
         
     }
        dismissCompletionBlock:^
     {
         [self.sequenceActionController showMemersOnNavigationController:contentViewController.navigationController
                                                                sequence:self.viewModel.sequence];
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
