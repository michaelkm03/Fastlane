//
//  VSDKURLMacroReplacement.h
//  victorious
//
//  Created by Josh Hinman on 2/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The character sequence that bookends the macros in URLs.
 */
extern NSString * const VSDKURLMacroReplacementDelimiter;

/**
 A class for replacing macros in a URL
 string with real values
 */
@interface VSDKURLMacroReplacement : NSObject

/**
 Takes a URL-like string that contains macros (e.g. "%%SESSION_TIME%%"),
 replaces those macros with values in the given dictionary, and removes
 macros that appear in the urlString don't appear in the macros 
 dictionary.
 
 You can also use this method to remove all remaining, unmatched macros
 (perhaps you've already called
 -urlByPartiallyReplacingMacrosFromDictionary:inURLString: one or more
 times and have no more macros to replace). To do that, pass in an
 empty dictionary for the "macros" parameter.
 
 See Also: -urlByPartiallyReplacingMacrosFromDictionary:inURLString:
 
 @param macros The keys in this dictionary should be macros, including their delimeters (e.g. "%%SESSION_TIME%%").
               The values will be used to replace instances of these macros in the URL string
 @param urlString A URL-like string containing macros to be replaced
 */
- (NSString *)urlByReplacingMacrosFromDictionary:(NSDictionary *)macros inURLString:(NSString *)urlString;

/**
 Takes a URL-like string that contains macros (e.g. "%%SESSION_TIME%%"),
 replaces those macros with values in the given dictionary. This
 method does NOT remove macros that appear in the urlString but don't
 appear in the macros dictionary.
 
 See also: -urlByReplacingMacrosFromDictionary:inURLString:
 
 @param macros The keys in this dictionary should be macros, including their delimeters (e.g. "%%SESSION_TIME%%").
 The values will be used to replace instances of these macros in the URL string
 @param urlString A URL-like string containing macros to be replaced
 */
- (NSString *)urlByPartiallyReplacingMacrosFromDictionary:(NSDictionary *)macros inURLString:(NSString *)urlString;

@end