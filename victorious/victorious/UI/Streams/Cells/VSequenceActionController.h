//
//  VSequenceActionController.h
//  victorious
//
//  Created by Will Long on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSequence, VAsset, VNode, VDependencyManager;

typedef NS_ENUM(NSInteger, VDefaultVideoEdit)
{
    VDefaultVideoEditVideo,
    VDefaultVideoEditGIF,
    VDefaultVideoEditSnapshot,
};

@interface VSequenceActionController : NSObject

@property (nonatomic, strong) VDependencyManager *dependencyManager;

- (void)showCommentsFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence;

- (BOOL)showPosterProfileFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence;

/**
 *  Internally calls -showRemixOnViewController:withSequence:preloadedImage:completion: with nil for completion.
 */
- (void)showRemixOnViewController:(UIViewController *)viewController
                     withSequence:(VSequence *)sequence
             andDependencyManager:(VDependencyManager *)dependencyManager;

/**
 *  Internally calls -showRemixOnViewController:withSequence:preloadedImage:completion:
 * with nil for completion and preloadedImage.
 */
- (void)showRemixOnViewController:(UIViewController *)viewController
                     withSequence:(VSequence *)sequence
             andDependencyManager:(VDependencyManager *)dependencyManager
                       completion:(void(^)(BOOL))completion;

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
- (void)showRemixersOnnNavigationController:(UINavigationController *)navigationController
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
                     completion:(void(^)())completion;

- (void)shareFromViewController:(UIViewController *)viewController
                       sequence:(VSequence *)sequence
                           node:(VNode *)node;

- (void)flagSheetFromViewController:(UIViewController *)viewController
                           sequence:(VSequence *)sequence;

- (void)flagActionForSequence:(VSequence *)sequence;

@end
