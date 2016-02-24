//
//  VSequenceActionController.h
//  victorious
//
//  Created by Will Long on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCommentMediaType.h"

@class VSequence, VAsset, VNode, VDependencyManager, VUser, VComment, VStream, ContentViewPresenterDelegate;

typedef NS_ENUM(NSInteger, VDefaultVideoEdit)
{
    VDefaultVideoEditVideo,
    VDefaultVideoEditGIF,
    VDefaultVideoEditSnapshot,
};

@interface VSequenceActionController : NSObject

@property (nonatomic, weak, readonly) VDependencyManager *dependencyManager;
@property (nonatomic, weak, readonly) UIViewController *originViewController;

- (instancetype)initWithDepencencyManager:(VDependencyManager *)dependencyManager andOriginViewController:(UIViewController *)originViewController;

- (void)showCommentsWithSequence:(VSequence *)sequence withSelectedComment:(VComment *)selectedComment;

- (BOOL)showPosterProfileWithSequence:(VSequence *)sequence;

- (BOOL)showProfileWithRemoteId:(NSNumber *)remoteId;

- (BOOL)showProfile:(VUser *)user;

- (BOOL)showMediaContentViewForUrl:(NSURL *)url withMediaLinkType:(VCommentMediaType)linkType;

/**
 *  Presents remix UI on the ViewController given in the initializer with a given sequence to remix.
 *  Will present a UIViewController for the remix UI on the passed in originViewController.
 *
 *  @param sequence          The sequence to remix.
 *  @param defaultVideoEdit  The default video editing state.
 *  @param completion        A completion block. BOOL is YES if successful publish, NO if cancelled out.
 */
- (void)showRemixWithSequence:(VSequence *)sequence
                   preloadedImage:(UIImage *)preloadedImage
                 defaultVideoEdit:(VDefaultVideoEdit)defaultVideoEdit
                       completion:(void(^)(BOOL))completion;

/**
 *  Internally calls "showRemixWithSequence:preloadedImage:defaultVideoEdit:completion:"
 *  with VDefaultVideoGIF for default video edit.
 */
- (void)showRemixWithSequence:(VSequence *)sequence
                   preloadedImage:(UIImage *)preloadedImage
                       completion:(void (^)(BOOL))completion;

/**
 *  Pushes a remixers VC on the given navigation controller for the given sequence.
 *
 *  @param navigationController The UINavigationController to push the remixers stream on.
 *  @param sequence             A valid sequence. Can't be nil.
 */
- (void)showGiffersOnNavigationController:(UINavigationController *)navigationController
                                 sequence:(VSequence *)sequence;

- (void)showMemersOnNavigationController:(UINavigationController *)navigationController
                                sequence:(VSequence *)sequence;

- (void)repostActionFromNode:(VNode *)node;

- (void)repostActionFromNode:(VNode *)node
              completion:(void(^)(BOOL))completion;

- (void)showRepostersWithSequence:(VSequence *)sequence;

- (void)shareWithSequence:(VSequence *)sequence
                     node:(VNode *)node
                 streamID:(NSString *)streamID
               completion:(void(^)())completion;

- (void)flagWithSequence:(VSequence *)sequence
                   completion:(void (^)(BOOL success))completion;


- (void)showLikersWithSequence:(VSequence *)sequence;

- (void)likeSequence:(VSequence *)sequence
      withActionView:(UIView *)actionView
          completion:(void(^)(BOOL success))completion;

@end
