//
//  VSequenceActionController.h
//  victorious
//
//  Created by Will Long on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCommentMediaType.h"

@class VSequence, VAsset, VNode, VDependencyManager, VUser, VComment, VStream;

typedef NS_ENUM(NSInteger, VDefaultVideoEdit)
{
    VDefaultVideoEditVideo,
    VDefaultVideoEditGIF,
    VDefaultVideoEditSnapshot,
};

@interface VSequenceActionController : NSObject

@property (nonatomic, strong) VDependencyManager *dependencyManager;

- (void)showCommentsFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence withSelectedComment:(VComment *)selectedComment;

- (BOOL)showPosterProfileFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence;

- (BOOL)showProfileWithRemoteId:(NSNumber *)remoteId fromViewController:(UIViewController *)viewController;

- (BOOL)showProfile:(VUser *)user fromViewController:(UIViewController *)viewController;

- (BOOL)showMediaContentViewForUrl:(NSURL *)url withMediaLinkType:(VCommentMediaType)linkType fromViewController:(UIViewController *)viewController;

/**
 *  Presents remix UI on a viewcontroller with a given sequence to remix.
 *  Will present a UIViewController for the remix UI on the pased in viewController.
 *
 *  @param viewController    The viewController to present the remix UI on.
 *  @param sequence          The sequence to remix.
 *  @param dependencyManager A dependency manager to use for creating the remix UI.
 *  @param defaultVideoEdit  The default video editing state.
 *  @param completion        A completion block. BOOL is YES if successful publish, NO if cancelled out.
 */
- (void)showRemixOnViewController:(UIViewController *)viewController
                     withSequence:(VSequence *)sequence
             andDependencyManager:(VDependencyManager *)dependencyManager
                   preloadedImage:(UIImage *)preloadedImage
                 defaultVideoEdit:(VDefaultVideoEdit)defaultVideoEdit
                       completion:(void(^)(BOOL))completion;

/**
 *  Internally calls "showRemixOnViewController:withSequence:preloadedImage:defaultVideoEdit:completion:"
 *  with VDefaultVideoGIF for default video edit.
 */
- (void)showRemixOnViewController:(UIViewController *)viewController
                     withSequence:(VSequence *)sequence
             andDependencyManager:(VDependencyManager *)dependencyManager
                   preloadedImage:(UIImage *)preloadedImage
                       completion:(void (^)(BOOL))completion;

/**
 *  Pushes a remixers VC on the given navigation controller for the given sequence.
 *
 *  @param navigationController The UINavigationController to push the remixers stream on.
 *  @param sequence             A valid sequence. Can't be nil.
 *  @param dependencyManager    A valid dependency manager.
 */
- (void)showGiffersOnNavigationController:(UINavigationController *)navigationController
                                 sequence:(VSequence *)sequence
                     andDependencyManager:(VDependencyManager *)dependencyManager;

- (void)showMemersOnNavigationController:(UINavigationController *)navigationController
                                sequence:(VSequence *)sequence
                    andDependencyManager:(VDependencyManager *)dependencyManager;

- (void)repostActionFromViewController:(UIViewController *)viewController
                                  node:(VNode *)node;

- (void)repostActionFromViewController:(UIViewController *)viewController
                                  node:(VNode *)node
                            completion:(void(^)(BOOL))completion;

- (void)showRepostersFromViewController:(UIViewController *)viewController
                               sequence:(VSequence *)sequence;

- (void)shareFromViewController:(UIViewController *)viewController
                       sequence:(VSequence *)sequence
                           node:(VNode *)node
                       streamID:(NSString *)streamID
                     completion:(void(^)())completion;

- (void)flagSheetFromViewController:(UIViewController *)viewController
                           sequence:(VSequence *)sequence
                         completion:(void (^)(BOOL success))completion;

- (void)flagActionForSequence:(VSequence *)sequence
           fromViewController:(UIViewController *)viewController
                   completion:(void (^)(BOOL success))completion;


- (void)showLikersFromViewController:(UIViewController *)viewControlle
                            sequence:(VSequence *)sequence;

- (void)likeSequence:(VSequence *)sequence fromViewController:(UIViewController *)viewController
      withActionView:(UIView *)actionView
          completion:(void(^)(BOOL success))completion;

@end
