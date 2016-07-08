//
//  VTagStringFormatter.m
//  victorious
//
//  Created by Sharif Ahmed on 2/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTagStringFormatter.h"
#import "VTag.h"
#import "VDependencyManager.h"
#import "VHashtag.h"
#import "VUserTaggingTextStorage.h"
#import "VTagDictionary.h"
#import "victorious-Swift.h"

@implementation VTagStringFormatter

+ (VTagDictionary *)tagDictionaryFromFormattingAttributedString:(NSMutableAttributedString *)attributedString
                               withTagStringAttributes:(NSDictionary *)tagStringAttributes
                               andDefaultStringAttributes:(NSDictionary *)defaultStringAttributes
{
    NSAssert(attributedString != nil, @"Must supply a attributedString to format");
    NSAssert(tagStringAttributes != nil, @"Must supply tagStringAttributes to format");
    NSAssert(defaultStringAttributes != nil, @"Must supply defaultStringAttributes to format");

    //Return a set of found tags and format attributedString to show properly highlighted
    VTagDictionary *foundTags = [[VTagDictionary alloc] init];
    
    //Find the location, if any, of the user names within the userString
    NSString *rawString = attributedString.string;
    NSArray *userCheckResults = [[self userRegex] matchesInString:rawString
                                                    options:0
                                                      range:NSMakeRange(0, rawString.length)];
    
    //Doing this "backwards" loop to edit later ranges first
    //Assumes mathchesInString:... returns results in order of first to last location in string
    for (NSInteger i = userCheckResults.count - 1; i>= 0; i--)
    {
        NSRange range = [[userCheckResults objectAtIndex:i] rangeAtIndex:0];
        VTag *tag = [VTag tagWithUserString:[rawString substringWithRange:range] andTagStringAttributes:tagStringAttributes];
        if ( tag == nil )
        {
            continue;
        }
        [foundTags incrementTag:tag];
        [attributedString replaceCharactersInRange:range withAttributedString:[self delimitedAttributedString:tag.displayString withDelimiterAttributes:defaultStringAttributes]];
    }
    
    NSArray *hashtagCheckResults = [[self hashtagRegex] matchesInString:rawString
                                                          options:0
                                                            range:NSMakeRange(0, rawString.length)];
    
    for (NSInteger i = hashtagCheckResults.count - 1; i>= 0; i--)
    {
        NSRange range = [[hashtagCheckResults objectAtIndex:i] rangeAtIndex:0];
        VTag *tag = [VTag tagWithHashtagString:[rawString substringWithRange:range] andTagStringAttributes:tagStringAttributes];
        if ( tag == nil )
        {
            continue;
        }
        [foundTags incrementTag:tag];
        [attributedString replaceCharactersInRange:range withAttributedString:[self delimitedAttributedString:tag.displayString withDelimiterAttributes:defaultStringAttributes]];
    }
    
    //Return empty tag dictionary if no tags are found
    return foundTags;
    
}

+ (NSString *)databaseFormattedStringFromAttributedString:(NSMutableAttributedString *)attributedString
                                                 withTags:(NSArray *)tags
{
    NSAssert(attributedString != nil, @"must provide an attributed string for formatting");
    if ( tags == nil )
    {
        return attributedString.string;
    }
    
    NSString *resultString = [attributedString.string copy];
    for (VTag *tag in tags)
    {
        resultString = [resultString stringByReplacingOccurrencesOfString:[self delimitedString:tag.displayString.string] withString:tag.databaseFormattedString];
    }
    return resultString;
    
}

+ (NSMutableAttributedString *)delimitedAttributedString:(NSAttributedString *)attributedString
                                 withDelimiterAttributes:(NSDictionary *)attributes
{
    NSAssert(attributedString != nil, @"must provide an attibuted string to delimit");
    NSAssert(attributes != nil, @"must provide string attributes to apply to delimiting strings");
    
    NSMutableAttributedString *delimString = [[NSMutableAttributedString alloc] initWithString:[self delimiterString] attributes:attributes];
    NSAttributedString *endDelim = [delimString copy];
    [delimString appendAttributedString:attributedString];
    [delimString appendAttributedString:endDelim];
    return delimString;
}

