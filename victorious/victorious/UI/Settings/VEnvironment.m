//
//  VEnvironment.m
//  victorious
//
//  Created by Josh Hinman on 5/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEnvironment.h"

static NSString * const kNameKey = @"name";
static NSString * const kAppIDKey = @"appID";
static NSString * const kBaseURLKey = @"baseURL";

@implementation VEnvironment

- (instancetype)initWithName:(NSString *)name baseURL:(NSURL *)baseURL appID:(NSNumber *)appID
{
    self = [super init];
    if ( self != nil )
    {
        _name = [name copy];
        _baseURL = [baseURL copy];
        _appID = appID;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    NSString *name = dictionary[kNameKey];
    NSNumber *appID = dictionary[kAppIDKey];
    NSString *baseURL = dictionary[kBaseURLKey];
    
    if ( ![name isKindOfClass:[NSString class]] ||
         ![appID isKindOfClass:[NSNumber class]] ||
         ![baseURL isKindOfClass:[NSString class]] )
    {
        return nil;
    }
    return [self initWithName:name baseURL:[NSURL URLWithString:baseURL] appID:appID];
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
