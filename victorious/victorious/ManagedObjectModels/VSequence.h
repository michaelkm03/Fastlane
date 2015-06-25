//
//  VSequence.h
//  victorious
//
//  Created by Sharif Ahmed on 6/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VStreamItem.h"

@class VAdBreak, VComment, VEndCard, VImageAsset, VNode, VPollResult, VTracking, VUser, VVoteResult;

@interface VSequence : VStreamItem

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * commentCount;
@property (nonatomic, retain) NSNumber * createdBy;
@property (nonatomic, retain) NSDate * expiresAt;
@property (nonatomic, retain) NSString * gameStatus;
@property (nonatomic, retain) NSNumber * gifCount;
@property (nonatomic, retain) NSNumber * hasReposted;
@property (nonatomic, retain) NSNumber * isComplete;
@property (nonatomic, retain) NSNumber * isRemix;
@property (nonatomic, retain) NSNumber * isRepost;
@property (nonatomic, retain) NSNumber * memeCount;
@property (nonatomic, retain) NSNumber * nameEmbeddedInContent;
@property (nonatomic, retain) NSNumber * parentUserId;
@property (nonatomic, retain) NSNumber * permissionsMask;
@property (nonatomic, retain) id previewData;
@property (nonatomic, retain) NSString * previewType;
@property (nonatomic, retain) NSDate * releasedAt;
@property (nonatomic, retain) NSNumber * repostCount;
@property (nonatomic, retain) NSString * sequenceDescription;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSOrderedSet *adBreaks;
@property (nonatomic, retain) NSOrderedSet *comments;
@property (nonatomic, retain) VEndCard *endCard;
@property (nonatomic, retain) NSOrderedSet *nodes;
@property (nonatomic, retain) VEndCard *parentEndCard;
@property (nonatomic, retain) VUser *parentUser;
@property (nonatomic, retain) NSSet *pollResults;
@property (nonatomic, retain) NSSet *previewAssets;
@property (nonatomic, retain) NSSet *reposters;
@property (nonatomic, retain) VTracking *tracking;
@property (nonatomic, retain) VUser *user;
@property (nonatomic, retain) NSSet *voteResults;
@property (nonatomic, retain) NSNumber * likeCount;
@property (nonatomic, retain) NSNumber * isLikedByMainUser;
@property (nonatomic, retain) NSSet *likers;

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

- (void)addPreviewAssetsObject:(VImageAsset *)value;
- (void)removePreviewAssetsObject:(VImageAsset *)value;
- (void)addPreviewAssets:(NSSet *)values;
- (void)removePreviewAssets:(NSSet *)values;

- (void)addRepostersObject:(VUser *)value;
- (void)removeRepostersObject:(VUser *)value;
- (void)addReposters:(NSSet *)values;
- (void)removeReposters:(NSSet *)values;

- (void)addVoteResultsObject:(VVoteResult *)value;
- (void)removeVoteResultsObject:(VVoteResult *)value;
- (void)addVoteResults:(NSSet *)values;
- (void)removeVoteResults:(NSSet *)values;

- (void)addLikersObject:(VUser *)value;
- (void)removeLikersObject:(VUser *)value;
- (void)addLikers:(NSSet *)values;
- (void)removeLikers:(NSSet *)values;

@end
