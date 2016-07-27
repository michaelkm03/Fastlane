//
//  VSequencePreviewViewProtocols.h
//  victorious
//
//  Created by Patrick Lynch on 9/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

@class VSequencePreviewView, VSequence;

NS_ASSUME_NONNULL_BEGIN

@protocol VSequencePreviewViewDetailDelegate <NSObject>

- (void)previewView:(VSequencePreviewView *)previewView
  didSelectMediaURL:(NSURL *)mediaURL
       previewImage:(UIImage *)previewImage
            isVideo:(BOOL)isVideo
         sourceView:(UIView *)sourceView;

- (void)previewView:(VSequencePreviewView *)previewView
    didLikeSequence:(VSequence *)sequence
         completion:(void(^__nullable)(BOOL))completion;

@end

NS_ASSUME_NONNULL_END
