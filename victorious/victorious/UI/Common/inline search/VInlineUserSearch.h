//
//  VInlineUserSearch.h
//  victorious
//
//  Created by Lawrence Leach on 1/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VUser;

@interface VInlineUserSearch : NSObject

/**
 Default attributes for username in a text string
 
 @return NSDictionary of attributed string attributes
 */
+ (NSDictionary *)inlineUsernameAttributes;

/**
 Grabs the user search term from text chunk
 
 @param fieldText Text that contains username
 
 @return NSString of username search term
 */
+ (NSString *)extractUsernameFromTextField:(NSString *)fieldText;

/**
 Parses a chunk of copy for tagged user objects and returns a formatted string with users highlighted
 
 @param content NSString of content to be parsed
 
 @return Attributed string with user objects formatted according to the theme
 */
+ (NSAttributedString *)formatUsernamesInContentString:(NSString *)content;

/**
 Formats and returns an NSAttributedString representing a text blurb with a user included within it
 
 @param user      VUser object of the user in the text chunk
 @param fieldText String to be formatted
 
 @return NSAtributedString version of the NSString text passed in
 */
+ (NSAttributedString *)formatUsername:(VUser *)user;

/**
 Formats a username so the backend can receive / parse it
 
 @param user VUser object of the user to be formatted
 
 @return NSSTring of the user information e.g. @{1234:Chris Crichton}
 */
+ (NSString *)formatUsernameForBackend:(VUser *)user;

/**
 Applies attributes to a string in the format of the backend
 
 @param userString The backend formatted user object
 
 @return NSAttributedString formatted version of the user object
 */
+ (NSAttributedString *)formatUsernameWithBackendObject:(NSString *)userString;

/**
 Locate any user objects contained within a chunk of text
 
 @param fieldText Text to parse
 
 @return NSArray of ranges within the provided fieldText that contain user objects
 */
+ (NSArray *)detectUserObjectsInTextField:(NSString *)fieldText;

/**
 Explodes the backend user object into an array
 
 @param userString The string to be exploded
 
 @return NSArray of the user string components
 */
+ (NSArray *)userStringCleanup:(NSString *)userString;

@end
