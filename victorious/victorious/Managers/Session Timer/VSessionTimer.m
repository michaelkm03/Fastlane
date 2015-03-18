//
//  VSessionTimer.m
//  victorious
//
//  Created by Josh Hinman on 7/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSArray+VMap.h"
#import "VObjectManager+Analytics.h"
#import "VSessionTimer.h"
#import "VSettingManager.h"
#import "VTracking.h"
#import "VFirstInstallManager.h"

#define TEST_NEW_SESSION 0 // Set to '1' to start a new session by leaving the app for only 10 seconds.

NSTimeInterval kVFirstLaunch = DBL_MAX;

NSString * const VSessionTimerNewSessionShouldStart     = @"VSessionTimerNewSessionShouldStart";

static NSString * const kSessionEndTimeDefaultsKey      = @"com.victorious.VSessionTimer.SessionEndTime";
static NSString * const kSessionEndTimePropertyListKey  = @"date";
static NSString * const kSessionLengthPropertyListKey   = @"length";

#if TEST_NEW_SESSION
#warning New sessions will start after 10 seconds of background time
static NSTimeInterval const kMinimumTimeBetweenSessions = 10.0;
#else
static NSTimeInterval const kMinimumTimeBetweenSessions = 1800.0; // 30 minutes
#endif

@interface VSessionTimer ()

@property (nonatomic, readwrite) NSTimeInterval previousBackgroundTime;
@property (nonatomic) BOOL firstLaunch;
@property (nonatomic) BOOL transitioningFromBackgroundToForeground;
@property (nonatomic, strong) NSDate *sessionStartTime;
@property (nonatomic, strong) VSettingManager *settingsManager;
@property (nonatomic, strong) NSMutableArray *queuedEventNames;
@property (nonatomic, strong) VFirstInstallManager *firstInstallManager;

@end

@implementation VSessionTimer

- (id)init
{
    self = [super init];
    if (self)
    {
        _previousBackgroundTime = kVFirstLaunch;
        _queuedEventNames = [[NSMutableArray alloc] init];
        _firstInstallManager = [[VFirstInstallManager alloc] init];
    }
    return self;
}

- (void)start
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)  name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)     name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)    name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    self.transitioningFromBackgroundToForeground = YES;
    
    self.firstLaunch = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Session Lifecycle

- (BOOL)shouldNewSessionStartNow
{
    return !self.firstLaunch && self.previousBackgroundTime >= kMinimumTimeBetweenSessions;
}

- (void)sessionDidStart
{
    self.sessionStartTime = [NSDate date];
    
    NSDate *lastSessionEnd = [[NSUserDefaults standardUserDefaults] objectForKey:kSessionEndTimeDefaultsKey];
    if ( lastSessionEnd )
    {
        self.previousBackgroundTime = -[lastSessionEnd timeIntervalSinceNow];
    }
    
    if ( [self shouldNewSessionStartNow] )
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:VSessionTimerNewSessionShouldStart object:self];
    }
    
    [self trackEventsForSessionDidStart];
}

- (void)trackEventsForSessionDidStart
{
    if ( self.firstLaunch )
    {
        // Set a default until the user logs in, either manually or automatically from saved info
        [[VTrackingManager sharedInstance] setValue:@(NO) forSessionParameterWithKey:VTrackingKeyUserLoggedIn];
        
        [self.queuedEventNames addObject:VTrackingEventApplicationDidLaunch];
        [self.queuedEventNames addObject:VTrackingEventApplicationFirstInstall];
        [self trackEventsInQueue];
    }
    else
    {
        [self.queuedEventNames addObject:VTrackingEventApplicationDidEnterForeground];
        [self trackEventsInQueue];
    }
    self.firstLaunch = NO;
}

- (void)sessionDidEnd
{
    self.firstLaunch = NO;
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kSessionEndTimeDefaultsKey];
}

- (void)appInitDidCompleteWithSettingsManager:(VSettingManager *)settingsManager
{
    self.settingsManager = settingsManager;
    
    [self trackEventsInQueue];
}

#pragma mark - Tracking

- (void)trackEventsInQueue
{
    if ( self.settingsManager == nil )
    {
        return;
    }
    
    VTracking *applicationTracking = self.settingsManager.applicationTracking;
    
    [self.queuedEventNames enumerateObjectsUsingBlock:^(NSString *eventName, NSUInteger idx, BOOL *stop)
     {
         if ( [eventName isEqualToString:VTrackingEventApplicationDidEnterForeground] )
         {
             NSArray* trackingURLs = applicationTracking != nil ? applicationTracking.appEnterForeground : @[];
             NSDictionary *params = @{ VTrackingKeyUrls : trackingURLs };
             [[VTrackingManager sharedInstance] trackEvent:eventName parameters:params];
         }
         else if ( [eventName isEqualToString:VTrackingEventApplicationDidEnterBackground] )
         {
             NSDate *startDate = self.sessionStartTime;
             NSDate *endDate = [[NSUserDefaults standardUserDefaults] objectForKey:kSessionEndTimeDefaultsKey];
             NSTimeInterval sessionDuration = [endDate timeIntervalSinceDate:startDate] * 1000;  // Backend requires milliseconds
             
             NSArray* trackingURLs = applicationTracking != nil ? applicationTracking.appEnterBackground : @[];
             NSDictionary *params = @{ VTrackingKeyUrls : trackingURLs, VTrackingKeySessionTime : [NSNumber numberWithUnsignedInteger:sessionDuration] };
             [[VTrackingManager sharedInstance] trackEvent:eventName parameters:params];
         }
         else if ( [eventName isEqualToString:VTrackingEventApplicationDidLaunch] )
         {
             // Tracking init (cold start)
             NSArray* trackingURLs = applicationTracking != nil ? applicationTracking.appLaunch : @[];
             NSDictionary *params = @{ VTrackingKeyUrls : trackingURLs };
             [[VTrackingManager sharedInstance] trackEvent:VTrackingEventApplicationDidLaunch parameters:params];
         }
         else if ( [eventName isEqualToString:VTrackingEventApplicationFirstInstall] )
         {
             if ( ![self.firstInstallManager hasFirstInstallBeenTracked] )
             {
                 // Resport the install event
                 NSDate *installDate = [NSDate date];
                 NSArray *urls = applicationTracking.appInstall ?: @[];
                 NSDictionary *params = @{ VTrackingKeyTimeStamp : installDate , VTrackingKeyUrls : urls };
                 [[VTrackingManager sharedInstance] trackEvent:eventName parameters:params];
                 
                 [self.firstInstallManager reportFirstInstall];
             }
         }
    }];
    
    [self.queuedEventNames removeAllObjects];
}

#pragma mark - NSNotification handlers

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self sessionDidEnd];
    
    [self.queuedEventNames addObject:VTrackingEventApplicationDidEnterBackground];
    [self trackEventsInQueue];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (self.transitioningFromBackgroundToForeground)
    {
        self.transitioningFromBackgroundToForeground = NO;
        [self sessionDidStart];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kSessionEndTimeDefaultsKey];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    self.transitioningFromBackgroundToForeground = NO;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    self.transitioningFromBackgroundToForeground = YES;
}

@end
