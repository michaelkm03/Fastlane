//
//  VStreamTrackingHelper.h
//  victorious
//
//  Created by Patrick Lynch on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import Foundation;

@class VStream, VSequence, StreamCellContext, VideoTrackingEvent;

/**
 A helper class that handles the somewhat complex state management rules relates
 to stream tracking.  For any stream view controller, be sure to call the events at the
 correct times as described in the comments for each method.
 */
@interface VStreamTrackingHelper : NSObject

/**
 Prevents duplicate events
 */
@property (nonatomic, readonly) BOOL didTrackViewDidAppear;

/**
 Prevents tracking views before enough data about the stream has been loaded
*/
@property (nonatomic, readonly) BOOL canTrackViewDidAppear;

/**
 Call this from a view controller's `viewWillAppear:aniamted` method.
 
 @param context A tracking constant that specifics a specific context in which to track related stream events.
 */
- (void)onStreamViewWillAppearWithStream:(VStream *)stream;

/**
 Call this from a view controller's `viewDidAppear:animated` method.
 */
- (void)onStreamViewDidAppearWithStream:(VStream *)stream isBeingPresented:(BOOL)isBeingPresented;

/**
 Call this from a view controller's `viewWilDisappear:animated` method.
 */
- (void)onStreamViewWillDisappearWithStream:(VStream *)stream isBeingDismissed:(BOOL)isBeingDismissed;

/**
 Call this whenever a cell becomes visisble according to any applicable visibility threshold requirements.
 */
- (void)onStreamCellDidBecomeVisibleWithCellEvent:(StreamCellContext *)event;

/**
 Call this when a stream cell is selected and another view will be presented/pushed to show its content.
 */
- (void)onStreamCellSelectedWithCellEvent:(StreamCellContext *)context additionalInfo:(NSDictionary *)info;

/**
 Call this after a stream has been fetched from the server and all information necessary
 to track it (name, remoteId, trackingIdentifier) are presented.
 */
- (void)streamDidLoad:(VStream *)stream;

/**
 Call this when a stream view is shown as the initial, default view in a multiple view controller container.
 */
- (void)viewControllerAppearedAsInitial:(VStream *)stream;

/**
 Call this to track autoplaying video inside a stream cell.
 */
- (void)trackAutoplayEvent:(VideoTrackingEvent *)event;

@end
