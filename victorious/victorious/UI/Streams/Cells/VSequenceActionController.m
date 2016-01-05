//
//  VSequenceActionController.m
//  victorious
//
//  Created by Will Long on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <objc/runtime.h>

#import "VSequenceActionController.h"
#import "VAsset+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VStream+Fetcher.h"
#import "VTracking.h"
#import "VStreamCollectionViewController.h"
#import "VReposterTableViewController.h"
#import "VUserProfileViewController.h"
#import "VWorkspaceViewController.h"
#import "VAbstractMediaLinkViewController.h"
#import "VTabScaffoldViewController.h"
#import "VNoContentView.h"
#import "VFacebookActivity.h"
#import "NSString+VParseHelp.h"
#import "VCoachmarkManager.h"
#import "VDependencyManager+VCoachmarkManager.h"
#import "VDependencyManager+VLoginAndRegistration.h"
#import "VRemixPresenter.h"
#import "VImageToolController.h"
#import "VVideoToolController.h"
#import "VAppInfo.h"
#import "VDependencyManager+VUserProfile.h"
#import "VUsersViewController.h"
#import "VLikersDataSource.h"
#import "victorious-Swift.h"

@interface VSequenceActionController ()

@property (nonatomic, strong) UIViewController *viewControllerPresentingWorkspace;
@property (nonatomic, strong) VRemixPresenter *remixPresenter;
@property (nonatomic, strong) SequenceActionHelper *sequenceActionHelper;

@end

@implementation VSequenceActionController

#pragma mark - Comments

- (void)showCommentsFromViewController:(UIViewController *)viewController
                              sequence:(VSequence *)sequence
                   withSelectedComment:(VComment *)selectedComment
{
    CommentsViewController *commentsViewController = [self.dependencyManager commentsViewController:sequence];
    [viewController.navigationController pushViewController:commentsViewController animated:YES];
}

- (SequenceActionHelper *)sequenceActionHelper
{
    if ( _sequenceActionHelper == nil )
    {
        _sequenceActionHelper = [[SequenceActionHelper alloc] init];
    }
    return _sequenceActionHelper;
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

- (BOOL)showMediaContentViewForUrl:(NSURL *)url withMediaLinkType:(VCommentMediaType)linkType fromViewController:(UIViewController *)viewController
{
    VAbstractMediaLinkViewController *mediaLinkViewController = [VAbstractMediaLinkViewController newWithMediaUrl:url andMediaLinkType:linkType];
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
    
    self.remixPresenter = [[VRemixPresenter alloc] initWithDependencymanager:self.dependencyManager
                                                             sequenceToRemix:sequence];
    [self.remixPresenter presentOnViewController:viewController];
    self.viewControllerPresentingWorkspace = viewController;
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
    [self.sequenceActionHelper likeSequence:sequence triggeringView:actionView originViewController:viewController dependencyManager:self.dependencyManager completion:completion];
}

#pragma mark - Repost

- (void)repostActionFromViewController:(UIViewController *)viewController node:(VNode *)node
{
    [self repostActionFromViewController:viewController node:node completion:nil];
}

- (void)repostActionFromViewController:(UIViewController *)viewController node:(VNode *)node completion:(void(^)(BOOL))completion
{
    [self.sequenceActionHelper repostNode:node completion:completion];
}

- (void)updateRepostsForUser:(VUser *)user withSequence:(VSequence *)sequence
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
    VDependencyManager *childDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:@{}];
    VUsersViewController *usersViewController = [[VUsersViewController alloc] initWithDependencyManager:childDependencyManager];
    usersViewController.title = NSLocalizedString( @"LikersTitle", nil );
    usersViewController.usersDataSource = [[VLikersDataSource alloc] initWithSequence:sequence];
    usersViewController.usersViewContext = VUsersViewContextLikers;
    
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
    fbActivity.shareMode = [self.dependencyManager shouldForceNativeFacebookLogin] ? FBSDKShareDialogModeNative : FBSDKShareDialogModeAutomatic;
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

- (void)flagSheetFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence completion:(void (^)(UIAlertAction *))completion
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectMoreActions parameters:nil];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Report/Flag", @"")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
                                {
                                    [self flagActionForSequence:sequence fromViewController:viewController completion:completion];
                                }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}

- (void)flagActionForSequence:(VSequence *)sequence fromViewController:(UIViewController *)viewController completion:(void (^)(UIAlertAction *))completion
{
    [self.sequenceActionHelper flagSequence:sequence fromViewController:viewController completion:nil];
}

- (UIAlertController *)standardAlertControllerWithTitle:(NSString *)title message:(NSString *)message
{
    return [self standardAlertControllerWithTitle:title message:message handler:nil];
}

- (UIAlertController *)standardAlertControllerWithTitle:(NSString *)title message:(NSString *)message handler:(void (^)(UIAlertAction *))handler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:handler];
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

@end
