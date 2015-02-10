//
//  VTagStringFormatter.m
//  victorious
//
//  Created by Sharif Ahmed on 2/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTagStringFormatter.h"
#import "VTag.h"
#import "VThemeManager.h"
#import "VDependencyManager.h"
#import "VHashtag.h"
#import "VUser.h"
#import "VUserTaggingTextStorage.h"

@implementation VTagStringFormatter

//Format the provided attributed string with provided attributes and return an tagDictionary of recognized tags
+ (VTagDictionary *)tagDictionaryFromFormattingAttributedString:(NSMutableAttributedString *)attributedString
                               withTagStringAttributes:(NSDictionary *)tagStringAttributes
                               andDefaultStringAttributes:(NSDictionary *)defaultStringAttributes
{
    NSAssert(attributedString != nil, @"Must supply a attributedString to format");
    NSAssert(tagStringAttributes != nil, @"Must supply tagStringAttributes to format");
    NSAssert(defaultStringAttributes != nil, @"Must supply defaultStringAttributes to format");
    
    if ( [attributedString isKindOfClass:[VUserTaggingTextStorage class]] )
    {
        VUserTaggingTextStorage *textStorage = (VUserTaggingTextStorage *)attributedString;
        textStorage.defaultStringAttributes = defaultStringAttributes;
        textStorage.tagStringAttributes = tagStringAttributes;
    }

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
        [foundTags incrementTag:tag];
        [attributedString replaceCharactersInRange:range withAttributedString:[self delimitedAttributedString:tag.displayString withDelimiterAttributes:defaultStringAttributes]];
    }
    
    //Return empty tag dictionary if no tags are found
    return foundTags;
    
}

//Generate a database-formatted string from the provided attributed string that contains display-formatted strings from tags in the provided tags array
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

//Add delimiting strings with provided string attributes to provided attributed string
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

//Generate a database-formatted string from the provided user
+ (NSString *)databaseFormattedStringFromUser:(VUser *)user
{
    if ( user == nil )
    {
        return nil;
    }
    return [NSString stringWithFormat:@"@{%@:%@}", [user.remoteId stringValue], user.name];
}

//Generate a database-formatted string from the provided hashtag
+ (NSString *)databaseFormattedStringFromHashtag:(VHashtag *)hashtag
{
    if ( hashtag == nil )
    {
        return nil;
    }
    return [NSString stringWithFormat:@"#%@", hashtag.tag];
}

//All ranges of tags in provided range of attributed string containing tags in the provided tagDictionary. Returned ranges will include full ranges of any partial tags found in the provided range. Delimiter strings are included in the returned ranges.
+ (NSIndexSet *)tagRangesInRange:(NSRange)range
              ofAttributedString:(NSAttributedString *)attributedString
               withTagDictionary:(VTagDictionary *)tagDictionary
{
    NSAssert(attributedString != nil, @"must provide attributed string to find tags in");
    
    NSMutableIndexSet *tagRanges = [[NSMutableIndexSet alloc] init];
    NSUInteger startIndex = range.location;
    while ( startIndex <= range.location + range.length )
    {
        NSRange tagRange = [self rangeOfTagAtIndex:startIndex ofAttributedString:attributedString withTagDictionary:tagDictionary];
        if ( tagRange.location != NSNotFound )
        {
            [tagRanges addIndexesInRange:tagRange];
            startIndex = tagRange.location + tagRange.length;
        }
        else
        {
            startIndex += tagRange.length;
        }
    }
    return tagRanges.count > 0 ? tagRanges : nil;
}

#pragma mark - static resources

//String key for tag color from dependency manager
+ (NSString *)defaultDependencyManagerTagColorKey
{
    return VDependencyManagerLinkColorKey;
}

//String key for tag color from theme manager
+ (NSString *)defaultThemeManagerTagColorKey
{
    return kVLinkColor;
}

//Shared delimiter string used as delimiter on either side of tag strings for easy recognition and formatting
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

//Shared NSRegularExpression for matching database-formatted VUsers in strings
+ (NSRegularExpression *)userRegex
{
    static NSRegularExpression *userRegex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      userRegex = [NSRegularExpression regularExpressionWithPattern:@"@\\{.+?:(.+?)\\}"
                                                                            options:0
                                                                              error:nil];
                  });
    return userRegex;
}

//Shared NSRegularExpression for matching database-formatted VHashtags in strings
+ (NSRegularExpression *)hashtagRegex
{
    static NSRegularExpression *hashtagRegex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      hashtagRegex = [NSRegularExpression regularExpressionWithPattern:@"(#\\w+)"
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
+ (NSRange)rangeOfTagAtIndex:(NSInteger)index
          ofAttributedString:(NSAttributedString *)attributedString
           withTagDictionary:(VTagDictionary *)tagDictionary
{
    if (index >= (NSInteger)attributedString.string.length)
    {
        return NSMakeRange(NSNotFound, NSNotFound);;
    }
    
    NSRange range;
    NSDictionary *attrs = [attributedString attributesAtIndex:index effectiveRange:&range];
    NSString *key = [attributedString.string substringWithRange:range];
    VTag *tag = [tagDictionary tagForKey:key];
    
    if ( tag )
    {
        for ( NSString *key in tag.tagStringAttributes )
        {
            if ( ![[attrs objectForKey:key] isEqual:[tag.tagStringAttributes objectForKey:key]] )
            {
                return NSMakeRange(NSNotFound, range.length); //The attributes in the string do not match those from our tag, so no match
            }
        }
        return NSMakeRange(range.location - 1, range.length + 2); //1s on either side take delimiting chars into account
    }
    return NSMakeRange(NSNotFound, range.length); //The attributes in the string do not match those from our tag, so no match
    
    if ([tag.tagStringAttributes isEqualToDictionary:attrs])
    {
        return NSMakeRange(range.location - 1, range.length + 2); //1s on either side take delimiting chars into account
    }
    return NSMakeRange(NSNotFound, range.length); //The attributes in the string do not match those from our tag, so no match
}

@end
