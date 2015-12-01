//
//  VUser+Fetcher.m
//  victorious
//
//  Created by Michael Sena on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUser+Fetcher.h"
#import "VHashtag.h"
#import "VHashtag+RestKit.h"
#import "VObjectManager.h"

@implementation VUser (Fetcher)

- (BOOL)isFollowingHashtagString:(NSString *)hashtag
{
    for (VHashtag *tag in self.hashtags)
    {
        if ([tag.tag isEqualToString:hashtag])
        {
            return YES;
        }
    }
    return NO;
}

- (void)addFollowedHashtag:(NSString *)hashtag
{
    if ([self isFollowingHashtagString:hashtag])
    {
        return;
    }
    
    // Create a new VHashtag object and assign it to the currently logged in user.
    VHashtag *newTag = [[VObjectManager sharedManager] objectWithEntityName:[VHashtag entityName]
                                                                   subclass:[VHashtag class]];
    newTag.tag = hashtag;
    
    NSMutableOrderedSet *hashtagSet = [self.hashtags mutableCopy] ?: [[NSMutableOrderedSet alloc] init];
    [hashtagSet addObject:newTag];
    
    if ( [self shouldUpdateUserForHashtags:hashtagSet] )
    {
        self.hashtags = [NSOrderedSet orderedSetWithOrderedSet:hashtagSet];
        [self.managedObjectContext saveToPersistentStore:nil];
    }
}

- (BOOL)shouldUpdateUserForHashtags:(NSOrderedSet *)hashtags
{
    NSOrderedSet *userHashtags = self.hashtags;
    if ( userHashtags.count == hashtags.count )
    {
        //We have the same count of hashtags, check each hashtag inside to make sure we have the same hashtags
        __block BOOL needsUpdate = NO;
        [userHashtags enumerateObjectsUsingBlock:^(VHashtag *followedHashtag, NSUInteger idx, BOOL *stop)
         {
             NSInteger foundIndex = [hashtags indexOfObjectPassingTest:^BOOL(VHashtag *hashtag, NSUInteger idx, BOOL *innerStop)
                                     {
                                         BOOL found = [hashtag.tag isEqualToString:followedHashtag.tag];
                                         if ( found )
                                         {
                                             *innerStop = YES;
                                         }
                                         return found;
                                     }];
             if ( foundIndex == NSNotFound )
             {
                 //Found a discrepancy, need to update
                 needsUpdate = YES;
                 *stop = YES;
             }
         }];
        return needsUpdate;
    }
    //Different count of hashtags, need to update
    return YES;
}

- (Float64)maxUploadDurationFloat
{
    return self.maxUploadDuration.floatValue;
}

@end
