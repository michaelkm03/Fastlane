//
//  VSequenceActionController.h
//  victorious
//
//  Created by Will Long on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSequence, VAsset, VNode;

@interface VSequenceActionController : NSObject

- (void)showCommentsFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence;

- (void)showPosterProfileFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence;

- (void)videoRemixActionFromViewController:(UIViewController *)viewController asset:(VAsset *)asset node:(VNode *)node sequence:(VSequence *)sequence;
- (void)imageRemixActionFromViewController:(UIViewController *)viewController previewImage:(UIImage *)previewImage sequence:(VSequence *)sequence;
- (void)showRemixStreamFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence;


- (BOOL)repostActionFromViewController:(UIViewController *)viewController node:(VNode *)node;///<Returns true if the user is allow to repost, false if not
- (void)showRepostersFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence;

- (void)shareFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence node:(VNode *)node;

- (void)flagSheetFromViewController:(UIViewController *)viewController sequence:(VSequence *)sequence;
- (void)flagActionForSequence:(VSequence *)sequence;

@end
