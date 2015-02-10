//
//  VInlineUserSearch.m
//  victorious
//
//  Created by Lawrence Leach on 1/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInlineUserSearch.h"
#import "VUser.h"
#import "VThemeManager.h"
#import "VConstants.h"

@import CoreText;

@implementation VInlineUserSearch

+ (NSDictionary *)inlineUsernameAttributes
{
    return @{
             NSFontAttributeName : [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont],
             NSForegroundColorAttributeName : [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor],
             (NSString *)kCTUnderlineStyleAttributeName : @(kCTUnderlineStyleSingle)
             };
}

+ (NSString *)extractUsernameFromTextField:(NSString *)fieldText
{
    NSString *returnString = @"";
    
    // Identify where the username is in the current field text
    NSRange range = [fieldText rangeOfString:@"@"];
    if (range.location != NSNotFound)
    {
        returnString = [fieldText substringFromIndex:range.location];
    }
    
    return returnString;
}

+ (NSAttributedString *)formatUsernamesInContentString:(NSString *)content
{
    // Highlight any tagged users in the comment text
    __block NSMutableAttributedString *formattedString = [[NSMutableAttributedString alloc] initWithString:content];
    NSArray *userRanges = [self detectUserObjectsInTextField:content];
    [userRanges enumerateObjectsUsingBlock:^(NSValue *enumeratedRangeValue, NSUInteger idx, BOOL *stop)
     {
         NSRange rangeFromValue = [enumeratedRangeValue rangeValue];
         NSString *userString = [content substringWithRange:rangeFromValue];
         
         NSArray *cleanUser = [VInlineUserSearch userStringCleanup:userString];
         NSMutableAttributedString *username = [[NSMutableAttributedString alloc] initWithString:cleanUser[1]
                                                                                      attributes:[VInlineUserSearch inlineUsernameAttributes]];
         
         NSString *profileUrl = [NSString stringWithFormat:@"vuser://%@", cleanUser[0]];
         [username addAttribute:NSLinkAttributeName
                          value:[NSURL URLWithString:profileUrl]
                          range:NSMakeRange(0, username.length)];
         
         NSRange rangeFromString = [formattedString.string rangeOfString:userString];
         
         [formattedString replaceCharactersInRange:rangeFromString
                              withAttributedString:username];
         
     }];
    
    return formattedString;
}

+ (NSAttributedString *)formatUsername:(VUser *)user
{
    // Set username to backend format
    NSString *userString = [self formatUsernameForBackend:user];
    
    // Format the username according to the current theme
    NSMutableAttributedString *formattedString = [[NSMutableAttributedString alloc] initWithString:user.name
                                                                                        attributes:[self inlineUsernameAttributes]];
    [formattedString addAttribute:NSLinkAttributeName
                            value:userString
                            range:NSMakeRange(0, formattedString.length)];
    
    // Return the attributed string
    return [formattedString copy];
}

+ (NSString *)formatUsernameForBackend:(VUser *)user
{
    return [NSString stringWithFormat:@"@{%@:%@}", user.remoteId, user.name];
}

+ (NSAttributedString *)formatUsernameWithBackendObject:(NSString *)userString
{
    NSArray *cleanUser = [self userStringCleanup:userString];
    NSString *username = cleanUser[1];
    
    NSMutableAttributedString *formattedString = [[NSMutableAttributedString alloc] initWithString:username
                                                                                        attributes:[self inlineUsernameAttributes]];
    [formattedString addAttribute:NSLinkAttributeName
                            value:userString
                            range:NSMakeRange(0, formattedString.length)];

    return formattedString;
}

+ (NSArray *)userStringCleanup:(NSString *)userString
{
    NSMutableString *string = [[NSMutableString alloc] initWithString:userString];
    [string replaceOccurrencesOfString:@"@{" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, string.length)];
    [string replaceOccurrencesOfString:@"}" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, string.length)];
    
    return [string componentsSeparatedByString:@":"];
}

+ (NSArray *)detectUserObjectsInTextField:(NSString *)fieldText
{
    if (fieldText == nil || fieldText.length == 0)
    {
        return nil;
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\@\\{(\\d+)\\:(.*?)\\}"
                                                                           options:0
                                                                             error:nil];
    NSArray *users = [regex matchesInString:fieldText
                                   options:0
                                     range:NSMakeRange(0, fieldText.length)];
    
    [users enumerateObjectsUsingBlock:^(NSTextCheckingResult *user, NSUInteger idx, BOOL *stop)
    {
        NSRange userRange = [user range];
        [array addObject:[NSValue valueWithRange:userRange]];
    }];
    
    return [NSArray arrayWithArray:array];
}

@end
