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

@property (nonatomic, strong) VSequence *sequence;

- (void)remixActionFromViewController:(UIViewController *)viewController asset:(VAsset *)asset node:(VNode *)node;
- (void)imageRemixActionFromViewController:(UIViewController *)viewController previewImage:(UIImage *)previewImage;
- (void)showRemixStreamFromViewController:(UIViewController *)viewController;

@end
