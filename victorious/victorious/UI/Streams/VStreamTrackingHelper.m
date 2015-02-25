//
//  VStreamTrackingHelper.m
//  victorious
//
//  Created by Patrick Lynch on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamTrackingHelper.h"
#import "VStream.h"
#import "VSequence.h"
#import "VTracking.h"

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
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kStreamTrackingHelperLoggedInChangedNotification
                                                  object:nil];
}

#pragma mark - Apperance/disappearance

- (void)onStreamViewWillAppearWithStream:(VStream *)stream
{
    [[VTrackingManager sharedInstance] setValue:VTrackingValueStream forSessionParameterWithKey:VTrackingKeyContext];
    
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

- (void)onStreamCellDidBecomeVisibleWithStream:(VStream *)stream sequence:(VSequence *)sequence
{
    if ( sequence == nil || stream == nil )
    {
        return;
    }
    
    NSDictionary *params = @{ VTrackingKeySequenceId : sequence.remoteId,
                              VTrackingKeyTimeStamp : [NSDate date],
                              VTrackingKeyUrls : sequence.tracking.cellView };
    [[VTrackingManager sharedInstance] queueEvent:VTrackingEventSequenceDidAppearInStream
                                       parameters:params
                                          eventId:sequence.remoteId];
}

- (void)onStreamCellSelectedWithStream:(VStream *)stream sequence:(VSequence *)sequence
{
    NSDictionary *params = @{ VTrackingKeySequenceId : sequence.remoteId,
                              VTrackingKeyTimeStamp : [NSDate date],
                              VTrackingKeyUrls : sequence.tracking.cellClick,
                              VTrackingKeyStreamId : stream.trackingIdentifier ?: @""};
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectItemFromStream parameters:params];
}

- (void)resetCellVisibilityTracking
{
    [[VTrackingManager sharedInstance] clearQueuedEventsWithName:VTrackingEventSequenceDidAppearInStream];
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

- (void)viewControllerSelected:(VStream *)stream
{
    if ( self.canTrackViewDidAppear )
    {
        self.didTrackViewDidAppear = YES;
        [self trackStreamDidAppear:stream];
    }
}

- (void)viewControllerAppearedAsInitial:(VStream *)stream
{
    if ( self.canTrackViewDidAppear && !self.didTrackViewDidAppear )
    {
        self.didTrackViewDidAppear = YES;
        [self trackStreamDidAppear:stream];
    }
}

#pragma mark - Private

- (void)trackStreamDidAppear:(VStream *)stream
{
    NSDictionary *params = @{ VTrackingKeyStreamName : stream.name ?: @"",
                              VTrackingKeyStreamId : stream.trackingIdentifier ?: @""};
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidViewStream parameters:params];
}

#pragma mark - Notificaiton handler

- (void)loginStatusDidChange:(NSNotification *)notification
{
    self.didTrackViewDidAppear = NO;
    self.canTrackViewDidAppear = NO;
}

@end
