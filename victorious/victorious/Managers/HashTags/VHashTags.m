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
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:hashTag attributes:[self attributeForHashTag]];
    return attributedString;
}

+(NSDictionary *)attributeForHashTag
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    return @{ NSFontAttributeName: [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont],
              NSForegroundColorAttributeName: [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor],
              NSParagraphStyleAttributeName: paragraphStyle,
              };
}

+(NSDictionary*)detectHashTags:(NSString*)fieldText
{
    BOOL haveTag = NO;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&error];
    NSArray *tags = [regex matchesInString:fieldText options:0 range:NSMakeRange(0, fieldText.length)];
    for (NSTextCheckingResult *tag in tags) {
        NSRange wordRange = [tag rangeAtIndex:1];
        NSString* word = [fieldText substringWithRange:wordRange];
        haveTag = YES;
        
        [dictionary setObject:[NSValue valueWithRange:wordRange] forKey:word];
    }
    return (NSDictionary*)dictionary;

}

+(NSMutableAttributedString*)formatHashTags:(NSMutableAttributedString*)fieldText withDictionary:(NSDictionary*)tagDictionary
{
    NSMutableAttributedString *attributedTag = [[NSMutableAttributedString alloc] initWithString:@""];
    for (NSString *tag in [tagDictionary allKeys]) {
        NSValue *val = [tagDictionary valueForKey:tag];
        NSRange oldRange = [val rangeValue];
        NSRange newRange = {oldRange.location-1,oldRange.length+1};
        
        NSString *tagText = [NSString stringWithFormat:@"#%@",tag];
        
        attributedTag = [self formatTag:tagText];
        
        [fieldText replaceCharactersInRange:newRange withAttributedString:attributedTag];
    }
    return fieldText;

}




@end
