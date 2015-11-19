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

static const NSTimeInterval kFlagHideTimeInterval = 2592000.0f; //30 days (60 * 60 * 24 * 30)

@implementation VFlaggedContent

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
        if ( expirationDate.timeIntervalSinceNow < -kFlagHideTimeInterval )
        {
            needsUpdate = YES;
            [validFlaggedContents removeObjectForKey:remoteId];
        }
    }
    if ( needsUpdate )
    {
        [[NSUserDefaults standardUserDefaults] setObject:validFlaggedContents forKey:[self flagArrayKeyForType:type]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSArray *)commentsAfterStrippingFlaggedItems:(NSArray *)comments
{
    NSArray *flaggedCommentIds = [self flaggedContentIdsWithType:VFlaggedContentTypeComment];
    NSMutableArray *safeComments = [comments mutableCopy];
    for ( VComment *comment in comments )
    {
        if ( [flaggedCommentIds containsObject:comment.remoteId.stringValue] )
        {
            [safeComments removeObject:comment];
        }
    }
    return safeComments;
}

- (NSArray *)streamItemsAfterStrippingFlaggedItems:(NSArray *)streamItems
{
    NSArray *flaggedStreamItemIds = [self flaggedContentIdsWithType:VFlaggedContentTypeStreamItem];
    NSMutableArray *safeStreamItems = [streamItems mutableCopy];
    for ( VStreamItem *streamItem in streamItems )
    {
        if ( [flaggedStreamItemIds containsObject:streamItem.remoteId] )
        {
            [safeStreamItems removeObject:streamItem];
        }
    }
    return safeStreamItems;
}

- (void)addRemoteId:(NSString *)remoteId toFlaggedItemsWithType:(VFlaggedContentType)type
{
    if ( remoteId == nil )
    {
        return;
    }
    NSMutableDictionary *contents = [[self flaggedContentDictionaryWithType:type] mutableCopy];
    [contents setObject:[NSDate date] forKey:remoteId];
    [[NSUserDefaults standardUserDefaults] setObject:contents forKey:[self flagArrayKeyForType:type]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)flaggedContentIdsWithType:(VFlaggedContentType)type
{
    return [self flaggedContentDictionaryWithType:type].allKeys;
}

- (NSDictionary *)flaggedContentDictionaryWithType:(VFlaggedContentType)type
{
    NSString *key = [self flagArrayKeyForType:type];
    NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if ( dictionary == nil )
    {
        dictionary = @{};
        [[NSUserDefaults standardUserDefaults] setObject:dictionary forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
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
    }
}

@end
