//
//  VEnvironment.m
//  victorious
//
//  Created by Josh Hinman on 5/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEnvironment.h"

@implementation VEnvironment

- (instancetype)initWithName:(NSString *)name baseURL:(NSURL *)baseURL appID:(NSNumber *)appID
{
    self = [super init];
    if (self)
    {
        _name = [name copy];
        _baseURL = baseURL;
        _appID = appID;
    }
    return self;
}

- (BOOL)isEqual:(VEnvironment *)object
{
    if (![object isKindOfClass:[VEnvironment class]])
    {
        return NO;
    }
    
    return [self.name isEqualToString:object.name];
}

- (NSUInteger)hash
{
    return self.name.hash;
}

@end
