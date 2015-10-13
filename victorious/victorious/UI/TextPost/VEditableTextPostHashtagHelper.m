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

@property (nonatomic, strong, readwrite) NSArray *collectedHashtagsRemoved;
@property (nonatomic, strong, readwrite) NSArray *collectedHashtagsAdded;

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

- (void)collectHashtagEditsFromBeforeText:(NSString *)beforeText toAfterText:(NSString *)afterText
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
    self.collectedHashtagsAdded = [[hashtagsAfter filteredArrayUsingPredicate:addedFilter] v_map:removeHashmarkBlock];
    
    NSPredicate *removedFilter = [NSPredicate predicateWithBlock:^BOOL(NSString *hashtag, NSDictionary *bindings)
                                  {
                                      return ![hashtagsAfter containsObject:hashtag];
                                  }];
    self.collectedHashtagsRemoved = [[hashtagsBefore filteredArrayUsingPredicate:removedFilter] v_map:removeHashmarkBlock];
}

- (void)resetCollectedHashtagEdits
{
    self.collectedHashtagsAdded = nil;
    self.collectedHashtagsRemoved = nil;
}

#pragma mark - Utilities

- (NSRange)rangeOfHashtag:(NSString *)hashtag inString:(NSString *)string
{
    NSUInteger length = [string length];
    NSRange range = NSMakeRange(0, length);
    
    // Iterate through all matching ranges to find correct range
    while (range.location != NSNotFound)
    {
        // Find range of substring
        range = [string rangeOfString:hashtag options:0 range:range];
        if (range.location != NSNotFound)
        {
            // If we found a match, check if there are more characters in this string
            if (string.length > range.location + range.length)
            {
                // If there is, check the character next to our hashtag to make sure this is not part of a larger hashtag
                NSString *nextChar = [string substringWithRange:NSMakeRange(range.location + range.length, 1)];
                if ([nextChar isEqualToString:@"#"] || [nextChar isEqualToString:@" "])
                {
                    return range;
                }
            }
            // If not, this hashtag is the entire string
            else
            {
                return range;
            }
            // We found a match but it was part of a bigger hashtag, move onto the next range
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
        }
    }
    
    return NSMakeRange(NSNotFound, NSNotFound);
}

@end
