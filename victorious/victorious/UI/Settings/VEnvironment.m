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

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder
{
    NSString *name = [coder decodeObjectForKey:VNameKey];
    NSNumber *appID = [coder decodeObjectForKey:VAppIDKey ];
    NSURL *baseURL = [coder decodeObjectForKey:VBaseURLKey ];
    
    if ( name == nil || appID == nil || baseURL == nil )
    {
        return nil;
    }
    return [self initWithName:name baseURL:baseURL appID:appID];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:VNameKey ];
    [aCoder encodeObject:self.appID forKey:VAppIDKey ];
    [aCoder encodeObject:self.baseURL forKey:VBaseURLKey ];
}

#pragma mark - NSObject overrides

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
