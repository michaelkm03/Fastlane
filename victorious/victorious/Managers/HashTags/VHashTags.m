//
//  VHashTags.m
//  victorious
//
//  Created by Lawrence Leach on 7/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHashTags.h"

#import "VThemeManager.h"

@interface VHashTags ()

+(NSDictionary *)attributeForHashTag;

@end

@implementation VHashTags


+(NSMutableAttributedString*)formatTag:(NSString*)hashTag
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:hashTag
                                                                                         attributes:[self attributeForHashTag]];
    return attributedString;
}

+(NSDictionary *)attributeForHashTag
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    return @{
             NSFontAttributeName: [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont],
             NSForegroundColorAttributeName: [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor],
             NSParagraphStyleAttributeName: paragraphStyle,
             };
}

+(NSArray*)detectHashTags:(NSString*)fieldText
{
    if (!fieldText)
    {
        return nil;
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)"
                                                                           options:0
                                                                             error:&error];
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

+(NSMutableAttributedString*)formatHashTags:(NSMutableAttributedString*)fieldText
                              withTagRanges:(NSArray*)tagRanges
{
    __block NSMutableAttributedString *attributedTag = [[NSMutableAttributedString alloc] initWithString:@""];
    
    [tagRanges enumerateObjectsUsingBlock:^(NSValue *tagRangeValue, NSUInteger idx, BOOL *stop)
    {
        NSRange tagRange = [tagRangeValue rangeValue];
        NSRange tagRangeWithHash = {tagRange.location-1,tagRange.length+1};
        NSString *tagText = [NSString stringWithFormat:@"#%@", [fieldText.string substringWithRange:tagRange]];
        attributedTag = [self formatTag:tagText];
        [fieldText replaceCharactersInRange:tagRangeWithHash
                       withAttributedString:attributedTag];
    }];
    
    return fieldText;
}




@end
