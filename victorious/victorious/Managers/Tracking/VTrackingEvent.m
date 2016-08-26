//
//  VTrackingEvent.m
//  victorious
//
//  Created by Patrick Lynch on 10/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrackingEvent.h"

@implementation VTrackingEvent

- (instancetype)initWithName:(NSString *)name parameters:(NSDictionary *)parameters eventId:(NSString *)eventId
{
    self = [super init];
    if (self)
    {
        _eventId = eventId;
        _parameters = parameters;
        _name = name;
        _dateCreated = [NSDate date];
    }
    return self;
}

@end
