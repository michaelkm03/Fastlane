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

- (instancetype)initWithName:(NSString *)name parameters:(NSDictionary *)parameters key:(id)key
{
    self = [super init];
    if (self)
    {
        _key = key;
        _parameters = parameters;
        _name = name;
    }
    return self;
}

@end
