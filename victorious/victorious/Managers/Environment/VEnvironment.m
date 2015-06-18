//
//  VEnvironment.m
//  victorious
//
//  Created by Josh Hinman on 5/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEnvironment.h"

NSString * const kNameKey = @"name";
NSString * const kAppIDKey = @"appID";
NSString * const kBaseURLKey = @"baseURL";
NSString * const kUserKey = @"isUser";

NSString * const VEnvironmentErrorKey = @"com.victorious.VEnvironment.ErrorKey";

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
    NSString *name = dictionary[ kNameKey ];
    NSNumber *appID = dictionary[ kAppIDKey ];
    NSString *baseURL = dictionary[ kBaseURLKey ];
    
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
    NSString *name = [coder decodeObjectForKey:kNameKey];
    NSNumber *appID = [coder decodeObjectForKey:kAppIDKey ];
    NSURL *baseURL = [coder decodeObjectForKey:kBaseURLKey ];
    NSNumber *isUserEnvironment = [coder decodeObjectForKey:kUserKey];
    
    if ( name == nil || appID == nil || baseURL == nil )
    {
        return nil;
    }
    typeof(self) instance = [self initWithName:name baseURL:baseURL appID:appID];
    instance.isUserEnvironment = isUserEnvironment.boolValue;
    return instance;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:kNameKey ];
    [aCoder encodeObject:self.appID forKey:kAppIDKey ];
    [aCoder encodeObject:self.baseURL forKey:kBaseURLKey ];
    [aCoder encodeObject:@(self.isUserEnvironment) forKey:kUserKey ];
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