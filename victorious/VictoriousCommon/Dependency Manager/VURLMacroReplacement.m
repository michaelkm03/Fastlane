//
//  VURLMacroReplacement.m
//  victorious
//
//  Created by Josh Hinman on 2/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSCharacterSet+VURLParts.h"
#import "VURLMacroReplacement.h"

NSString * const VURLMacroReplacementDelimiter = @"%%";

static NSString * const kQueryStringDelimiter = @"?";

@implementation VURLMacroReplacement

- (NSString *)urlByReplacingMacrosFromDictionary:(NSDictionary *)macros inURLString:(NSString *)urlString
{
    return [self urlByReplacingMacrosFromDictionary:macros inURLString:urlString complete:YES];
}

- (NSString *)urlByPartiallyReplacingMacrosFromDictionary:(NSDictionary *)macros inURLString:(NSString *)urlString
{
    return [self urlByReplacingMacrosFromDictionary:macros inURLString:urlString complete:NO];
}

- (NSString *)urlByReplacingMacrosFromDictionary:(NSDictionary *)macros inURLString:(NSString *)urlString complete:(BOOL)complete
{
    NSString *nonQueryString = nil;
    NSString *queryString = nil;
    NSArray *urlParts = [urlString componentsSeparatedByString:kQueryStringDelimiter];
    
    if ( urlParts.count > 0 )
    {
        nonQueryString = urlParts[0];
        
        if ( urlParts.count > 1 )
        {
            queryString = urlParts[1];
        }
    }
    else
    {
        nonQueryString = urlString;
    }
    
    nonQueryString = [self urlByReplacingMacrosFromDictionary:macros inURLString:nonQueryString withAllowedCharacters:[NSCharacterSet v_pathPartCharacterSet] complete:complete];
    
    if ( queryString != nil )
    {
        queryString = [self urlByReplacingMacrosFromDictionary:macros inURLString:queryString withAllowedCharacters:[NSCharacterSet v_queryPartCharacterSet] complete:complete];
        return [NSString stringWithFormat:@"%@%@%@", nonQueryString, kQueryStringDelimiter, queryString];
    }
    else
    {
        return nonQueryString;
    }
}

- (NSString *)urlByReplacingMacrosFromDictionary:(NSDictionary *)macros inURLString:(NSString *)urlString withAllowedCharacters:(NSCharacterSet *)allowedCharacters complete:(BOOL)complete
{
    NSString *output = urlString;

    for (NSString *macro in macros.keyEnumerator)
    {
        NSString *replacementValue = macros[macro];
        NSAssert([replacementValue isKindOfClass:[NSString class]], @"The replacement value needs to be a string");
        
        if ( ![replacementValue isKindOfClass:[NSString class]] )
        {
            // debug builds will never get here because they will fail the assertion above, but for production builds, let's do something non-crashy.
            continue;
        }
        replacementValue = [macros[macro] stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
        output = [output stringByReplacingOccurrencesOfString:macro withString:replacementValue];
    }
    
    if ( complete )
    {
        // Remove any un-replaced macros
        static NSRegularExpression *macroRegex;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^(void)
        {
            macroRegex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%1$@.+?%1$@", VURLMacroReplacementDelimiter]
                                                                   options:0
                                                                     error:nil];
        });
        output = [macroRegex stringByReplacingMatchesInString:output options:0 range:NSMakeRange(0, output.length) withTemplate:@""];
    }
    
    return output;
}

@end
