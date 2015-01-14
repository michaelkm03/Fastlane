//
//  VSequenceActionController.h
//  victorious
//
//  Created by Will Long on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSequence, VAsset, VNode, VDependencyManager;

@interface VSequenceActionController : NSObject

- (void)showCommentsFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence;

- (BOOL)showPosterProfileFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence;

- (void)videoRemixActionFromViewController:(UIViewController *)viewController asset:(VAsset *)asset node:(VNode *)node sequence:(VSequence *)sequence withDependencyManager:(VDependencyManager *)dependencyManager;
- (void)imageRemixActionFromViewController:(UIViewController *)viewController previewImage:(UIImage *)previewImage sequence:(VSequence *)sequence;
- (void)imageRemixActionFromViewController:(UIViewController *)viewController previewImage:(UIImage *)previewImage sequence:(VSequence *)sequence completion:(void(^)(BOOL))completion;
- (void)showRemixStreamFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence;


- (BOOL)repostActionFromViewController:(UIViewController *)viewController node:(VNode *)node;///<Returns true if the user is allow to repost, false if not
- (BOOL)repostActionFromViewController:(UIViewController *)viewController node:(VNode *)node completion:(void(^)(BOOL))completion;

- (void)showRepostersFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence;

- (void)shareFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence node:(VNode *)node;

- (void)flagSheetFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence;
- (void)flagActionForSequence:(VSequence *)sequence;

@end
