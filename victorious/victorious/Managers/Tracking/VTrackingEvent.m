//
//  VTrackingEvent.m
//  victorious
//
//  Created by Patrick Lynch on 10/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrackingEvent.h"

@interface VTrackingEvent ()

@property (nonatomic, readwrite) NSArray *urls;

@end

@implementation VTrackingEvent

- (instancetype)initWithName:(NSString *)name parameters:(NSDictionary *)parameters eventId:(id)eventId
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

- (void)minimize
{
    _parameters = nil;
    _name = nil;
}

@end
