//
//  VURLMacroReplacement.m
//  victorious
//
//  Created by Josh Hinman on 2/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VURLMacroReplacement.h"

NSString * const VURLMacroReplacementDelimiter = @"%%";

static NSString * const kQueryStringDelimiter = @"?";

@implementation VURLMacroReplacement

+ (NSString *)urlByReplacingMacrosFromDictionary:(NSDictionary *)macros inURLString:(NSString *)urlString
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
    
    nonQueryString = [self urlByReplacingMacrosFromDictionary:macros inURLString:nonQueryString withAllowedCharacters:[NSCharacterSet v_pathPartCharacterSet]];
    
    if ( queryString != nil )
    {
        queryString = [self urlByReplacingMacrosFromDictionary:macros inURLString:queryString withAllowedCharacters:[NSCharacterSet v_queryPartCharacterSet]];
        return [NSString stringWithFormat:@"%@%@%@", nonQueryString, kQueryStringDelimiter, queryString];
    }
    else
    {
        return nonQueryString;
    }
}

+ (NSString *)urlByReplacingMacrosFromDictionary:(NSDictionary *)macros inURLString:(NSString *)urlString withAllowedCharacters:(NSCharacterSet *)allowedCharacters
{
    NSString *output = urlString;

    for (NSString *macro in macros.keyEnumerator)
    {
        NSString *queryStringReplacementValue = [macros[macro] stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
        output = [output stringByReplacingOccurrencesOfString:macro withString:queryStringReplacementValue];
    }
    
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
    
    return output;
}

@end

#pragma mark -

@implementation NSCharacterSet (VURLMacroReplacementExtensions)

+ (NSCharacterSet *)v_pathPartCharacterSet
{
    static NSCharacterSet *pathPartCharacterSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
    {
        NSMutableCharacterSet *mutableCharacterSet = [[NSCharacterSet URLPathAllowedCharacterSet] mutableCopy];
        [mutableCharacterSet removeCharactersInRange:NSMakeRange('/', 1)];
        pathPartCharacterSet = [mutableCharacterSet copy];
    });
    return pathPartCharacterSet;
}

+ (NSCharacterSet *)v_queryPartCharacterSet
{
    static NSCharacterSet *queryPartCharacterSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
    {
        NSMutableCharacterSet *mutableCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [mutableCharacterSet removeCharactersInString:@"?&="];
        queryPartCharacterSet = [mutableCharacterSet copy];
    });
    return queryPartCharacterSet;
}

@end
