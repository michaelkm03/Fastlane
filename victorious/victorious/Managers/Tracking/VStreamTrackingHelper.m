//
//  VStreamTrackingHelper.m
//  victorious
//
//  Created by Patrick Lynch on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamTrackingHelper.h"
#import "VStream+Fetcher.h"
#import "VStreamItem+Fetcher.h"
#import "VSequence.h"
#import "VTracking.h"
#import "VVideoSettings.h"
#import "victorious-Swift.h"

NSString * const kStreamTrackingHelperLoggedInChangedNotification = @"com.getvictorious.LoggedInChangedNotification";

@interface VStreamTrackingHelper()

@property (nonatomic, readwrite) BOOL didTrackViewDidAppear;
@property (nonatomic, readwrite) BOOL canTrackViewDidAppear;

@property (nonatomic, strong) VVideoSettings *videoSettings;
@property (nonatomic, strong) AutoplayTrackingHelper *autoplayTrackingHelper;

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
    [[VTrackingManager sharedInstance] setValue:nil forSessionParameterWithKey:VTrackingKeyStreamId];
    
    [self resetCellVisibilityTracking];
    
    if ( isBeingDismissed )
    {
        [[VTrackingManager sharedInstance] setValue:nil forSessionParameterWithKey:VTrackingKeyContext];
    }
}

- (void)onStreamViewDidAppearWithStream:(VStream *)stream
{
    [self trackStreamDidAppear:stream];
}

#pragma mark - Cell visibily tracking (SequenceDidAppearInStream event)

- (void)onStreamCellDidBecomeVisibleWithCellEvent:(StreamCellContext *)event
{
    VSequence *sequence = (VSequence *)event.streamItem;
    VStream *stream = event.stream;
    
    if ( sequence == nil || stream == nil )
    {
        return;
    }
    
    NSString *trackingID = event.fromShelf ? stream.shelfId : stream.trackingIdentifier;
    NSDictionary *params = @{ VTrackingKeySequenceId : sequence.remoteId,
                              VTrackingKeyTimeStamp : [NSDate date],
                              VTrackingKeyUrls : sequence.tracking.cellView,
                              VTrackingKeyStreamId : trackingID ?: @""};
    [[VTrackingManager sharedInstance] queueEvent:VTrackingEventSequenceDidAppearInStream
                                       parameters:params
                                          eventId:sequence.remoteId];
}

- (void)onStreamCellSelectedWithCellEvent:(StreamCellContext *)event
{
    VSequence *sequence = (VSequence *)event.streamItem;
    VStream *stream = event.stream;
    
    NSString *trackingID = event.fromShelf ? stream.shelfId : stream.trackingIdentifier;
    NSDictionary *params = @{ VTrackingKeySequenceId : sequence.remoteId,
                              VTrackingKeyTimeStamp : [NSDate date],
                              VTrackingKeyUrls : sequence.tracking.cellClick,
                              VTrackingKeyStreamId : trackingID ?: @""};
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectItemFromStream parameters:params];
    
    // Track an autoplay click if necessary
    if (!sequence.isGifStyle.boolValue)
    {
        if (!sequence.firstNode.httpLiveStreamingAsset.streamAutoplay.boolValue && [self.videoSettings isAutoplayEnabled])
        {
            self.autoplayTrackingHelper.trackingItem = sequence.tracking;
            [self.autoplayTrackingHelper trackAutoplayClick];
        }
    }
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

#pragma mark - Private

- (void)trackStreamDidAppear:(VStream *)stream
{
    self.didTrackViewDidAppear = YES;
    
    if (stream.isHashtagStream)
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
    NSString *context = [stream isHashtagStream] ? VTrackingValueHashtagStream : VTrackingValueStream;
    [[VTrackingManager sharedInstance] setValue:context forSessionParameterWithKey:VTrackingKeyContext];
}

- (void)resetCellVisibilityTracking
{
    [[VTrackingManager sharedInstance] clearQueuedEventsWithName:VTrackingEventSequenceDidAppearInStream];
}

- (VVideoSettings *)videoSettings
{
    if (_videoSettings == nil)
    {
        _videoSettings = [[VVideoSettings alloc] init];
    }
    return _videoSettings;
}

- (AutoplayTrackingHelper *)autoplayTrackingHelper
{
    if (_autoplayTrackingHelper == nil)
    {
        _autoplayTrackingHelper = [[AutoplayTrackingHelper alloc] init];
    }
    return _autoplayTrackingHelper;
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
