//
//  VEnvironment.m
//  victorious
//
//  Created by Josh Hinman on 5/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

NSString * const kNameKey = @"name";
NSString * const kAppIDKey = @"appID";
NSString * const kBaseURLKey = @"baseURL";
NSString * const kUserKey = @"isUser";

NSString * const VEnvironmentDidFailToLoad = @"VEnvironmentDidFailToLoad";

@implementation VEnvironment

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

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

+ (NSArray *__nullable)environmentsFromPlist:(NSURL *)plistFile
{
    NSInputStream *fileStream = [[NSInputStream alloc] initWithURL:plistFile];
    [fileStream open];
    NSArray *environmentsPlist = [NSPropertyListSerialization propertyListWithStream:fileStream options:0 format:nil error:nil];
    [fileStream close];
    
    if ( environmentsPlist == nil )
    {
        return nil;
    }
    
    NSMutableArray *environments = [[NSMutableArray alloc] initWithCapacity:environmentsPlist.count];
    for ( NSDictionary *environmentDictionary in environmentsPlist )
    {
        if ( [environmentDictionary isKindOfClass:[NSDictionary class]] )
        {
            VEnvironment *environment = [[VEnvironment alloc] initWithDictionary:environmentDictionary];
            if ( environment != nil )
            {
                [environments addObject:environment];
            }
        }
    }
    return environments;
}

#pragma mark - NSCoding

- (nullable instancetype)initWithCoder:(NSCoder *)coder
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

NS_ASSUME_NONNULL_END
