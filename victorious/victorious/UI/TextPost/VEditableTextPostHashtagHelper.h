//
//  VEditableTextPostHashtagHelper.h
//  victorious
//
//  Created by Patrick Lynch on 3/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A helper class that manages hashtag-related actions for text posts.
 The primary function is to store a list of added hashtags in the `embeddedHashtags` set.
 The secondary function is to manage additions and removals by detrmining when they occur in
 `setHashtagModificationsWithBeforeText:afterText` and storing the results in the `removed`
 and `added` properties.
 */
@interface VEditableTextPostHashtagHelper : NSObject

/**
 An array of hashtags that were recently removed, cached here to reference if needed.
 */
@property (nonatomic, strong, readonly) NSArray *removed;

/**
 An array of hashtags that were recently added, cached here to reference if needed.
 */
@property (nonatomic, strong, readonly) NSArray *added;

/**
 A list of strings that represents which hastags have been added into some text
 that is managed elsewhere.
 */
@property (nonatomic, strong, readonly) NSMutableSet *embeddedHashtags;

/**
 Manually add a hastag from the `embeddedHashatgs` set.
 
 @return Whether or not the addition was successful.
 */
- (BOOL)addHashtag:(NSString *)hashtag;

/**
 Manually remove a hastag from the `embeddedHashatgs` set.
 
 @return Whether or not the removal was successful.
 */
- (BOOL)removeHashtag:(NSString *)hashtag;

/**
 Determines any added or removed hashtags in the change from `beforeText` to `afterText`,
 caching those added or removed hashtags in the `added` or `removed properties of this class.
 */
- (void)setHashtagModificationsWithBeforeText:(NSString *)beforeText afterText:(NSString *)afterText;

/**
 Clears `removed` and `added`, the cached arrays of added/removed hashtags.
 */
- (void)resetCachedModifications;

@end
