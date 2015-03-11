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

- (void)showRemixOnViewController:(UIViewController *)viewController
                     withSequence:(VSequence *)sequence
                   preloadedImage:(UIImage *)preloadedImage
                       completion:(void(^)(BOOL))completion
{
    NSAssert( ![sequence isPoll], @"You cannot remix polls." );
    
    VAuthorizedAction *authorization = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                dependencyManager:self.dependencyManager];
    [authorization performFromViewController:viewController withContext:VAuthorizationContextRemix withSuccess:^
     {
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
         [addedDependencies setObject:@(VVideoToolControllerInitialVideoEditStateGIF) forKey:VVideoToolControllerInitalVideoEditStateKey];
         
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
                       completion:(void(^)(BOOL))completion
{
    [self showRemixOnViewController:viewController withSequence:sequence preloadedImage:nil completion:nil];
}

- (void)showRemixOnViewController:(UIViewController *)viewController
                     withSequence:(VSequence *)sequence
{
    [self showRemixOnViewController:viewController withSequence:sequence completion:nil];
}

- (void)showRemixStreamFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence
{
    VStream *stream = [VStream remixStreamForSequence:sequence];
    stream.name = NSLocalizedString(@"Remixes", nil);
    VStreamCollectionViewController  *streamCollection = [VStreamCollectionViewController streamViewControllerForStream:stream];
    streamCollection.dependencyManager = self.dependencyManager;
    
    VNoContentView *noRemixView = [VNoContentView noContentViewWithFrame:streamCollection.view.bounds];
    noRemixView.titleLabel.text = NSLocalizedString(@"NoRemixersTitle", @"");
    noRemixView.messageLabel.text = NSLocalizedString(@"NoRemixersMessage", @"");
    noRemixView.iconImageView.image = [UIImage imageNamed:@"noRemixIcon"];
    streamCollection.noContentView = noRemixView;
    
    [viewController.navigationController pushViewController:streamCollection animated:YES];
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
    [authorization performFromViewController:viewController withContext:VAuthorizationContextRepost withSuccess:^
     {
         [[VObjectManager sharedManager] repostNode:node
                                           withName:nil
                                       successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
          {
              node.sequence.repostCount = @( node.sequence.repostCount.integerValue + 1 );
              
              [self updateRespostsForUser:[VObjectManager sharedManager].mainUser withSequence:node.sequence];
              
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
    
    VFacebookActivity *fbActivity = [[VFacebookActivity alloc] init];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[sequence ?: [NSNull null],
                                                                                                                 [self shareTextForSequence:sequence],
                                                                                                                 [NSURL URLWithString:node.shareUrlPath] ?: [NSNull null]]
                                                                                         applicationActivities:@[fbActivity]];
    
    NSString *emailSubject = [NSString stringWithFormat:NSLocalizedString(@"EmailShareSubjectFormat", nil), [[VThemeManager sharedThemeManager] themedStringForKey:kVCreatorName]];
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
