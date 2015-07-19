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
#import "VTracking.h"

#pragma mark - Controllers
#import "VStreamCollectionViewController.h"
#import "VReposterTableViewController.h"
#import "VUserProfileViewController.h"
#import "VCommentsContainerViewController.h"
#import "VWorkspaceViewController.h"
#import "VMediaLinkViewController.h"

#pragma mark-  Views
#import "VNoContentView.h"
#import "VFacebookActivity.h"

#pragma mark - Managers
#import "VObjectManager+Login.h"
#import "VObjectManager+ContentCreation.h"
#import "VObjectManager+Sequence.h"

#pragma mark - Categories
#import "NSString+VParseHelp.h"
#import "UIActionSheet+VBlocks.h"

#pragma mark - Dependency Manager
#import "VCoachmarkManager.h"
#import "VDependencyManager+VCoachmarkManager.h"

#pragma mark - Workflow
#import "VWorkspaceFlowController.h"
#import "VImageToolController.h"
#import "VVideoToolController.h"
#import "VAuthorizedAction.h"

#import "VAppInfo.h"
#import "VDependencyManager+VUserProfile.h"
#import "VUsersViewController.h"
#import "VLikersDataSource.h"

@interface VSequenceActionController () <VWorkspaceFlowControllerDelegate>

@property (nonatomic, strong) UIViewController *viewControllerPresentingWorkspace;

@end

@implementation VSequenceActionController

#pragma mark - Comments

- (void)showCommentsFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence withSelectedComment:(VComment *)selectedComment
{
    VCommentsContainerViewController *commentsContainerViewController;
    if ( selectedComment != nil )
    {
        commentsContainerViewController = [self.dependencyManager commentsContainerWithSequence:sequence andSelectedComment:selectedComment];
    }
    else
    {
        commentsContainerViewController = [self.dependencyManager commentsContainerWithSequence:sequence];
    }
    [viewController.navigationController pushViewController:commentsContainerViewController animated:YES];
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

- (BOOL)showProfileWithRemoteId:(NSNumber *)remoteId fromViewController:(UIViewController *)viewController
{
    if ( viewController == nil || viewController.navigationController == nil || remoteId == nil )
    {
        return NO;
    }
    
    if ( [viewController isKindOfClass:[VUserProfileViewController class]] &&
        [((VUserProfileViewController *)viewController).user.remoteId isEqual:remoteId] )
    {
        return NO;
    }
    
    VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithRemoteId:remoteId];
    [viewController.navigationController pushViewController:profileViewController animated:YES];
    
    return YES;
}

- (BOOL)showProfile:(VUser *)user fromViewController:(UIViewController *)viewController
{
    if ( viewController == nil || viewController.navigationController == nil || user == nil )
    {
        return NO;
    }
    
    if ( [viewController isKindOfClass:[VUserProfileViewController class]] &&
        [((VUserProfileViewController *)viewController).user isEqual:user] )
    {
        return NO;
    }
    
    VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithUser:user];
    [viewController.navigationController pushViewController:profileViewController animated:YES];
    
    return YES;
}

