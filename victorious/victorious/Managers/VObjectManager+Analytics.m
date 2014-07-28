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
        dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
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

@end