+ (NSString *)databaseFormattedStringFromUser:(VUser *)user
{
    if ( user == nil )
    {
        return nil;
    }
    return [NSString stringWithFormat:@"@{%@:%@}", [user.remoteId stringValue], user.name];
}

+ (NSString *)databaseFormattedStringFromHashtag:(VHashtag *)hashtag
{
    if ( hashtag == nil )
    {
        return nil;
    }
    return [NSString stringWithFormat:@"#%@", hashtag.tag];
}

+ (NSIndexSet *)tagRangesInRange:(NSRange)range
              ofAttributedString:(NSAttributedString *)attributedString
               withTagDictionary:(VTagDictionary *)tagDictionary
{
    NSAssert(attributedString != nil, @"must provide attributed string to find tags in");
    
    NSMutableIndexSet *tagRanges = [[NSMutableIndexSet alloc] init];
    NSUInteger startIndex = range.location;
    while ( startIndex <= range.location + range.length )
    {
        NSRange tagRange;
        BOOL foundTag = [self foundTagAtIndex:startIndex ofAttributedString:attributedString withTagDictionary:tagDictionary range:&tagRange];
        if ( foundTag )
        {
            [tagRanges addIndexesInRange:tagRange];
        }
        startIndex = MAX(tagRange.location + tagRange.length, startIndex) + 1;

    }
    return tagRanges.count > 0 ? tagRanges : nil;
}

#pragma mark - static resources

+ (NSString *)defaultDependencyManagerTagColorKey
{
    return VDependencyManagerLinkColorKey;
}

+ (NSString *)delimiterString
{
    static NSString *delimiterString;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      char cString[] = "\u200B";
                      NSData *data = [NSData dataWithBytes:cString length:strlen(cString)];
                      delimiterString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                  });
    return delimiterString;
}

+ (NSRegularExpression *)userRegex
{
    static NSRegularExpression *userRegex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      userRegex = [NSRegularExpression regularExpressionWithPattern:@"@\\{(.+?):(.+?)\\}"
                                                                            options:0
                                                                              error:nil];
                  });
    return userRegex;
}

+ (NSRegularExpression *)hashtagRegex
{
    static NSRegularExpression *hashtagRegex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      hashtagRegex = [NSRegularExpression regularExpressionWithPattern:@"(#\\w*[a-zA-Z]\\w*)"
                                                                               options:0
                                                                                 error:nil];
                  });
    return hashtagRegex;
}

#pragma mark - internal

//Add delims as bookends to the provided string
+ (NSString *)delimitedString:(NSString *)string
{
    NSString *delimString = [self delimiterString];
    return [[delimString stringByAppendingString:string] stringByAppendingString:delimString];
}

//Find the range of a tag contained within the provided tag dictionary with tag attributes that has a character at the provided index of the provided attributed string
+ (BOOL)foundTagAtIndex:(NSInteger)index
     ofAttributedString:(NSAttributedString *)attributedString
      withTagDictionary:(VTagDictionary *)tagDictionary
                  range:(NSRangePointer)range
{
    if (index >= (NSInteger)attributedString.string.length || tagDictionary.count == 0)
    {
        return NO;
    }
    UIColor *textColor = [attributedString attribute:NSForegroundColorAttributeName atIndex:index longestEffectiveRange:range inRange:NSMakeRange(0, attributedString.length)];
    NSString *key = [attributedString.string substringWithRange:*range];
    VTag *tag = [tagDictionary tagForKey:key];
    
    if ( tag )
    {
        if ( ![[tag.tagStringAttributes objectForKey:NSForegroundColorAttributeName] isEqual:textColor] )
        {
            return NO; //The attributes in the string do not match those from our tag, so no match
        }
        
        (*range).location -= 1;
        (*range).length += 2;
        return YES; //1s on either side take delimiting chars into account
    }
    return NO; //The attributes in the string do not match those from our tag, so no match
}

@end
