//
//  VFlurryTracking.m
//  victorious
//
//  Created by Patrick Lynch on 10/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFlurryTracking.h"
#import "Flurry.h"

#define FLURRY_TRACKING_LOGGING_ENABLED 0

#if DEBUG && FLURRY_TRACKING_LOGGING_ENABLED
#warning Tracking logging is enabled. Please remember to disable it when you're done debugging.
#endif

@interface VFlurryTracking()

@property (nonatomic, readonly) NSString *appVersionString;
@property (nonatomic, readonly) NSString *apiKey;

@end

@implementation VFlurryTracking

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSString *apiKey = self.apiKey;
        if ( apiKey != nil )
        {
            NSString *appVersion = self.appVersionString;
            if ( appVersion != nil )
            {
                // Call this before startSession:
                [Flurry setAppVersion:appVersion];
            };
            
            [Flurry startSession:apiKey];
            _enabled = YES;
        }
    }
    return self;
}

- (NSString *)appVersionString
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *buildNumber = [infoDictionary objectForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@ (%@)", appVersion, buildNumber];
}

- (NSString *)apiKey
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"FlurryAPIKey"];
}

- (NSDictionary *)filteredDictionaryExcludingKeys:(NSArray *)keysToExclude fromDictionary:(NSDictionary *)dictionary
{
    if ( keysToExclude == nil || dictionary == nil || keysToExclude.count == 0 || dictionary.count == 0 )
    {
        return dictionary;
    }
    
    // Only include keys not contained in keysToExclude and that are not empty strings
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *key, NSDictionary *bindings)
                              {
                                  BOOL shoudBeExcluded = [keysToExclude containsObject:key];
                                  BOOL isEmptyString = [dictionary[ key ] isKindOfClass:[NSString class]] && [dictionary[ key ] isEqualToString:@""];
                                  return !shoudBeExcluded && !isEmptyString;
                              }];
    NSArray *filteredParameterKeys = [[dictionary allKeys] filteredArrayUsingPredicate:predicate];
    return[dictionary dictionaryWithValuesForKeys:filteredParameterKeys];
}

#pragma mark - VTrackingDelegate protocol

- (void)trackEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    if ( !self.enabled )
    {
        return;
    }
    
    // Because Flurry only allows up to 10 parameters, this allows us to filter out ones
    // that we don't care about to ensure that others get used
    NSDictionary *filteredParameters = [self filteredDictionaryExcludingKeys:self.unwantedParameterKeys fromDictionary:parameters];
    [Flurry logEvent:eventName withParameters:filteredParameters];
    
#if DEBUG && FLURRY_TRACKING_LOGGING_ENABLED
    NSString *params = @"";
    for ( NSString *key in filteredParameters )
    {
        params = [params stringByAppendingFormat:@"\n\t%@: %@", key, filteredParameters[key]];
    }
    NSLog( @":: ******* Flurry Tracking ******** :: \n%@%@", eventName, params );
#endif
}

@end
