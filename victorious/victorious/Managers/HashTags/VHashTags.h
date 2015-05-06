//
//  VHashTags.h
//  victorious
//
//  Created by Lawrence Leach on 7/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VHashTags : NSObject

/**
 Returns an attributed string with hash tags highlighted using the proper app theme
 
 @param fieldText The string, (that may or may not contain hash tags), that needs to be formatted.
 @param tagDictionary A dictionary object that contains any hashtags found in the fieldText that need to be formatted.
 @param attributes A dictionary of text attributes to add to each hash tag
 
 @return A NSMutableAttributedString object that contains the property formatted text string.
 */
+ (BOOL)formatHashTagsInString:(NSMutableAttributedString *)fieldText
                 withTagRanges:(NSArray *)tagRanges
                    attributes:(NSDictionary *)attributes;

+ (NSArray *)detectHashTags:(NSString *)fieldText includeHashSymbol:(BOOL)includeHashSymbol;

/**
 *  Find all hash tags within a given string.
 *
 *  @param fieldText The string to detect hash tags in.
 *
 *  @return An arry of NSRanges wrapped in NSValues.
 */
+ (NSArray *)detectHashTags:(NSString *)fieldText;

/**
 Creates a copy of the input string with a hash mark (#) prepending, if it is not already prepending.
 @param string The string with which to copy and prepend the hash mark.
 */
+ (NSString *)stringWithPrependedHashmarkFromString:(NSString *)string;

/**
 Creates a copy of the input string with a prepended hash mark (#) removed.  If there is no prepended
 hashtag, an unmodified copy is returned.
 @param string The string with which to copy and remove the prepended hash mark.
 */
+ (NSString *)stringByRemovingPrependingHashmarkFromString:(NSString *)string;

/**
 *  Find all hash tags within a given string and return the text of each one in an array.
 *
 *  @param fieldText The string to detect hash tags in.
 *
 *  @return An arry of NSStrings wrapped in NSValues.
 */
+ (NSArray *)getHashTags:(NSString *)fieldText includeHashMark:(BOOL)includeHashMark;


+ (NSArray *)getHashTags:(NSString *)fieldText;

@end