- (BOOL)showMediaContentViewForUrlString:(NSString *)urlString withMediaLinkType:(VInStreamMediaLinkType)linkType fromViewController:(UIViewController *)viewController
{
    VMediaLinkViewController *mediaLinkViewController = [VMediaLinkViewController newWithMediaUrlString:urlString andMediaLinkType:linkType];
    [viewController presentViewController:mediaLinkViewController animated:YES completion:nil];
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

- (void)showGiffersOnNavigationController:(UINavigationController *)navigationController
                                 sequence:(VSequence *)sequence
                     andDependencyManager:(VDependencyManager *)dependencyManager
{
    NSParameterAssert(sequence != nil);
    VStreamCollectionViewController *gifStream = [dependencyManager gifStreamForSequence:sequence];
    [navigationController pushViewController:gifStream animated:YES];
}

- (void)showMemersOnNavigationController:(UINavigationController *)navigationController
                                sequence:(VSequence *)sequence
                    andDependencyManager:(VDependencyManager *)dependencyManager
{
    NSParameterAssert(sequence != nil);
    VStreamCollectionViewController *memeStream = [dependencyManager memeStreamForSequence:sequence];
    [navigationController pushViewController:memeStream animated:YES];
}

- (void)likeSequence:(VSequence *)sequence fromViewController:(UIViewController *)viewController
      withActionView:(UIView *)actionView
          completion:(void(^)(BOOL success))completion
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectLike];
    
    VAuthorizedAction *authorization = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                      dependencyManager:self.dependencyManager];
    
    __weak typeof(self) welf = self;
    [authorization performFromViewController:viewController context:VAuthorizationContextDefault
                                  completion:^(BOOL authorized)
     {
         __strong typeof(self) strongSelf = welf;
         if ( authorized )
         {
             CGRect likeButtonFrame = [actionView convertRect:actionView.bounds toView:viewController.view];
             [[strongSelf.dependencyManager coachmarkManager] triggerSpecificCoachmarkWithIdentifier:VLikeButtonCoachmarkIdentifier inViewController:viewController atLocation:likeButtonFrame];
             
             [[VObjectManager sharedManager] toggleLikeWithSequence:sequence
                                                       successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
              {
                  completion( YES );
                  
              } failBlock:^(NSOperation *operation, NSError *error)
              {
                  completion( NO );
              }];
         }
         else
         {
             completion( NO );
         }
     }];
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

- (void)showLikersFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence
{
    VUsersViewController *usersViewController = [[VUsersViewController alloc] initWithDependencyManager:self.dependencyManager];
    usersViewController.title = NSLocalizedString( @"LikersTitle", nil );
    usersViewController.usersDataSource = [[VLikersDataSource alloc] initWithSequence:sequence];
    
    [viewController.navigationController pushViewController:usersViewController animated:YES];
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
                                      [self flagActionForSequence:sequence fromViewController:viewController];
                                  }, nil];
    [actionSheet showInView:viewController.view];
}

- (void)flagActionForSequence:(VSequence *)sequence fromViewController:(UIViewController *)viewController
{
    [[VObjectManager sharedManager] flagSequence:sequence
                                    successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         UIAlertController *alert = [self standardAlertControllerWithTitle:NSLocalizedString(@"ReportedTitle", @"") message:NSLocalizedString(@"ReportContentMessage", @"")];
         
         [viewController presentViewController:alert animated:YES completion:nil];
     }
                                       failBlock:^(NSOperation *operation, NSError *error)
     {
         VLog(@"Failed to flag sequence %@", sequence);
         UIAlertController *alert;
         if ( error.code == kVCommentAlreadyFlaggedError )
         {
             alert = [self standardAlertControllerWithTitle:NSLocalizedString(@"ReportedTitle", @"") message:NSLocalizedString(@"ReportContentMessage", @"")];
         }
         else
         {
             alert = [self standardAlertControllerWithTitle:NSLocalizedString(@"WereSorry", @"") message:NSLocalizedString(@"ErrorOccured", @"")];
         }
         [viewController presentViewController:alert animated:YES completion:nil];
     }];
}

- (UIAlertController *)standardAlertControllerWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:nil];
    [alert addAction:okAction];
    return alert;
}

#pragma mark - Helpers

//TODO: this is a duplicate of the action item class.  That class should eventually be refactored to utilize a VSequenceActionController, and should clean up the duplicate method.
- (NSString *)shareTextForSequence:(VSequence *)sequence
{
    NSString *shareText = @"";

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
    else if ([sequence isImage])
    {
        shareText = [NSString stringWithFormat:NSLocalizedString(@"UGCShareImageFormat", nil), sequence.user.name];
    }
    else if ([sequence isText])
    {
        shareText = [NSString stringWithFormat:NSLocalizedString(@"UGCShareTextFormat", nil), sequence.user.name];
    }
    else
    {
        shareText = [NSString stringWithFormat:NSLocalizedString(@"UGCShareLinkFormat", nil), sequence.user.name];
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
