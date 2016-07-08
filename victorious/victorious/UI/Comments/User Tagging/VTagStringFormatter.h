//
//  VTagStringFormatter.h
//  victorious
//
//  Created by Sharif Ahmed on 2/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VUser, VTagDictionary;

/**
 A helper for converting attributed strings with tags from display-formatted to database-formatted and visa versa.
 Possibly refactor to split out user and hashtag specific formatting functions to allow for easy addition of new tag types.
 */
@interface VTagStringFormatter : NSObject

/**
 Format the provided attributed string with provided attributes and return an tagDictionary of recognized tags
 
 @param attributedString An attributed string that possibly contains database-formatted tag strings ("@{remoteId:name}" for a user, #tag for hashtag).
 @param tagStringAttributes a dictionary of string attributes to use when formatting tags found within the provided attributed string
 @param defaultStringAttributes a dictionary of string attributes to use when formatting delimiters found within the provided attributed string
 
 @return A tagDictionary of recognized and replaced VTags in the provided attributedString keyed by username (if user) or tag (if hashtag), nil if none are recognized
 */
+ (VTagDictionary *)tagDictionaryFromFormattingAttributedString:(NSMutableAttributedString *)attributedString
                               withTagStringAttributes:(NSDictionary *)tagStringAttributes
                               andDefaultStringAttributes:(NSDictionary *)defaultStringAttributes;

/**
 Generate a database-formatted string from the provided attributed string that contains display-formatted strings from tags in the provided tags array
 
 @param attributedString An attributed string that possibly contains database-formatted tag strings ("@{remoteId:name}" for a user, #tag for hashtag).
 @param tags an array of tags whose database-formatted strings could be contained in the provided attributed string
 
 @return A string resulting from replacing display-formatted strings of tags from the tags array with database-formatted strings in the provided attributed string
 */
+ (NSString *)databaseFormattedStringFromAttributedString:(NSMutableAttributedString *)attributedString
                                             withTags:(NSArray *)tags;

/**
 Add delimiting strings with provided string attributes to provided attributed string
 
 @param attributedString Any attributed string
 @param attributes a dictionary of string attributes that will be applied to the delimiter string on either side of the attributed string
 
 @return a mutable attributed string with delimiter strings, formatted by the provided attributes, bookending the provided attributed string
 */
+ (NSMutableAttributedString *)delimitedAttributedString:(NSAttributedString *)attributedString
                                 withDelimiterAttributes:(NSDictionary *)attributes;

/**
 Generate a database-formatted string from the provided user
 
 @param user a user with valid name and remoteId fields
 
 @return a database-formatted string composed of the name and remoteId fields from the user or an empty string for nil user or user with invalid fields
 */
+ (NSString *)databaseFormattedStringFromUser:(VUser *)user;

/**
 All ranges of tags in provided range of attributed string containing tags in the provided tagDictionary. Returned ranges will include full ranges of any partial tags found in the provided range. Delimiter strings are included in the returned ranges.
 
 @param range range to check for tags contained in the tagDictionary
 @param attributedString an attributed string containing display-formatted tags from the tagDictionary
 @param tagDictionary a tagDictionary containing tags with displayStrings contained in the provided attributed string
 
 @return an indexSet created from all found tag ranges or nil if no tags are found
 */
+ (NSIndexSet *)tagRangesInRange:(NSRange)range
              ofAttributedString:(NSAttributedString *)attributedString
               withTagDictionary:(VTagDictionary *)tagDictionary;

/**
 String key for tag color from dependency manager
 */
+ (NSString *)defaultDependencyManagerTagColorKey;

/**
 Shared delimiter string used as delimiter on either side of tag strings for easy recognition and formatting
 */
+ (NSString *)delimiterString;

/**
 Shared NSRegularExpression for matching database-formatted VUsers in strings
 */
+ (NSRegularExpression *)userRegex;

/**
 Shared NSRegularExpression for matching database-formatted VHashtags in strings
 */
+ (NSRegularExpression *)hashtagRegex;

@end
