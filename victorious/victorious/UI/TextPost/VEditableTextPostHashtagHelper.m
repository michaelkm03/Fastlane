//
//  VEditableTextPostHashtagHelper.m
//  victorious
//
//  Created by Patrick Lynch on 3/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEditableTextPostHashtagHelper.h"
#import "VHashTags.h"
#import "NSArray+VMap.h"

@interface VEditableTextPostHashtagHelper()

@property (nonatomic, strong, readwrite) NSArray *removed;
@property (nonatomic, strong, readwrite) NSArray *added;

@end

@implementation VEditableTextPostHashtagHelper

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _embeddedHashtags = [[NSMutableSet alloc] init];
    }
    return self;
}

- (BOOL)addHashtag:(NSString *)hashtag
{
    [self.embeddedHashtags addObject:hashtag];
    return YES;
}

- (BOOL)removeHashtag:(NSString *)hashtag
{
    if ( [self.embeddedHashtags containsObject:hashtag] )
    {
        [self.embeddedHashtags removeObject:hashtag];
        return YES;
    }
    return NO;
}

- (void)setHashtagModificationsWithBeforeText:(NSString *)beforeText afterText:(NSString *)afterText
{
    NSArray *hashtagsBefore = [VHashTags getHashTags:beforeText includeHashMark:YES];
    NSArray *hashtagsAfter = [VHashTags getHashTags:afterText includeHashMark:YES];
    
    NSString *(^removeHashmarkBlock)(NSString *) = ^NSString *(NSString *string)
    {
        return [string stringByReplacingOccurrencesOfString:@"#" withString:@""];
    };
    
    NSPredicate *addedFilter = [NSPredicate predicateWithBlock:^BOOL(NSString *hashtag, NSDictionary *bindings)
                                {
                                    hashtag = [hashtag stringByReplacingOccurrencesOfString:@"#" withString:@""];
                                    return ![hashtagsBefore containsObject:hashtag];
                                }];
    self.added = [[hashtagsAfter filteredArrayUsingPredicate:addedFilter] v_map:removeHashmarkBlock];
    
    NSPredicate *removedFilter = [NSPredicate predicateWithBlock:^BOOL(NSString *hashtag, NSDictionary *bindings)
                                  {
                                      return ![hashtagsAfter containsObject:hashtag];
                                  }];
    self.removed = [[hashtagsBefore filteredArrayUsingPredicate:removedFilter] v_map:removeHashmarkBlock];
}

- (void)resetCachedModifications
{
    self.added = nil;
    self.removed = nil;
}

@end
