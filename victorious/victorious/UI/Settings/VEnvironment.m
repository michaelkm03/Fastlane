//
//  VEnvironment.m
//  victorious
//
//  Created by Josh Hinman on 5/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEnvironment.h"

#import "VConstants.h"

@implementation VEnvironment

- (instancetype)initWithName:(NSString *)name baseURL:(NSURL *)baseURL appID:(NSNumber *)appID
{
    self = [super init];
    if (self)
    {
        _name = [name copy];
        _baseURL = baseURL;

        //If the app ID is less 1 its invalid.  Use the dev app ID so they can log in and try to change servers.
        _appID = appID.integerValue < 1 ? @(kDevAppID) : appID;
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
