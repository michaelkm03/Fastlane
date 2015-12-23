//
//  VSequence.h
//  
//
//  Created by Sharif Ahmed on 7/16/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VStreamItem.h"

@class VAdBreak, VComment, VEndCard, VImageAsset, VNode, VPollResult, VTracking, VUser, VVoteResult;

NS_ASSUME_NONNULL_BEGIN

@interface VSequence : VStreamItem

@property (nonatomic, retain, nullable) NSString * category;
@property (nonatomic, retain) NSNumber * commentCount;
@property (nonatomic, retain) NSNumber * createdBy;
@property (nonatomic, retain, nullable) NSDate * expiresAt;
@property (nonatomic, retain, nullable) NSString * gameStatus;
@property (nonatomic, retain) NSNumber * gifCount;
@property (nonatomic, retain) NSNumber * hasReposted;
@property (nonatomic, retain) NSNumber * isComplete;
@property (nonatomic, retain) NSNumber * isLikedByMainUser;
@property (nonatomic, retain) NSNumber * hasBeenRepostedByMainUser;
@property (nonatomic, retain) NSNumber * isRemix;
@property (nonatomic, retain) NSNumber * isRepost;
@property (nonatomic, retain) NSNumber * likeCount;
@property (nonatomic, retain) NSNumber * memeCount;
@property (nonatomic, retain) NSNumber * nameEmbeddedInContent;
@property (nonatomic, retain, nullable) NSNumber * parentUserId;
@property (nonatomic, retain) NSNumber * permissionsMask;
@property (nonatomic, retain, nullable) id previewData;
@property (nonatomic, retain, nullable) NSString * previewType;
@property (nonatomic, retain) NSNumber * repostCount;
@property (nonatomic, retain, nullable) NSString * sequenceDescription;
@property (nonatomic, retain, nullable) NSOrderedSet * adBreaks;
@property (nonatomic, retain) NSOrderedSet * comments;
@property (nonatomic, retain, nullable) VEndCard * endCard;
@property (nonatomic, retain, nullable) NSSet * likers;
@property (nonatomic, retain, nullable) NSOrderedSet * nodes;
@property (nonatomic, retain, nullable) VEndCard * parentEndCard;
@property (nonatomic, retain, nullable) VUser * parentUser;
@property (nonatomic, retain, nullable) NSSet * pollResults;
@property (nonatomic, retain, nullable) VUser * recentUser;
@property (nonatomic, retain) NSOrderedSet * reposters;
@property (nonatomic, retain, nullable) VTracking * tracking;
@property (nonatomic, retain) VUser * user;
@property (nonatomic, retain, nullable) NSSet * voteResults;
@property (nonatomic, retain, nullable) NSOrderedSet * recentComments;
@property (nonatomic, retain) NSNumber * isGifStyle;
@property (nonatomic, retain, nullable) NSString * trendingTopicName;

@end

@interface VSequence (CoreDataGeneratedAccessors)

- (void)insertObject:(VAdBreak *)value inAdBreaksAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAdBreaksAtIndex:(NSUInteger)idx;
- (void)insertAdBreaks:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAdBreaksAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAdBreaksAtIndex:(NSUInteger)idx withObject:(VAdBreak *)value;
- (void)replaceAdBreaksAtIndexes:(NSIndexSet *)indexes withAdBreaks:(NSArray *)values;
- (void)addAdBreaksObject:(VAdBreak *)value;
- (void)removeAdBreaksObject:(VAdBreak *)value;
- (void)addAdBreaks:(NSOrderedSet *)values;
- (void)removeAdBreaks:(NSOrderedSet *)values;
- (void)insertObject:(VComment *)value inCommentsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCommentsAtIndex:(NSUInteger)idx;
- (void)insertComments:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCommentsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCommentsAtIndex:(NSUInteger)idx withObject:(VComment *)value;
- (void)replaceCommentsAtIndexes:(NSIndexSet *)indexes withComments:(NSArray *)values;
- (void)addCommentsObject:(VComment *)value;
- (void)removeCommentsObject:(VComment *)value;
- (void)addComments:(NSOrderedSet *)values;
- (void)removeComments:(NSOrderedSet *)values;
- (void)addLikersObject:(VUser *)value;
- (void)removeLikersObject:(VUser *)value;
- (void)addLikers:(NSSet *)values;
- (void)removeLikers:(NSSet *)values;

- (void)insertObject:(VNode *)value inNodesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromNodesAtIndex:(NSUInteger)idx;
- (void)insertNodes:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeNodesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInNodesAtIndex:(NSUInteger)idx withObject:(VNode *)value;
- (void)replaceNodesAtIndexes:(NSIndexSet *)indexes withNodes:(NSArray *)values;
- (void)addNodesObject:(VNode *)value;
- (void)removeNodesObject:(VNode *)value;
- (void)addNodes:(NSOrderedSet *)values;
- (void)removeNodes:(NSOrderedSet *)values;
- (void)addPollResultsObject:(VPollResult *)value;
- (void)removePollResultsObject:(VPollResult *)value;
- (void)addPollResults:(NSSet *)values;
- (void)removePollResults:(NSSet *)values;

- (void)addRepostersObject:(VUser *)value;
- (void)removeRepostersObject:(VUser *)value;
- (void)addReposters:(NSOrderedSet *)values;
- (void)removeReposters:(NSOrderedSet *)values;

- (void)addVoteResultsObject:(VVoteResult *)value;
- (void)removeVoteResultsObject:(VVoteResult *)value;
- (void)addVoteResults:(NSSet *)values;
- (void)removeVoteResults:(NSSet *)values;

- (void)insertObject:(VComment *)value inRecentCommentsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRecentCommentsAtIndex:(NSUInteger)idx;
- (void)insertRecentComments:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRecentCommentsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRecentCommentsAtIndex:(NSUInteger)idx withObject:(VComment *)value;
- (void)replaceRecentCommentsAtIndexes:(NSIndexSet *)indexes withRecentComments:(NSArray *)values;
- (void)addRecentCommentsObject:(VComment *)value;
- (void)removeRecentCommentsObject:(VComment *)value;
- (void)addRecentComments:(NSOrderedSet *)values;
- (void)removeRecentComments:(NSOrderedSet *)values;
@end

NS_ASSUME_NONNULL_END
