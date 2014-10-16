//
//  VObjectManager+Analytics.m
//  victorious
//
//  Created by Josh Hinman on 7/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSArray+VMap.h"
#import "VObjectManager+Analytics.h"
#import "VObjectManager+Private.h"
#import "VSequence.h"

static NSString * const kEventKey     = @"event";
static NSString * const kCreatedAtKey = @"created_at";
static NSString * const kLengthKey    = @"length";
static NSString * const kSequenceKey  = @"sequence";

@implementation VObjectManager (Analytics)

+ (NSDateFormatter *)analyticsDateFormatter
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });
    return dateFormatter;
}

- (NSDictionary *)dictionaryForInstallEventWithDate:(NSDate *)date
{
    return @{ kEventKey: @"install",
              kCreatedAtKey: [[VObjectManager analyticsDateFormatter] stringFromDate:date],
            };
}

- (NSDictionary *)dictionaryForSessionEventWithDate:(NSDate *)date length:(NSTimeInterval)length
{
    return @{ kEventKey: @"session",
              kCreatedAtKey: [[VObjectManager analyticsDateFormatter] stringFromDate:date],
              kLengthKey: @(ceil(length)),
            };
}

- (NSDictionary *)dictionaryForSequenceViewWithDate:(NSDate *)date length:(NSTimeInterval)length sequence:(VSequence *)sequence
{
    return @{ kEventKey: @"view",
              kCreatedAtKey: [[VObjectManager analyticsDateFormatter] stringFromDate:date],
              kLengthKey: @(ceil(length)),
              kSequenceKey: @{ @"sequence_id": sequence.remoteId,
                               @"category": sequence.category,
                               @"created_by": sequence.createdBy,
                            },
            };
}

- (RKManagedObjectRequestOperation *)addEvents:(NSArray *)events successBlock:(VSuccessBlock)success failBlock:(VFailBlock)fail
{
    NSArray *jsonObjects = [events v_map:^id(NSDictionary *eventDictionary)
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:eventDictionary options:0 error:nil];
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }];
    
    return [self POST:@"/api/event/add"
               object:nil
           parameters:@{@"events": jsonObjects}
         successBlock:success
            failBlock:fail];
}

- (BOOL)trackEventWithUrl:(NSString *)url
{
    return [self trackEventWithUrl:url andValues:nil];
}

- (BOOL)trackEventWithUrl:(NSString *)url andValues:(NSDictionary *)values
{
    BOOL isParameterValid = url != nil && [url isKindOfClass:[NSString class]] && url.length > 0;
    if ( !isParameterValid )
    {
        return NO;
    }
    
    __block NSString *formattedUrl = [url copy];
    
    if ( values != nil && values.allKeys.count > 0 )
    {
        [values enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
            
            formattedUrl = [self urlStringFromUrlString:formattedUrl byReplacingMacro:key withValue:value];
            if ( formattedUrl == nil )
            {
                *stop = YES;
            }
        }];
    }
    
    if ( formattedUrl == nil )
    {
        return NO;
    }
    
    VLog( @"Track event with URL: %@", formattedUrl );
    
    return YES;
}

- (NSString *)urlStringFromUrlString:(NSString *)urlString byReplacingMacro:(NSString *)macro withValue:(id)value
{
    if ( urlString == nil || ![urlString isKindOfClass:[NSString class]] || urlString.length == 0 )
    {
        return nil;
    }
    if ( macro == nil || ![macro isKindOfClass:[NSString class]] || macro.length == 0 )
    {
        return urlString;
    }
    
    NSString *formattedValue = nil;
    
    if ( [value isKindOfClass:[NSDate class]] )
    {
        formattedValue = [[VObjectManager analyticsDateFormatter] stringFromDate:(NSDate *)value];
    }
    else if ( [value isKindOfClass:[NSNumber class]] )
    {
        formattedValue = [NSString stringWithFormat:@"%@", (NSNumber *)value];
    }
    else if ( [value isKindOfClass:[NSString class]] )
    {
        formattedValue = value;
    }
    
    BOOL isValueValue = formattedValue != nil && formattedValue.length > 0 && [formattedValue isKindOfClass:[NSString class]];

    if ( !isValueValue )
    {
        return nil;
    }
    
    return [urlString stringByReplacingOccurrencesOfString:macro withString:formattedValue];
}

@end
