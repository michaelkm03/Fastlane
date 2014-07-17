//
//  VAnalyticsRecorder.m
//  victorious
//
//  Created by Josh Hinman on 6/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "VAnalyticsRecorder.h"
#import "VConstants.h"

#import <Crashlytics/Crashlytics.h>

#define EnableAnalyticsLogs 0 // Set to "1" to see analytics logging, but please remember to set it back to "0" before committing your changes.

static NSString * const kVAnalyticsEventAppLaunch  = @"Cold Launch";
static NSString * const kVAnalyticsEventAppSuspend = @"Suspend";
static NSString * const kVAnalyticsEventAppResume  = @"Resume";

NSString * const kVAnalyticsEventCategoryNavigation   = @"Navigation";
NSString * const kVAnalyticsEventCategoryAppLifecycle = @"App Lifecycle";
NSString * const kVAnalyticsEventCategoryUserAccount  = @"User Account";
NSString * const kVAnalyticsEventCategoryInteraction  = @"Interaction";
NSString * const kVAnalyticsEventCategoryVideo        = @"Video";
NSString * const kVAnalyticsEventCategoryCamera       = @"Camera";

@interface VAnalyticsRecorder ()

@property (nonatomic, strong) id<GAITracker> tracker;
@property (nonatomic)         BOOL           inBackground;

@end

@implementation VAnalyticsRecorder

+ (VAnalyticsRecorder *)sharedAnalyticsRecorder
{
    static VAnalyticsRecorder *sharedAnalyticsRecorder;
    static dispatch_once_t     onceToken;
    dispatch_once(&onceToken, ^(void)
    {
        sharedAnalyticsRecorder = [[VAnalyticsRecorder alloc] init];
    });
    return sharedAnalyticsRecorder;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [[GAI sharedInstance] setDispatchInterval:10.0];
#if DEBUG && EnableAnalyticsLogs
        [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
#warning Analytics logging is enabled. Please remember to disable it when you're done debugging.
#endif
        NSString *trackerID = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:kGAID];
        self.tracker = [[GAI sharedInstance] trackerWithTrackingId:trackerID];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startAnalytics
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)    name:UIApplicationDidBecomeActiveNotification    object:nil];
    [self sendEventWithCategory:kVAnalyticsEventCategoryAppLifecycle action:kVAnalyticsEventAppLaunch label:nil value:nil];
}

- (void)startAppView:(NSString *)screenName
{
    [self.tracker set:kGAIScreenName value:screenName];
    [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    CLSLog(@"AppView: %@", screenName);
}

- (void)finishAppView
{
    [self.tracker set:kGAIScreenName value:nil];
}

- (void)sendEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value
{
    GAIDictionaryBuilder *eventDictionary = [GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:value];
    [self.tracker send:[eventDictionary build]];
    
    NSString *labelLog = @"";
    if (label && ![label isEqualToString:@""])
    {
        labelLog = [NSString stringWithFormat:@" (%@)", label];
    }
    NSString *valueLog = @"";
    if (value)
    {
        valueLog = [NSString stringWithFormat:@" (%@)", value];
    }
    CLSLog(@"%@/%@%@%@", category, action, labelLog, valueLog);
}

#pragma mark - NSNotification handlers

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self sendEventWithCategory:kVAnalyticsEventCategoryAppLifecycle action:kVAnalyticsEventAppSuspend label:nil value:nil];
    [[GAI sharedInstance] dispatch];
    self.inBackground = YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (self.inBackground)
    {
        [self sendEventWithCategory:kVAnalyticsEventCategoryAppLifecycle action:kVAnalyticsEventAppResume label:nil value:nil];
        self.inBackground = NO;
    }
}

@end
