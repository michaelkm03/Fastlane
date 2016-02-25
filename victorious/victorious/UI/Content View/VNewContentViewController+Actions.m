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

@end
