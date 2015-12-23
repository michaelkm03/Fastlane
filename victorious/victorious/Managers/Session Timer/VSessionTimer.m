//
//  VSessionTimer.m
//  victorious
//
//  Created by Josh Hinman on 7/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSArray+VMap.h"
#import "VDependencyManager+VTracking.h"
#import "VObjectManager+Analytics.h"
#import "VRootViewController.h"
#import "VSessionTimer.h"
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

@property (nonatomic) BOOL firstLaunch;
@property (nonatomic) BOOL transitioningFromBackgroundToForeground;
@property (nonatomic, readwrite) BOOL started;
@property (nonatomic, strong) NSDate *sessionStartTime;

@end

@implementation VSessionTimer

- (void)start
{
    if ( self.started )
    {
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)  name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)     name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)    name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    self.transitioningFromBackgroundToForeground = YES;
    self.started = YES;
    self.firstLaunch = YES;
    [self sessionDidStart];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Session Lifecycle

- (BOOL)shouldNewSessionStartNow
{
    NSDate *lastSessionEnd = [[NSUserDefaults standardUserDefaults] objectForKey:kSessionEndTimeDefaultsKey];
    if (lastSessionEnd)
    {
        NSTimeInterval previousBackgroundTime = -[lastSessionEnd timeIntervalSinceNow];
        return !self.firstLaunch && previousBackgroundTime >= kMinimumTimeBetweenSessions;
    }
    else
    {
        return NO;
    }
}

- (void)sessionDidStart
{
    self.sessionStartTime = [NSDate date];
    
    if ( [self shouldNewSessionStartNow] )
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:VSessionTimerNewSessionShouldStart object:self];
        [self.delegate sessionTimerDidResetSession:self];
    }
    if ( self.firstLaunch )
    {
        [self trackApplicationLaunch];
    }
    else
    {
        [self trackApplicationForeground];
    }
    self.firstLaunch = NO;
}

- (void)sessionDidEnd
{
    self.firstLaunch = NO;
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kSessionEndTimeDefaultsKey];
    [[VTrackingManager sharedInstance] clearSessionParameters];
    
}

- (NSUInteger)sessionDuration
{
    NSDate *startDate = self.sessionStartTime;
    NSUInteger duration = (NSUInteger)([[NSDate date] timeIntervalSinceDate:startDate] * 1000); // Backend requires milliseconds
    return duration;
}

#pragma mark - Tracking

- (void)trackApplicationForeground
{
    NSArray *trackingURLs = [self.dependencyManager trackingURLsForKey:VTrackingStartKey] ?: @[];
    NSDictionary *params = @{ VTrackingKeyUrls : trackingURLs };
    [[VObjectManager sharedManager] resetSessionID];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventApplicationDidEnterForeground parameters:params];
}

- (void)trackApplicationBackground
{
    NSArray *trackingURLs = [self.dependencyManager trackingURLsForKey:VTrackingStopKey] ?: @[];
    NSDictionary *params = @{ VTrackingKeyUrls : trackingURLs, VTrackingKeySessionTime : [NSNumber numberWithUnsignedInteger:self.sessionDuration] };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventApplicationDidEnterBackground parameters:params];
}

- (void)trackApplicationLaunch
{
    // Track first install
    [[[VFirstInstallManager alloc] init] reportFirstInstallWithTrackingURLs:[self.dependencyManager trackingURLsForKey:VTrackingInstallKey]];
    
    // Tracking init (cold start)
    NSArray *trackingURLs = [self.dependencyManager trackingURLsForKey:VTrackingInitKey] ?: @[];
    NSDictionary *params = @{ VTrackingKeyUrls : trackingURLs };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventApplicationDidLaunch parameters:params];
    
    // Set a default until the user logs in, either manually or automatically from saved info
    [[VTrackingManager sharedInstance] setValue:@(NO) forSessionParameterWithKey:VTrackingKeyUserLoggedIn];
}

#pragma mark - NSNotification handlers

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self trackApplicationBackground];
    [self sessionDidEnd];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (self.transitioningFromBackgroundToForeground)
    {
        self.transitioningFromBackgroundToForeground = NO;
        if ( ![self shouldNewSessionStartNow] )
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:VApplicationDidBecomeActiveNotification  object:self];
        }
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