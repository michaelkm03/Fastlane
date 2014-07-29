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
 Returns an attributed string with a single hash tag highlighted using the proper app theme
 
 @param hashTag The string that contains a hash tag to be formatted.
 
 @return A NSMutableAttributedString object that contains the property formatted text string.
 */
+(NSMutableAttributedString*)formatTag:(NSString*)hashTag;

/**
 Returns an attributed string with hash tags highlighted using the proper app theme
 
 @param fieldText The string, (that may or may not contain hash tags), that needs to be formatted.
 @param tagDictionary A dictionary object that contains any hashtags found in the fieldText that need to be formatted.
 
 @return A NSMutableAttributedString object that contains the property formatted text string.
 */
+(NSMutableAttributedString*)formatHashTags:(NSMutableAttributedString*)fieldText withDictionary:(NSDictionary*)tagDictionary;


/**
 Returns an BOOL indicating wheather hash tags are detected in a string of text.
 
 @param fieldText The string, (that may or may not contain hash tags), that needs to be checked
 
 @return An NSDictionary object containing any found tags. (Otherwise return nil)
 */
+(NSDictionary*)detectHashTags:(NSString*)fieldText;

@end
