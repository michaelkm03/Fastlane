//
//  VTrackingEventLog.m
//  victorious
//
//  Created by Patrick Lynch on 3/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTrackingEventLog.h"

static NSString * const kLogFileName = @"tracking-log.plist";

NSString * const VTrackingEventLogKeyEventName = @"eventName";
NSString * const VTrackingEventLogKeyDate = @"date";

@interface VTrackingEventLog()

@property (nonatomic, strong) NSMutableArray *mutableEvents;
@property (nonatomic, readonly) NSString *filepath;

@end

@implementation VTrackingEventLog

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _mutableEvents = [[NSMutableArray alloc] initWithContentsOfFile:self.filepath] ?: [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)events
{
    return [NSArray arrayWithArray:self.mutableEvents];
}

- (void)logEvent:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    NSMutableDictionary *logData = [[NSMutableDictionary alloc] init];
    logData[ VTrackingEventLogKeyEventName ] = eventName ?: @"";
    for ( id key in parameters.allKeys )
    {
        logData[ key ] = parameters[ key ];
    }
    logData[ VTrackingEventLogKeyDate ] = [NSDate date];
    [self.mutableEvents addObject:[NSDictionary dictionaryWithDictionary:logData]];
    [self.mutableEvents writeToFile:self.filepath atomically:YES];
}

- (void)clearEvents
{
    self.mutableEvents = [[NSMutableArray alloc] init];
    [self.mutableEvents writeToFile:self.filepath atomically:YES];
}

- (NSString *)filepath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    return [paths.firstObject stringByAppendingPathComponent:kLogFileName];
}

@end
