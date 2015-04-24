//
//  VSequenceActionController.m
//  victorious
//
//  Created by Will Long on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <objc/runtime.h>

#import "VSequenceActionController.h"

#pragma mark - Models
#import "VAsset+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VStream+Fetcher.h"
#import "VUser+Fetcher.h"
#import "VTracking.h"

#pragma mark - Controllers
#import "VStreamCollectionViewController.h"
#import "VReposterTableViewController.h"
#import "VUserProfileViewController.h"
#import "VCommentsContainerViewController.h"
#import "VWorkspaceViewController.h"

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

#pragma mark - Dependency Manager
#import "VDependencyManager.h"

#pragma mark - Workflow
#import "VWorkspaceFlowController.h"
#import "VImageToolController.h"
#import "VVideoToolController.h"
#import "VAuthorizedAction.h"

#import "VAppInfo.h"

@interface VSequenceActionController () <VWorkspaceFlowControllerDelegate>

@property (nonatomic, strong) UIViewController *viewControllerPresentingWorkspace;

@end

@implementation VSequenceActionController

#pragma mark - Comments

- (void)showCommentsFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence
{
    VCommentsContainerViewController *commentsTable = [VCommentsContainerViewController newWithDependencyManager:self.dependencyManager];
    commentsTable.sequence = sequence;
    [viewController.navigationController pushViewController:commentsTable animated:YES];
}

#pragma mark - User

- (BOOL)showPosterProfileFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence
{
    if ( sequence == nil )
    {
        return NO;
    }
    
    return [self showProfile:sequence.user fromViewController:viewController];
}

- (BOOL)showProfile:(VUser *)user fromViewController:(UIViewController *)viewController
{
    if ( !viewController || !viewController.navigationController || user == nil )
    {
        return NO;
    }
    
    if ( [viewController isKindOfClass:[VUserProfileViewController class]] &&
        [((VUserProfileViewController *)viewController).profile isEqual:user] )
    {
        return NO;
    }
    
    VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithUser:user];
    [viewController.navigationController pushViewController:profileViewController animated:YES];
    
    return YES;
}

#pragma mark - Remix

- (void)showRemixOnViewController:(UIViewController *)viewController
                     withSequence:(VSequence *)sequence
             andDependencyManager:(VDependencyManager *)dependencyManager
                   preloadedImage:(UIImage *)preloadedImage
                 defaultVideoEdit:(VDefaultVideoEdit)defaultVideoEdit
                       completion:(void(^)(BOOL))completion
{
    NSAssert( ![sequence isPoll], @"You cannot remix polls." );
    NSMutableDictionary *addedDependencies = [[NSMutableDictionary alloc] init];
    if (sequence)
    {
        [addedDependencies setObject:sequence forKey:VWorkspaceFlowControllerSequenceToRemixKey];
    }
    if (preloadedImage)
    {
        [addedDependencies setObject:preloadedImage forKey:VWorkspaceFlowControllerPreloadedImageKey];
    }
    [addedDependencies setObject:@(VImageToolControllerInitialImageEditStateText) forKey:VImageToolControllerInitialImageEditStateKey];
    VVideoToolControllerInitialVideoEditState editState;
    switch (defaultVideoEdit)
    {
        case VDefaultVideoEditVideo:
            editState = VVideoToolControllerInitialVideoEditStateVideo;
            break;
        case VDefaultVideoEditGIF:
            editState = VVideoToolControllerInitialVideoEditStateGIF;
            break;
        case VDefaultVideoEditSnapshot:
            editState = VVideoToolControllerInitialVideoEditStateMeme;
            break;
    }
    [addedDependencies setObject:@(editState) forKey:VVideoToolControllerInitalVideoEditStateKey];
    
    VAuthorizedAction *authorization = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                dependencyManager:self.dependencyManager];
    [authorization performFromViewController:viewController context:VAuthorizationContextRemix completion:^(BOOL authorized)
     {
         if (!authorized)
         {
             return;
         }
         
         VWorkspaceFlowController *workspaceFlowController = [self.dependencyManager templateValueOfType:[VWorkspaceFlowController class]
                                                                                                  forKey:VDependencyManagerWorkspaceFlowKey
                                                                                   withAddedDependencies:addedDependencies];
         
         workspaceFlowController.delegate = self;
         self.viewControllerPresentingWorkspace = viewController;
         [viewController presentViewController:workspaceFlowController.flowRootViewController
                                      animated:YES
                                    completion:nil];
     }];
}

- (void)showRemixOnViewController:(UIViewController *)viewController
                     withSequence:(VSequence *)sequence
             andDependencyManager:(VDependencyManager *)dependencyManager
                   preloadedImage:(UIImage *)preloadedImage
                       completion:(void (^)(BOOL))completion
{
    [self showRemixOnViewController:viewController
                       withSequence:sequence
               andDependencyManager:dependencyManager
                     preloadedImage:preloadedImage
                   defaultVideoEdit:VDefaultVideoEditGIF
                         completion:completion];
}

- (void)showRemixersOnNavigationController:(UINavigationController *)navigationController
                                   sequence:(VSequence *)sequence
                       andDependencyManager:(VDependencyManager *)dependencyManager
{
    NSParameterAssert(sequence != nil);
    VStreamCollectionViewController *remixStream = [dependencyManager remixStreamForSequence:sequence];
    [navigationController pushViewController:remixStream animated:YES];
}

#pragma mark - Repost

- (BOOL)canRespost
{
    if (![VObjectManager sharedManager].authorized)
    {
        return NO;
    }
    
    return YES;
}

- (void)repostActionFromViewController:(UIViewController *)viewController node:(VNode *)node
{
    [self repostActionFromViewController:viewController node:node completion:nil];
}

