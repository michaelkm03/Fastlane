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

@end

@implementation VSessionTimer

- (id)init
{
    self = [super init];
    if (self)
    {
        _previousBackgroundTime = kVFirstLaunch;
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
    if (lastSessionEnd)
    {
        self.previousBackgroundTime = -[lastSessionEnd timeIntervalSinceNow];
    }
    
    if ( [self shouldNewSessionStartNow] )
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:VSessionTimerNewSessionShouldStart object:self];
    }
    self.firstLaunch = NO;
    [self trackApplicationForeground];
}

- (void)sessionDidEnd
{
    self.firstLaunch = NO;
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kSessionEndTimeDefaultsKey];
}

#pragma mark - Tracking

- (void)trackApplicationForeground
{
    VTracking *applicationTracking = [VSettingManager sharedManager].applicationTracking;
    
    NSArray* trackingURLs = applicationTracking != nil ? applicationTracking.appEnterForeground : @[];
    NSDictionary *params = @{ VTrackingKeyUrls : trackingURLs };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventApplicationDidEnterForeground parameters:params];
}

- (void)trackApplicationBackground
{
    VTracking *applicationTracking = [VSettingManager sharedManager].applicationTracking;
    
    NSArray* trackingURLs = applicationTracking != nil ? applicationTracking.appEnterBackground : @[];
    NSDictionary *params = @{ VTrackingKeyUrls : trackingURLs };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventApplicationDidEnterBackground parameters:params];
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
