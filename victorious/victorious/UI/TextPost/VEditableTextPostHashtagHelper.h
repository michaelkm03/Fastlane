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
 An array of hashtags that were removed after calling `collectHashtagEditsFromBeforeText:toAfterText`
 and collected here to evaluate.
 */
@property (nonatomic, strong, readonly) NSArray *collectedHashtagsRemoved;

/**
 An array of hashtags that were added after calling `collectHashtagEditsFromBeforeText:toAfterText`
 and collected here to evaluate.
 */
@property (nonatomic, strong, readonly) NSArray *collectedHashtagsAdded;

/**
 A list of strings that represents which hastags have been added into some text
 that is managed elsewhere.  This exists to manage the state of hashtags in that text
 so that a user's edits to a text view containing the text or programmatic insertions and
 removals of hashtags are tracked.
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
 collectiong those added or removed hashtags in the `collectedHashtagsAdded` or
 `collectedHashtagsRemoved` properties of this class.  This is used to detect hashtags removed while
 a user is editing text in a text view.
 */
- (void)collectHashtagEditsFromBeforeText:(NSString *)beforeText toAfterText:(NSString *)afterText;

/**
 Clears `collectedHashtagsRemoved` and `collectedHashtagsAdded`, arrays of added/removed hashtags
 collected after calling  `collectHashtagEditsFromBeforeText:toAfterText`;
 */
- (void)resetCollectedHashtagEdits;

@end
