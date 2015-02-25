//
//  VStreamTrackingHelper.h
//  victorious
//
//  Created by Patrick Lynch on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import Foundation;

@class VStream, VSequence;

@interface VStreamTrackingHelper : NSObject

/**
 Prevents duplicate events
 */
@property (nonatomic, readonly) BOOL didTrackViewDidAppear;

/**
 Prevents tracking views before enough data about the stream has been loaded
*/
@property (nonatomic, readonly) BOOL canTrackViewDidAppear;

- (void)onStreamViewWillAppearWithStream:(VStream *)stream;

- (void)onStreamViewDidAppearWithStream:(VStream *)stream isBeingPresented:(BOOL)isBeingPresented;

- (void)onStreamViewWillDisappearWithStream:(VStream *)stream isBeingDismissed:(BOOL)isBeingDismissed;

- (void)onStreamCellDidBecomeVisibleWithStream:(VStream *)stream sequence:(VSequence *)sequence;

- (void)onStreamCellSelectedWithStream:(VStream *)stream sequence:(VSequence *)sequence;

- (void)resetCellVisibilityTracking;

- (void)streamDidLoad:(VStream *)stream;

- (void)viewControllerSelected:(VStream *)stream;

- (void)viewControllerAppearedAsInitial:(VStream *)stream;

@end
