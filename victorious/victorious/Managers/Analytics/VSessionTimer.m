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

#define TEST_NEW_SESSION 0 // Set to '1' to start a new session by leaving the app for only 10 seconds.

NSTimeInterval kVFirstLaunch = DBL_MAX;
NSString * const VSessionTimerNewSessionShouldStart = @"VSessionTimerNewSessionShouldStart";

static NSString * const kSessionEndTimeDefaultsKey     = @"com.victorious.VSessionTimer.SessionEndTime";
static NSString * const kSessionEndTimePropertyListKey = @"date";
static NSString * const kSessionLengthPropertyListKey  = @"length";

#if TEST_NEW_SESSION
#warning New sessions will start after 10 seconds of background time
static NSTimeInterval const kMinimumTimeBetweenSessions = 10.0;
#else
static NSTimeInterval const kMinimumTimeBetweenSessions = 1800.0; // 30 minutes
#endif

@interface VSessionTimer ()

@property (nonatomic, strong)    NSMutableArray /* NSDictionary */ *previousSessions;
@property (nonatomic, readwrite) NSTimeInterval  previousBackgroundTime;
@property (nonatomic)            BOOL            transitioningFromBackgroundToForeground;
@property (nonatomic)            BOOL            coldLaunch;
@property (nonatomic, strong)    NSDate         *sessionStartTime;

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

+ (VSessionTimer *)sharedSessionTimer
{
    static VSessionTimer *sessionTimer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
    {
        sessionTimer = [[VSessionTimer alloc] init];
    });
    return sessionTimer;
}

- (void)start
{
    self.previousSessions = [[self loadPreviousSessionsFromDisk] mutableCopy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)  name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)     name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)    name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    self.transitioningFromBackgroundToForeground = YES;
    self.coldLaunch = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Session Lifecycle

- (void)sessionDidStart
{
    self.sessionStartTime = [NSDate date];
    
    NSDate *lastSessionEnd = [[NSUserDefaults standardUserDefaults] objectForKey:kSessionEndTimeDefaultsKey];
    if (lastSessionEnd)
    {
        self.previousBackgroundTime = -[lastSessionEnd timeIntervalSinceNow];
    }
    
    if (!self.coldLaunch && self.previousBackgroundTime >= kMinimumTimeBetweenSessions)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:VSessionTimerNewSessionShouldStart object:self];
    }
    self.coldLaunch = NO;
    
    if (self.previousSessions.count)
    {
        [self reportSessions];
    }
}

- (void)sessionDidEnd
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kSessionEndTimeDefaultsKey];
    NSTimeInterval sessionLength = -[self.sessionStartTime timeIntervalSinceNow];
    [self addSessionToReportingQueueWithLength:sessionLength];
    [self saveSessionsToDisk:self.previousSessions];
    [self reportSessions];
}

#pragma mark - Reporting

- (void)addSessionToReportingQueueWithLength:(NSTimeInterval)sessionLength
{
    NSDictionary *session = @{ kSessionEndTimePropertyListKey: [NSDate date],
                               kSessionLengthPropertyListKey:  @(sessionLength)
                            };
    [self.previousSessions addObject:session];
}

- (void)reportSessions
{
    __block RKManagedObjectRequestOperation *requestOperation = nil;
    UIBackgroundTaskIdentifier task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void)
    {
        [requestOperation cancel];
    }];
    
    NSArray *analyticsEvents = [self.previousSessions v_map:^id (NSDictionary *session)
    {
        return [[VObjectManager sharedManager] dictionaryForSessionEventWithDate:session[kSessionEndTimePropertyListKey] length:[session[kSessionLengthPropertyListKey] doubleValue]];
    }];
    
    requestOperation = [[VObjectManager sharedManager] addEvents:analyticsEvents
                                                    successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
    {
        [self.previousSessions removeAllObjects];
        [[NSFileManager defaultManager] removeItemAtURL:[self previousSessionSaveLocation] error:nil];
        [[UIApplication sharedApplication] endBackgroundTask:task];
    }
                                                       failBlock:^(NSOperation *operation, NSError *error)
    {
        NSLog(@"Error posting session events to the server: %@", [error localizedDescription]);
        [[UIApplication sharedApplication] endBackgroundTask:task];
    }];
}

- (NSArray *)loadPreviousSessionsFromDisk
{
    NSData *previousSessionData = [NSData dataWithContentsOfURL:[self previousSessionSaveLocation]];
    if (previousSessionData)
    {
        return [NSPropertyListSerialization propertyListWithData:previousSessionData
                                                         options:0
                                                          format:NULL
                                                           error:nil];
    }
    return @[];
}

- (void)saveSessionsToDisk:(NSArray *)sessions
{
    NSData *sessionsData = [NSPropertyListSerialization dataWithPropertyList:sessions
                                                                      format:NSPropertyListXMLFormat_v1_0
                                                                     options:0
                                                                       error:nil];
    [sessionsData writeToURL:[self previousSessionSaveLocation] atomically:NO];
}

- (NSURL *)previousSessionSaveLocation
{
    NSArray *searchResults = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    if (searchResults.count)
    {
        NSURL *documentsDirectory = searchResults[0];
        return [documentsDirectory URLByAppendingPathComponent:@"sessions"];
    }
    return nil;
}

#pragma mark - NSNotification handlers

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
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
