//
//  VFlaggedContent.m
//  victorious
//
//  Created by Sharif Ahmed on 9/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VComment.h"
#import "VConversation.h"
#import "VStreamItem.h"
#import "VFlaggedContent.h"

@interface VFlaggedContent()

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

const NSTimeInterval VDefaultRefreshTimeInterval = 2592000.0f; //30 days (60 * 60 * 24 * 30)

@implementation VFlaggedContent

- (instancetype)init
{
    return [self initWithDefaults:[NSUserDefaults standardUserDefaults]
              refreshTimeInterval:VDefaultRefreshTimeInterval];
}

- (instancetype)initWithDefaults:(NSUserDefaults *)defaults
{
    return [self initWithDefaults:defaults refreshTimeInterval:VDefaultRefreshTimeInterval];
}

- (instancetype)initWithDefaults:(NSUserDefaults *)defaults refreshTimeInterval:(NSTimeInterval)timeInterval
{
    self = [super init];
    if (self)
    {
        _userDefaults = defaults;
        _refreshTimeInterval = timeInterval;
    }
    return self;
}

- (void)refreshFlaggedContents
{
    [self removeOutdatedItemsForFlaggedContentsWithType:VFlaggedContentTypeStreamItem];
    [self removeOutdatedItemsForFlaggedContentsWithType:VFlaggedContentTypeComment];
}

- (void)removeOutdatedItemsForFlaggedContentsWithType:(VFlaggedContentType)type
{
    NSDictionary *flaggedContents = [self flaggedContentDictionaryWithType:type];
    NSMutableDictionary *validFlaggedContents = [flaggedContents mutableCopy];
    NSArray *remoteIds = flaggedContents.allKeys;
    BOOL needsUpdate = NO;
    for ( NSString *remoteId in remoteIds )
    {
        NSDate *expirationDate = [flaggedContents objectForKey:remoteId];
        if ( expirationDate.timeIntervalSinceNow < -self.refreshTimeInterval )
        {
            needsUpdate = YES;
            [validFlaggedContents removeObjectForKey:remoteId];
        }
    }
    if ( needsUpdate )
    {
        [self.userDefaults setObject:validFlaggedContents forKey:[self flagArrayKeyForType:type]];
        [self.userDefaults synchronize];
    }
}

- (void)addRemoteId:(NSString *)remoteId toFlaggedItemsWithType:(VFlaggedContentType)type
{
    if ( remoteId == nil )
    {
        return;
    }
    NSMutableDictionary *contents = [[self flaggedContentDictionaryWithType:type] mutableCopy];
    [contents setObject:[NSDate date] forKey:remoteId];
    [self.userDefaults setObject:contents forKey:[self flagArrayKeyForType:type]];
    [self.userDefaults synchronize];
}

- (NSArray<NSString *> *)flaggedContentIdsWithType:(VFlaggedContentType)type
{
    return [self flaggedContentDictionaryWithType:type].allKeys;
}

- (NSDictionary *)flaggedContentDictionaryWithType:(VFlaggedContentType)type
{
    NSString *key = [self flagArrayKeyForType:type];
    NSDictionary *dictionary = [self.userDefaults objectForKey:key];
    if ( dictionary == nil )
    {
        dictionary = @{};
        [self.userDefaults setObject:dictionary forKey:key];
        [self.userDefaults synchronize];
    }
    return dictionary;
}

- (NSString *)flagArrayKeyForType:(VFlaggedContentType)type
{
    switch (type)
    {
        case VFlaggedContentTypeComment:
            return @"flaggedComments";
        case VFlaggedContentTypeStreamItem:
            return @"flaggedStreamItems";
        case VFlaggedContentTypeContent:
            return @"flaggedContent";
    }
}

@end
