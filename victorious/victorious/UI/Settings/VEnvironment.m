//
//  VEnvironment.m
//  victorious
//
//  Created by Josh Hinman on 5/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEnvironment.h"

NSString * const VNameKey = @"name";
NSString * const VAppIDKey = @"appID";
NSString * const VBaseURLKey = @"baseURL";

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
    NSString *name = dictionary[ VNameKey ];
    NSNumber *appID = dictionary[ VAppIDKey ];
    NSString *baseURL = dictionary[ VBaseURLKey ];
    
    if ( ![name isKindOfClass:[NSString class]] ||
         ![appID isKindOfClass:[NSNumber class]] ||
         ![baseURL isKindOfClass:[NSString class]] )
    {
        return nil;
    }
    return [self initWithName:name baseURL:[NSURL URLWithString:baseURL] appID:appID];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
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