- (void)repostActionFromViewController:(UIViewController *)viewController node:(VNode *)node completion:(void(^)(BOOL))completion
{
    VAuthorizedAction *authorization = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                      dependencyManager:self.dependencyManager];
    [authorization performFromViewController:viewController context:VAuthorizationContextRepost completion:^(BOOL authorized)
     {
         if (!authorized)
         {
             completion(NO);
             return;
         }
         [[VObjectManager sharedManager] repostNode:node
                                           withName:nil
                                       successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
          {
              node.sequence.repostCount = @( node.sequence.repostCount.integerValue + 1 );
              
              [self updateRespostsForUser:[VObjectManager sharedManager].mainUser withSequence:node.sequence];
              
              node.sequence.hasReposted = @(YES);
              [node.sequence.managedObjectContext save:nil];
              
              if ( completion != nil )
              {
                  completion( YES );
              }
          }
                                          failBlock:^(NSOperation *operation, NSError *error)
          {
              if ( error.code == kVSequenceAlreadyReposted )
              {
                  [self updateRespostsForUser:[VObjectManager sharedManager].mainUser withSequence:node.sequence];
                  node.sequence.hasReposted = @(YES);
                  [node.sequence.managedObjectContext save:nil];
              }
              
              if ( completion != nil )
              {
                  completion( NO );
              }
          }];
     }];
}

- (void)updateRespostsForUser:(VUser *)user withSequence:(VSequence *)sequence
{
    NSError *error = nil;
    [user addRepostedSequencesObject:sequence];
    if ( ![user.managedObjectContext saveToPersistentStore:&error] )
    {
        VLog( @"Error marking sequence as reposted for main user: %@", error );
    }
}

- (void)showRepostersFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence
{
    VReposterTableViewController *vc = [[VReposterTableViewController alloc] initWithDependencyManager:self.dependencyManager];
    vc.sequence = sequence;
    [viewController.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Share

- (void)shareFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence node:(VNode *)node
{
    [self shareFromViewController:viewController sequence:sequence node:node completion:nil];
}

- (void)shareFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence node:(VNode *)node completion:(void(^)())completion
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectShare];
    
    VAppInfo *appInfo = [[VAppInfo alloc] initWithDependencyManager:self.dependencyManager];
    
    VFacebookActivity *fbActivity = [[VFacebookActivity alloc] init];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[sequence ?: [NSNull null],
                                                                                                                 [self shareTextForSequence:sequence],
                                                                                                                 [NSURL URLWithString:node.shareUrlPath] ?: [NSNull null]]
                                                                                         applicationActivities:@[fbActivity]];
    
    NSString *creatorName = appInfo.appName;
    NSString *emailSubject = [NSString stringWithFormat:NSLocalizedString(@"EmailShareSubjectFormat", nil), creatorName];
    [activityViewController setValue:emailSubject forKey:@"subject"];
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook];
    activityViewController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError)
    {
        if ( completed )
        {
            NSDictionary *params = @{ VTrackingKeySequenceCategory : sequence.category ?: @"",
                                      VTrackingKeyShareDestination : activityType ?: @"",
                                      VTrackingKeyUrls : sequence.tracking.share ?: @[] };
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidShare parameters:params];
        }
        else if ( activityError != nil )
        {
            NSDictionary *params = @{ VTrackingKeySequenceCategory : sequence.category ?: @"",
                                      VTrackingKeyShareDestination : activityType ?: @"",
                                      VTrackingKeyUrls : sequence.tracking.share ?: @[],
                                      VTrackingKeyErrorMessage : activityError == nil ? @"" : activityError.localizedDescription };
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserShareDidFail parameters:params];
        }
        
        [viewController reloadInputViews];
        
        if ( completion != nil )
        {
            completion();
        }
    };
    
    [viewController presentViewController:activityViewController
                                 animated:YES
                               completion:nil];
}

#pragma mark - Flag

- (void)flagSheetFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectMoreActions parameters:nil];
    
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
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                      otherButtonTitles:nil];
         [alert show];
         
     }
                                       failBlock:^(NSOperation *operation, NSError *error)
     {
         VLog(@"Failed to flag sequence %@", sequence);
         
         UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WereSorry", @"")
                                                                message:NSLocalizedString(@"ErrorOccured", @"")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
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
            if (sequence.name.length > 0)
            {
                shareText = [NSString stringWithFormat:NSLocalizedString(@"OwnerShareVideoFormat", nil), sequence.name, sequence.user.name];
            }
            else
            {
                shareText = [NSString stringWithFormat:NSLocalizedString(@"OwnerShareVideoFormatNoVideoName", nil), sequence.user.name];
            }
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
        else if ([sequence isGIFVideo])
        {
            shareText = [NSString stringWithFormat:NSLocalizedString(@"UGCShareGIFFormat", nil), sequence.name, sequence.user.name];
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

#pragma mark - VWorkspaceFlowControllerDelegate

- (void)workspaceFlowControllerDidCancel:(VWorkspaceFlowController *)workspaceFlowController
{
    [self.viewControllerPresentingWorkspace dismissViewControllerAnimated:YES
                                                               completion:^
     {
         self.viewControllerPresentingWorkspace = nil;
     }];
}

- (void)workspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController
       finishedWithPreviewImage:(UIImage *)previewImage
               capturedMediaURL:(NSURL *)capturedMediaURL
{
    [self.viewControllerPresentingWorkspace dismissViewControllerAnimated:YES
                                                               completion:^
     {
         self.viewControllerPresentingWorkspace = nil;
     }];
}

@end
