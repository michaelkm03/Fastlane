//
//  VStreamTrackingHelper.m
//  victorious
//
//  Created by Patrick Lynch on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamTrackingHelper.h"
#import "VStreamItem+Fetcher.h"
#import "VSequence.h"
#import <AVFoundation/AVFoundation.h>
#import "VReachability.h"
#import "victorious-Swift.h"

NSString * const kStreamTrackingHelperLoggedInChangedNotification = @"com.getvictorious.LoggedInChangedNotification";

@interface VStreamTrackingHelper()

@property (nonatomic, readwrite) BOOL didTrackViewDidAppear;
@property (nonatomic, readwrite) BOOL canTrackViewDidAppear;

@end

@implementation VStreamTrackingHelper

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loginStatusDidChange:)
                                                     name:kStreamTrackingHelperLoggedInChangedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Apperance/disappearance

- (void)onStreamViewWillAppearWithStream:(VStream *)stream
{
    if ( stream.trackingIdentifier != nil )
    {
        [[VTrackingManager sharedInstance] setValue:stream.trackingIdentifier
                         forSessionParameterWithKey:VTrackingKeyStreamId];
    }
    
    if ( stream.name != nil )
    {
        NSDictionary *params = @{ VTrackingKeyStreamName : stream.name };
        [[VTrackingManager sharedInstance] startEvent:VTrackingEventStreamDidAppear parameters:params];
    }
}

- (void)onStreamViewWillDisappearWithStream:(VStream *)stream isBeingDismissed:(BOOL)isBeingDismissed
{
    [[VTrackingManager sharedInstance] endEvent:VTrackingEventStreamDidAppear];
    [[VTrackingManager sharedInstance] clearValueForSessionParameterWithKey:VTrackingKeyStreamId];
    
    [self resetCellVisibilityTracking];
    
    if ( isBeingDismissed )
    {
        [[VTrackingManager sharedInstance] clearValueForSessionParameterWithKey:VTrackingKeyContext];
    }
}

- (void)onStreamViewDidAppearWithStream:(VStream *)stream
{
    [self trackStreamDidAppear:stream];
}

#pragma mark - Cell visibily tracking (SequenceDidAppearInStream event)

- (void)onStreamCellDidBecomeVisibleWithCellEvent:(StreamCellContext *)event
{
    if ( ![event.streamItem isKindOfClass:[VSequence class]] && event.streamItem.remoteId != nil )
    {
        return;
    }
    VSequence *sequence = (VSequence *)event.streamItem;
    VStream *stream = event.stream;
    VTracking *tracking = [sequence streamItemPointerWithStreamID:stream.remoteId].tracking;
    
    if ( sequence == nil || stream == nil || tracking == nil )
    {
        VLog( @"Cannot track 'cellView' because required data is missing:  Sequence: %@, Stream: %@, URLs: %@",
             sequence.remoteId, stream.remoteId, tracking.cellView);
        return;
    }
    
    NSString *trackingID = (event.fromShelf ? stream.shelfId : stream.trackingIdentifier) ?: stream.remoteId;
    NSDictionary *params = @{ VTrackingKeySequenceId : sequence.remoteId ?: @"",
                              VTrackingKeyTimeStamp : [NSDate date],
                              VTrackingKeyUrls : tracking.cellView,
                              VTrackingKeyStreamId : trackingID ?: @""};
    [[VTrackingManager sharedInstance] queueEvent:VTrackingEventSequenceDidAppearInStream
                                       parameters:params
                                          eventId:sequence.remoteId];
}

