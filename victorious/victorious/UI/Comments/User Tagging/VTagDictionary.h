//
//  VTagDictionary.h
//  victorious
//
//  Created by Sharif Ahmed on 2/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VTag;

/**
 An object to abstract away a little of the bookkeeping around keeping track of currently visible tags in an attributed string
 */
@interface VTagDictionary : NSObject

/**
 Generate a new tagDictionary from the provided array of tags
 
 @param tags the array of tags that should be represented in the tagDictionary. A tag can appear more than once in the tags dictionary and it's number of occurrences in the tags array will be represented by the tagDictionary.
 
 @return a new tagDictionary
 */
+ (instancetype)tagDictionaryWithTags:(NSArray *)tags;

/**
 Add or update the number of occurrences of a tag in the tagDictionary
 
 @param tag the tag to add or increase the occurrences count of in the tagDictionary
 */
- (void)incrementTag:(VTag *)tag;

/**
 Decrement the number of occurrences or delete a tag in the tagDictionary
 
 @param key the key value of the tag that should be removed or have its number of occurrences decremented as appropriate
 */
- (void)decrementTagWithKey:(NSString *)key;

//All of the tags in the tagDictionary represented in an array. Only one of each tag, regardless of it's number of occurrences in the tagDictionary, will be returned.
- (NSArray *)tags;

/**
 Get the tag corresponding to a given key
 
 @param key the key of the desired tag (its display-formatted string)
 
 @return the tag corresponding to the provided key
 */
- (VTag *)tagForKey:(NSString *)key;

/**
 The key corresponding to the provided tag
 
 @param tag the tag we want the key value for
 
 @return a string representing the key used to place the tag into a tagDictionary
 */
+ (NSString *)keyForTag:(VTag *)tag;

//The count of items in the tagDictionary
- (NSUInteger)count;

@end
