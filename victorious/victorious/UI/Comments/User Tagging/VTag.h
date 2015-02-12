//
//  VTag.h
//  victorious
//
//  Created by Sharif Ahmed on 2/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VUser, VHashtag;

/*
 An object to represent a user or hashtag tag within an attributed string
 */
@interface VTag : NSObject

/**
 FOR USE IN TESTS
 */
- (instancetype)initWithAttributedDisplayString:(NSMutableAttributedString *)displayString
                        databaseFormattedString:(NSString *)databaseFormattedString
                         andTagStringAttributes:(NSDictionary *)tagStringAttributes;

/**
 Generate a new tag from the given user and string attributes dictionary
 
 @param user a VUser object with valid name and remoteId fields.
 @param tagStringAttributes a dictionary of string attributes that will be used to format the tag.
 
 @return A new VTag when provided a valid user and dictionary, will raise exception if no user or dictionary is supplied
 */
+ (instancetype)tagWithUser:(VUser *)user
     andTagStringAttributes:(NSDictionary *)tagStringAttributes;

/**
 Generate a new tag from the given hashtag and string attributes dictionary
 
 @param hashtag a VHastag object with a valid tag field.
 @param tagStringAttributes a dictionary of string attributes that will be used to format the tag.
 
 @return A new VTag when provided a valid hashtag and dictionary, will raise exception if no hashtag or dictionary is supplied
 */
+ (instancetype)tagWithHashtag:(VHashtag *)hashtag
        andTagStringAttributes:(NSDictionary *)tagStringAttributes;

/**
 Generate a new tag from the given database-formatted user string and string attributes dictionary
 
 @param userString an NSString that fits the format expected by VTagStringFormatter's userRegex
 @param tagStringAttributes a dictionary of string attributes that will be used to format the tag.
 
 @return A new VTag when provided a valid string and dictionary, will raise exception if no string or dictionary is supplied
 */
+ (instancetype)tagWithUserString:(NSString *)userString
           andTagStringAttributes:(NSDictionary *)tagStringAttributes;

/**
 Generate a new tag from the given database-formatted hashtag string and string attributes dictionary
 
 @param hashtagString an NSString that fits the format expected by VTagStringFormatter's hashtagRegex
 @param tagStringAttributes a dictionary of string attributes that will be used to format the tag.
 
 @return A new VTag when provided a valid string and dictionary, will raise exception if no string or dictionary is supplied
 */
+ (instancetype)tagWithHashtagString:(NSString *)hashtagString
              andTagStringAttributes:(NSDictionary *)tagStringAttributes;

/**
 The display string corresponding to the string or object used to init the tag
 */
@property (nonatomic, readonly) NSMutableAttributedString *displayString;

/**
 The database-formatted string corresponding to the string used to init the tag
 */
@property (nonatomic, readonly) NSString *databaseFormattedString;

/**
 The string attributes the tag should have when embedded in an attributed string
 */
@property (nonatomic, readonly) NSDictionary *tagStringAttributes;

@end
