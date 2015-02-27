//
//  VURLMacroReplacement.h
//  victorious
//
//  Created by Josh Hinman on 2/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The character sequence that bookends the macros in URLs.
 */
extern NSString * const VURLMacroReplacementDelimiter;

/**
 A class for replacing macros in a URL
 string with real values
 */
@interface VURLMacroReplacement : NSObject

/**
 Takes a URL-like string that contains macros (e.g. "%%SESSION_TIME%%"),
 replaces those macros with values in the given dictionary, and removes
 macros that appear in the urlString don't appear in the macros 
 dictionary.
 
 @param macros The keys in this dictionary should be macros, including their delimeters (e.g. "%%SESSION_TIME%%").
               The values will be used to replace instances of these macros in the URL string
 @param urlString A URL-like string containing macros to be replaced
 */
+ (NSString *)urlByReplacingMacrosFromDictionary:(NSDictionary *)macros inURLString:(NSString *)urlString;

@end
