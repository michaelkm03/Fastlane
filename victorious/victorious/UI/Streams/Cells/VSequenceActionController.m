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
#import "VStreamItem+Fetcher.h"
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
#import "victorious-Swift.h"

@interface VSequenceActionController ()

@property (nonatomic, strong) VRemixPresenter *remixPresenter;
@property (nonatomic, weak, readwrite) UIViewController *originViewController;
@property (nonatomic, weak, readwrite) VDependencyManager *depencencyManager;

@end

@implementation VSequenceActionController

#pragma mark - Initializer

- (instancetype)initWithDepencencyManager:(VDependencyManager *)dependencyManager andOriginViewController:(UIViewController *)originViewController
{
    self = [super init];
    if (self)
    {
        _dependencyManager = dependencyManager;
        _originViewController = originViewController;
    }
    return self;
}

#pragma mark - Comments

- (void)showCommentsWithSequence:(VSequence *)sequence
             withSelectedComment:(VComment *)selectedComment
{
    CommentsViewController *commentsViewController = [self.dependencyManager commentsViewController:sequence];
    [self.originViewController.navigationController pushViewController:commentsViewController animated:YES];
}

#pragma mark - User

- (BOOL)showPosterProfileWithSequence:(VSequence *)sequence
{
    if ( sequence == nil )
    {
        return NO;
    }
    
    return [self showProfile:sequence.user];
}

- (BOOL)showProfileWithRemoteId:(NSNumber *)remoteId
{
    if ( self.originViewController == nil || self.originViewController.navigationController == nil || remoteId == nil )
    {
        return NO;
    }
    
    if ( [self.originViewController isKindOfClass:[VUserProfileViewController class]] &&
        [((VUserProfileViewController *)self.originViewController).user.remoteId isEqual:remoteId] )
    {
        return NO;
    }
    
    VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithRemoteId:remoteId];
    [self.originViewController.navigationController pushViewController:profileViewController animated:YES];
    
    return YES;
}

- (BOOL)showProfile:(VUser *)user
{
    if ( self.originViewController == nil || self.originViewController.navigationController == nil || user == nil )
    {
        return NO;
    }
    
    if ( [self.originViewController isKindOfClass:[VUserProfileViewController class]] &&
        [((VUserProfileViewController *)self.originViewController).user isEqual:user] )
    {
        return NO;
    }
    
    VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithUser:user];
    [self.originViewController.navigationController pushViewController:profileViewController animated:YES];
    
    return YES;
}

- (BOOL)showMediaContentViewForUrl:(NSURL *)url withMediaLinkType:(VCommentMediaType)linkType
{
    VAbstractMediaLinkViewController *mediaLinkViewController = [VAbstractMediaLinkViewController newWithMediaUrl:url andMediaLinkType:linkType];
    [self.originViewController presentViewController:mediaLinkViewController animated:YES completion:nil];
    return YES;
}

#pragma mark - Remix

- (void)showRemixWithSequence:(VSequence *)sequence
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
    [self.remixPresenter presentOnViewController:self.originViewController];
}

- (void)showRemixWithSequence:(VSequence *)sequence
                   preloadedImage:(UIImage *)preloadedImage
                       completion:(void (^)(BOOL))completion
{
    [self showRemixWithSequence:sequence
                     preloadedImage:preloadedImage
                   defaultVideoEdit:VDefaultVideoEditGIF
                         completion:completion];
}

- (void)showGiffersOnNavigationController:(UINavigationController *)navigationController
                                 sequence:(VSequence *)sequence
{
    NSParameterAssert(sequence != nil);
    VStreamCollectionViewController *gifStream = [self.dependencyManager gifStreamForSequence:sequence];
    [navigationController pushViewController:gifStream animated:YES];
}

- (void)showMemersOnNavigationController:(UINavigationController *)navigationController
                                sequence:(VSequence *)sequence
{
    NSParameterAssert(sequence != nil);
    VStreamCollectionViewController *memeStream = [self.dependencyManager memeStreamForSequence:sequence];
    [navigationController pushViewController:memeStream animated:YES];
}

- (void)likeSequence:(VSequence *)sequence
      withActionView:(UIView *)actionView
          completion:(void(^)(BOOL success))completion
{
    [self likeSequence:sequence triggeringView:actionView completion:completion];
}

#pragma mark - Repost

- (void)repostActionFromNode:(VNode *)node
{
    [self repostActionFromNode:node completion:nil];
}

- (void)repostActionFromNode:(VNode *)node completion:(void(^)(BOOL))completion
{
    [self repostNode:node completion:completion];
}

- (void)updateRepostsForUser:(VUser *)user withSequence:(VSequence *)sequence
{
#warning FIXME: Redo in new architecture: Create FetcherOperation subclass
    NSError *error = nil;
    [user v_addObject:sequence to:@"repostedSequences"];
    if ( ![user.managedObjectContext save:&error] )
    {
        VLog( @"Error marking sequence as reposted for main user: %@", error );
    }
}

- (void)showRepostersWithSequence:(VSequence *)sequence
{
    VReposterTableViewController *vc = [[VReposterTableViewController alloc] initWithSequence:sequence
                                                                            dependencyManager:self.dependencyManager];
    [self.originViewController.navigationController pushViewController:vc animated:YES];
}

- (void)showLikersWithSequence:(VSequence *)sequence
{
    VDependencyManager *childDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:@{}];
    VUsersViewController *usersViewController = [[VUsersViewController alloc] initWithDependencyManager:childDependencyManager];
    usersViewController.title = NSLocalizedString( @"LikersTitle", nil );
    usersViewController.usersDataSource = [[VLikersDataSource alloc] initWithSequence:sequence];
    usersViewController.usersViewContext = VUsersViewContextLikers;
    
    [self.originViewController.navigationController pushViewController:usersViewController animated:YES];
}

#pragma mark - Share

- (void)shareWithSequence:(VSequence *)sequence
                     node:(VNode *)node
                 streamID:(NSString *)streamID
               completion:(void(^)())completion
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
        VTracking *tracking;
        if ( streamID == nil )
        {
            tracking = sequence.streamItemPointerForStandloneStreamItem.tracking;
        }
        else
        {
            tracking = [sequence streamItemPointerWithStreamID:streamID].tracking;
        }
        NSAssert( tracking != nil, @"Cannot track 'share' event because tracking data is missing." );
        
        if ( completed )
        {
            NSDictionary *params = @{ VTrackingKeySequenceCategory : sequence.category ?: @"",
                                      VTrackingKeyShareDestination : activityType ?: @"",
                                      VTrackingKeyUrls : tracking.share ?: @[]
                                      };
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidShare parameters:params];
        }
        else if ( activityError != nil )
        {
            NSDictionary *params = @{ VTrackingKeySequenceCategory : sequence.category ?: @"",
                                      VTrackingKeyShareDestination : activityType ?: @"",
                                      VTrackingKeyUrls : tracking.share ?: @[],
                                      VTrackingKeyErrorMessage : activityError == nil ? @"" : activityError.localizedDescription };
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserShareDidFail parameters:params];
        }
        
        [self.originViewController reloadInputViews];
        
        if ( completion != nil )
        {
            completion();
        }
    };
    
    [self.originViewController presentViewController:activityViewController
                                 animated:YES
                               completion:nil];
}

#pragma mark - Flag

- (void)flagSequence:(VSequence *)sequence completion:(void (^)(BOOL success))completion
{
    [self flagSequence:sequence completion:completion];
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
