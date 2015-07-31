//
//  VUser.h
//  victorious
//
//  Created by Sharif Ahmed on 6/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VComment, VConversation, VHashtag, VImageAsset, VMessage, VNotification, VPollResult, VSequence, VUser;

@interface VUser : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * isDirectMessagingDisabled;
@property (nonatomic, retain) NSNumber * isFollowedByMainUser;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numberOfFollowers;
@property (nonatomic, retain) NSNumber * numberOfFollowing;
@property (nonatomic, retain) NSString * pictureUrl;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * tagline;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSDate * tokenUpdatedAt;
@property (nonatomic, retain) NSSet *childSequences;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) VConversation *conversation;
@property (nonatomic, retain) NSSet *followers;
@property (nonatomic, retain) NSSet *following;
@property (nonatomic, retain) NSOrderedSet *hashtags;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSSet *notifications;
@property (nonatomic, retain) NSSet *pollResults;
@property (nonatomic, retain) NSOrderedSet *recentSequences;
@property (nonatomic, retain) NSSet *previewAssets;
@property (nonatomic, retain) NSSet *repostedSequences;
@property (nonatomic, retain) NSNumber *maxUploadDuration;

@end

@interface VUser (CoreDataGeneratedAccessors)

- (void)addChildSequencesObject:(VSequence *)value;
- (void)removeChildSequencesObject:(VSequence *)value;
- (void)addChildSequences:(NSSet *)values;
- (void)removeChildSequences:(NSSet *)values;

- (void)addCommentsObject:(VComment *)value;
- (void)removeCommentsObject:(VComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addFollowersObject:(VUser *)value;
- (void)removeFollowersObject:(VUser *)value;
- (void)addFollowers:(NSSet *)values;
- (void)removeFollowers:(NSSet *)values;

- (void)addFollowingObject:(VUser *)value;
- (void)removeFollowingObject:(VUser *)value;
- (void)addFollowing:(NSSet *)values;
- (void)removeFollowing:(NSSet *)values;

- (void)insertObject:(VHashtag *)value inHashtagsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromHashtagsAtIndex:(NSUInteger)idx;
- (void)insertHashtags:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeHashtagsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInHashtagsAtIndex:(NSUInteger)idx withObject:(VHashtag *)value;
- (void)replaceHashtagsAtIndexes:(NSIndexSet *)indexes withHashtags:(NSArray *)values;
- (void)addHashtagsObject:(VHashtag *)value;
- (void)removeHashtagsObject:(VHashtag *)value;
- (void)addHashtags:(NSOrderedSet *)values;
- (void)removeHashtags:(NSOrderedSet *)values;
- (void)addMessagesObject:(VMessage *)value;
- (void)removeMessagesObject:(VMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addNotificationsObject:(VNotification *)value;
- (void)removeNotificationsObject:(VNotification *)value;
- (void)addNotifications:(NSSet *)values;
- (void)removeNotifications:(NSSet *)values;

- (void)addPollResultsObject:(VPollResult *)value;
- (void)removePollResultsObject:(VPollResult *)value;
- (void)addPollResults:(NSSet *)values;
- (void)removePollResults:(NSSet *)values;

- (void)addRecentSequencesObject:(VSequence *)value;
- (void)removeRecentSequencesObject:(VSequence *)value;
- (void)addRecentSequences:(NSOrderedSet *)values;
- (void)removeRecentSequences:(NSOrderedSet *)values;

- (void)addPreviewAssetsObject:(VImageAsset *)value;
- (void)removePreviewAssetsObject:(VImageAsset *)value;
- (void)addPreviewAssets:(NSSet *)values;
- (void)removePreviewAssets:(NSSet *)values;

- (void)addRepostedSequencesObject:(VSequence *)value;
- (void)removeRepostedSequencesObject:(VSequence *)value;
- (void)addRepostedSequences:(NSSet *)values;
- (void)removeRepostedSequences:(NSSet *)values;

@end
