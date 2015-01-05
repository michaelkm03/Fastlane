//
//  VHashtagManager.m
//  victorious
//
//  Created by Lawrence Leach on 1/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHashtagManager.h"
#import "VObjectManager+Discover.h"
#import "VHashtag.h"
#import "VConstants.h"

@implementation VHashtagManager

+ (instancetype)sharedManager
{
    static  VHashtagManager  *sharedManager;
    static  dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,
                  ^{
                      sharedManager = [[VHashtagManager alloc] init];
                  });
    
    return sharedManager;
}

- (NSArray *)detectHashTags:(NSString *)fieldText
{
    if (!fieldText)
    {
        return nil;
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)"
                                                                           options:0
                                                                             error:nil];
    NSArray *tags = [regex matchesInString:fieldText
                                   options:0
                                     range:NSMakeRange(0, fieldText.length)];
    
    for (NSTextCheckingResult *tag in tags)
    {
        NSRange wordRange = [tag rangeAtIndex:1];
        [array addObject:[NSValue valueWithRange:wordRange]];
    }
    
    return [NSArray arrayWithArray:array];
}

- (BOOL)formatHashTagsInString:(NSMutableAttributedString *)fieldText
                 withTagRanges:(NSArray *)tagRanges
                    attributes:(NSDictionary *)attributes
{
    // Error checking
    if ( fieldText == nil || tagRanges == nil || attributes == nil )
    {
        return NO;
    }
    
    // Optimizaitons
    if ( fieldText.length == 0 || tagRanges.count == 0 || attributes.allKeys.count == 0 )
    {
        return NO;
    }
    
    [tagRanges enumerateObjectsUsingBlock:^(NSValue *tagRangeValue, NSUInteger idx, BOOL *stop)
     {
         NSRange tagRange = [tagRangeValue rangeValue];
         if (tagRange.location && tagRange.length < fieldText.length)
         {
             NSRange tagRangeWithHash = {tagRange.location - 1, tagRange.length + 1};
             [fieldText addAttributes:attributes range:tagRangeWithHash];
         }
     }];
    
    return YES;
}

- (NSString *)stringWithPrependedHashmarkFromString:(NSString *)string
{
    // Check invalid input
    if ( string == nil || string.length == 0 )
    {
        return nil;
    }
    
    // No spaces allowed
    if ( [string rangeOfString:@" "].location != NSNotFound )
    {
        return nil;
    }
    
    // No dashes allowed
    if ( [string rangeOfString:@"-"].location != NSNotFound )
    {
        return nil;
    }
    
    NSRange rangeOfHashmark = [string rangeOfString:@"#"];
    if ( rangeOfHashmark.location != 0 || rangeOfHashmark.length != 1 )
    {
        return [NSString stringWithFormat:@"#%@", string];
    }
    else
    {
        return [string copy];
    }
}

- (NSArray *)getHashTags:(NSString *)fieldText includeHashMark:(BOOL)includeHashMark
{
    NSMutableArray *container = [[NSMutableArray alloc] init];
    NSArray *ranges = [self detectHashTags:fieldText];
    [ranges enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger idx, BOOL *stop)
     {
         NSString *hashtag = [fieldText substringWithRange:[value rangeValue]];
         if ( includeHashMark )
         {
             hashtag = [NSString stringWithFormat:@"#%@", hashtag];
         }
         [container addObject:hashtag];
     }];
    return [NSArray arrayWithArray:container];
}

- (NSArray *)getHashTags:(NSString *)fieldText
{
    return [self getHashTags:fieldText includeHashMark:NO];
}

#pragma mark - Hashtag Actions

- (void)subscribeToHashtag:(VHashtag *)hashtag
{
    VLog(@"Follow #%@", hashtag.tag);
    
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VLog(@"Success");
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        VLog(@"Subscribe FAILED!");
    };
    
    // Backend Subscribe to Hashtag
        [[VObjectManager sharedManager] subscribeToHashtag:hashtag
                                              successBlock:successBlock
                                                 failBlock:failureBlock];
}

- (void)unsubscribeToHashtag:(VHashtag *)hashtag successBlock:(VSuccessBlock)success failBlock:(VFailBlock)fail
{
    VLog(@"Unfollow #%@", hashtag.tag);
    
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VLog(@"Unsub Success");
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        VLog(@"Unsub FAILED!");
    };
    
    // Backend Unsubscribe to Hashtag call
        [[VObjectManager sharedManager] unsubscribeToHashtag:hashtag
                                                successBlock:successBlock
                                                   failBlock:failureBlock];
}

@end
