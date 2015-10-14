//
//  VCrashlyticsLogTracking.m
//  victorious
//
//  Created by Michael Sena on 10/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>

#import "VCrashlyticsLogTracking.h"
#import "NSString+VParseHelp.h"

static NSString * const kVAnalyticsEventAppLaunch  = @"Cold Launch";
static NSString * const kVAnalyticsEventAppSuspend = @"Suspend";
static NSString * const kVAnalyticsEventAppResume  = @"Resume";

static NSString * const kVAnalyticsEventCategoryNavigation   = @"Navigation";
static NSString * const kVAnalyticsEventCategoryAppLifecycle = @"App Lifecycle";
static NSString * const kVAnalyticsEventCategoryUserAccount  = @"User Account";
static NSString * const kVAnalyticsEventCategoryInteraction  = @"Interaction";
static NSString * const kVAnalyticsEventCategoryVideo        = @"Video";
static NSString * const kVAnalyticsEventCategoryCamera       = @"Camera";

static NSString * const kVAnalyticsKeyCategory         = @"category";
static NSString * const kVAnalyticsKeyAction           = @"action";
static NSString * const kVAnalyticsKeyLabel            = @"label";
static NSString * const kVAnalyticsKeyValue            = @"value";

@implementation VCrashlyticsLogTracking

- (void)trackEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    if ( eventName == nil || eventName.length == 0 )
    {
        return;
    }
    

    NSMutableArray *trackingLogComponents = [[NSMutableArray alloc] init];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop)
    {
        NSString *stringForParam = nil;
        if ([key isEqualToString:VTrackingKeyUserLoggedIn])
        {
            NSNumber *loggedInNumber = (NSNumber *)obj;
            stringForParam = [NSString stringWithFormat:@"Logged in: %@", [loggedInNumber boolValue] ? @"true" : @"false"];

        }
        else if ([key isEqualToString:VTrackingKeyUrls])
        {
            NSArray *trackingURLS = (NSArray *)obj;
            NSMutableArray *trackingURLPaths = [[NSMutableArray alloc] init];
            for (NSString *trackingURL in trackingURLS)
            {
                [trackingURLPaths addObject:[trackingURL v_pathComponent]];
            }

            stringForParam = [NSString stringWithFormat:@"TrackingURLPaths: [%@] ", [trackingURLPaths componentsJoinedByString:@", "]];
        }
        else
        {
            stringForParam = [NSString stringWithFormat:@"%@ : %@", [key description], [obj description]];
        }
        [trackingLogComponents addObject:stringForParam];
    }];
    
    /**
     This lines up tracking logs like this:
     Prompt
         Event Name
             EventParam: ParamValue
             EventParam: ParamValue
     */
    NSString *trackingLog = [NSString stringWithFormat:@"\n\t%@\n\t\t%@", eventName, [trackingLogComponents componentsJoinedByString:@"\n\t\t"]];
    NSLog(@"%@", trackingLog);
    CLSLog(@"%@", trackingLog);
}

@end
