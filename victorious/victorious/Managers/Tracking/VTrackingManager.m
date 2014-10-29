//
//  VTrackingManager.m
//  victorious
//
//  Created by Patrick Lynch on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrackingManager.h"

NSString * const VTrackingEventNameSequenceSelected                 = @"com.getvictorious.VTrackingEventNameSequenceSelected";
NSString * const VTrackingEventNameSequenceDidAppearInStream        = @"com.getvictorious.VTrackingEventNameSequenceDidAppearInStream";
NSString * const VTrackingEventNameVideoDidComplete25               = @"com.getvictorious.VTrackingEventNameVideoDidComplete25";
NSString * const VTrackingEventNameVideoDidComplete50               = @"com.getvictorious.VTrackingEventNameVideoDidComplete50";
NSString * const VTrackingEventNameVideoDidComplete75               = @"com.getvictorious.VTrackingEventNameVideoDidComplete75";
NSString * const VTrackingEventNameVideoDidComplete100              = @"com.getvictorious.VTrackingEventNameVideoDidComplete100";
NSString * const VTrackingEventNameVideoDidError                    = @"com.getvictorious.VTrackingEventNameVideoDidError";
NSString * const VTrackingEventNameVideoDidSkip                     = @"com.getvictorious.VTrackingEventNameVideoDidSkip";
NSString * const VTrackingEventNameVideoDidStall                    = @"com.getvictorious.VTrackingEventNameVideoDidStall";
NSString * const VTrackingEventNameVideoDidStart                    = @"com.getvictorious.VTrackingEventNameVideoDidStart";
NSString * const VTrackingEventNameUserDidVoteSequence              = @"com.getvictorious.VTrackingEventNameUserDidVoteSequence";
NSString * const VTrackingEventNameApplicationDidEnterForeground    = @"com.getvictorious.VTrackingEventNameApplicationDidEnterForeground";
NSString * const VTrackingEventNameApplicationDidLaunch             = @"com.getvictorious.VTrackingEventNameApplicationDidLaunch";
NSString * const VTrackingEventNameApplicationDidEnterBackground    = @"com.getvictorious.VTrackingEventNameApplicationDidEnterBackground";
NSString * const VTrackingEventNameApplicationFirstInstall          = @"com.getvictorious.VTrackingEventNameApplicationFirstInstall";
NSString * const VTrackingEventNameUserDidPostComment               = @"com.getvictorious.VTrackingEventNameUserDidPostComment";
NSString * const VTrackingEventNameRemixSelected                    = @"com.getvictorious.VTrackingEventNameRemixSelected";
NSString * const VTrackingEventNameRemixCompleted                   = @"com.getvictorious.VTrackingEventNameRemixCompleted";
NSString * const VTrackingEventNameRemixTrimStarted                 = @"com.getvictorious.VTrackingEventNameRemixTrimStarted";
NSString * const VTrackingEventNameRemixTrimCompleted               = @"com.getvictorious.VTrackingEventNameRemixTrimCompleted";

NSString * const VTrackingParamKeyTimeFrom          = @"com.getvictorious.VTrackingParamKeyTimeFrom";
NSString * const VTrackingParamKeyTimeTo            = @"com.getvictorious.VTrackingParamKeyTimeTo";
NSString * const VTrackingParamKeyTimeCurrent       = @"com.getvictorious.VTrackingParamKeyTimeCurrent";
NSString * const VTrackingParamKeyTimeStamp         = @"com.getvictorious.VTrackingParamKeyTimeStamp";
NSString * const VTrackingParamKeyPageLabel         = @"com.getvictorious.VTrackingParamKeyPageLabel";
NSString * const VTrackingParamKeyPositionX         = @"com.getvictorious.VTrackingParamKeyPositionX";
NSString * const VTrackingParamKeyPositionY         = @"com.getvictorious.VTrackingParamKeyPositionY";
NSString * const VTrackingParamKeyNavigiationFrom   = @"com.getvictorious.VTrackingParamKeyNavigiationFrom";
NSString * const VTrackingParamKeyNavigiationTo     = @"com.getvictorious.VTrackingParamKeyNavigiationTo";
NSString * const VTrackingParamKeyStreamId          = @"com.getvictorious.VTrackingParamKeyStreamId";
NSString * const VTrackingParamKeySequenceId        = @"com.getvictorious.VTrackingParamKeySequenceId";
NSString * const VTrackingParamKeyVoteCount         = @"com.getvictorious.VTrackingParamKeyVoteCount";
NSString * const VTrackingParamKeyUrls              = @"com.getvictorious.VTrackingParamKeyUrls";

@interface VTrackingManager ()

@property (nonatomic, strong) NSMutableArray *services;

@end

static VTrackingManager *_sharedInstance;

@implementation VTrackingManager

+ (VTrackingManager *)sharedInstance
{
    if ( _sharedInstance == nil )
    {
        _sharedInstance = [[self alloc] init];
    }
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _services = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (void)trackEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters
{
    NSParameterAssert( eventName != nil );
    
    [[self sharedInstance].services enumerateObjectsUsingBlock:^(id<VTrackingService> service, NSUInteger idx, BOOL *stop)
    {
        [service trackEventWithName:eventName withParameters:parameters];
    }];
}

+ (void)addService:(id<VTrackingService>)service
{
    [[self sharedInstance].services addObject:service];
}

+ (void)removeService:(id<VTrackingService>)service
{
    [[self sharedInstance].services removeObject:service];
    
    if ( [self sharedInstance].services.count == 0 )
    {
        [self deallocateSharedInstance];
    }
}

+ (void)removeAllServices
{
    [[self sharedInstance].services removeAllObjects];
    [self deallocateSharedInstance];
}

+ (void)deallocateSharedInstance
{
    _sharedInstance = nil;
}

@end
