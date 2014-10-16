//
//  VHashTags.m
//  victorious
//
//  Created by Lawrence Leach on 7/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHashTags.h"

@implementation VHashTags

+ (NSArray *)detectHashTags:(NSString *)fieldText
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

+ (BOOL)formatHashTagsInString:(NSMutableAttributedString *)fieldText
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

@end
