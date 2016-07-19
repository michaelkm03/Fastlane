//
//  VContentCell.h
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"
#import "VBackgroundContainer.h"
#import "VContentLikeButton.h"
#import "AdLifecycleDelegate.h"

@class VSequencePreviewView, VContentCell, VAdBreak, AdVideoPlayerViewController;

@interface VContentCell : VBaseCollectionViewCell

/**
 *  An array of UIImages to use for the animation.
 */
@property (nonatomic, strong) NSArray *animationSequence;

@property (nonatomic, assign) NSTimeInterval animationDuration;

/**
 *  Defaults to 1.
 */
@property (nonatomic, assign) NSInteger repeatCount;

@property (nonatomic, weak) id<AdLifecycleDelegate> delegate;

/**
 Used to determine how to fade in or out with an interactive-style animation
 as the cell size is changed.
 */
@property (nonatomic, assign, readwrite) CGSize maxSize;

/**
 Used to determine how to fade in or out with an interactive-style animation
 as the cell size is changed.
 */
@property (nonatomic, assign, readwrite) CGSize minSize;

@property (nonatomic, assign, readonly) BOOL isPlayingAd;

@property (nonatomic, weak, readonly) VSequencePreviewView *sequencePreviewView;

/**
 Properly rotates itself and subcomponents based on the rotation of the collection view.
 Make sure to forward this from your collection view controller.
 */
- (void)handleRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

/**
 Creates the appropraite ad video player and UI for the parameters provided.
 */
- (void)playAdWithAdBreak:(VAdBreak *)adBreak;

/**
 Puts the cell into a state where dismissal of its parent view collection view and view controller
 can continue.
 */
- (void)prepareForDismissal;

@end