- (void)onStreamCellSelectedWithCellEvent:(StreamCellContext *)context additionalInfo:(NSDictionary *)info
{
    if ( ![context.streamItem isKindOfClass:[VSequence class]] )
    {
        return;
    }
    VSequence *sequence = (VSequence *)context.streamItem;
    VStream *stream = context.stream;
    VTracking *tracking = [sequence streamItemPointerWithStreamID:stream.remoteId].tracking;
    
    if ( sequence == nil || stream == nil || tracking == nil )
    {
        VLog( @"Cannot track 'cellClick' because required data is missing:  Sequence: %@, Stream: %@, URLs: %@",
             sequence.remoteId, stream.remoteId, tracking.cellClick);
        return;
    }

    NSString *trackingID = context.fromShelf ? stream.shelfId : stream.trackingIdentifier;
    NSDictionary *params = @{ VTrackingKeySequenceId : sequence.remoteId,
                              VTrackingKeyTimeStamp : [NSDate date],
                              VTrackingKeyUrls : tracking.cellClick,
                              VTrackingKeyStreamId : trackingID ?: @""};
    
    // Track an autoplay click if necessary
    if (!sequence.isGifStyle.boolValue)
    {
        if (sequence.firstNode.httpLiveStreamingAsset.streamAutoplay.boolValue)
        {
            VideoTrackingEvent *event = [[VideoTrackingEvent alloc] initWithName:VTrackingEventVideoDidStop urls:tracking.viewStop];
            event.context = context;
            event.autoPlay = YES;
            event.currentTime = info[VTrackingKeyTimeCurrent];
            [self trackAutoplayEvent:event];
        }
    }
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectItemFromStream parameters:[NSDictionary dictionaryWithDictionary:params]];
}

#pragma mark - State management for StreamDidAppear event

- (void)onStreamViewDidAppearWithStream:(VStream *)stream isBeingPresented:(BOOL)isBeingPresented
{
    if ( isBeingPresented && self.canTrackViewDidAppear )
    {
        [self trackStreamDidAppear:stream];
    }
}

- (void)streamDidLoad:(VStream *)stream
{
    self.canTrackViewDidAppear = YES;
    if ( !self.didTrackViewDidAppear )
    {
        [self trackStreamDidAppear:stream];
    }
}

- (void)multipleContainerDidSetSelected:(VStream *)stream
{
    if ( self.canTrackViewDidAppear )
    {
        [self trackStreamDidAppear:stream];
    }
}

- (void)viewControllerAppearedAsInitial:(VStream *)stream
{
    if ( self.canTrackViewDidAppear && !self.didTrackViewDidAppear )
    {
        [self trackStreamDidAppear:stream];
    }
}

#pragma mark - Autoplay

- (void)trackAutoplayEvent:(VideoTrackingEvent *)event
{
    [event track];
}

#pragma mark - Private

- (void)trackStreamDidAppear:(VStream *)stream
{
    self.didTrackViewDidAppear = YES;
    
    const BOOL isHashtagStream = stream.hashtag != nil;
    
    if (isHashtagStream)
    {
        NSDictionary *params = @{ VTrackingKeyStreamName : stream.name ?: @"",
                                  VTrackingKeyStreamId : stream.trackingIdentifier ?: @"",
                                  VTrackingKeyHashtag : stream.hashtag ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidViewHashtagStream parameters:params];
    }
    else
    {
        NSDictionary *params = @{ VTrackingKeyStreamName : stream.name ?: @"",
                                  VTrackingKeyStreamId : stream.trackingIdentifier ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidViewStream parameters:params];
    }
    
    // Be sure to set context AFTER the events above, so that the above events contain
    // any previous context, and the new context below affects subsequent events
    NSString *context = isHashtagStream ? VTrackingValueHashtagStream : VTrackingValueStream;
    [[VTrackingManager sharedInstance] setValue:context forSessionParameterWithKey:VTrackingKeyContext];
}

- (void)resetCellVisibilityTracking
{
    [[VTrackingManager sharedInstance] clearQueuedEventsWithName:VTrackingEventSequenceDidAppearInStream];
}

#pragma mark - Notificaiton handler

- (void)loginStatusDidChange:(NSNotification *)notification
{
    self.didTrackViewDidAppear = NO;
    self.canTrackViewDidAppear = NO;
}

- (void)didEnterBackground:(NSNotification *)notification
{
    [self resetCellVisibilityTracking];
}

@end