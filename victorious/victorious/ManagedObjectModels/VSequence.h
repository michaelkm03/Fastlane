//
//  VSequence.h
//  victorious
//
//  Created by Will Long on 9/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VStreamItem.h"

@class VComment, VNode, VPollResult, VUser, VVoteResult;

@interface VSequence : VStreamItem

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * commentCount;
@property (nonatomic, retain) NSNumber * createdBy;
@property (nonatomic, retain) NSDate * expiresAt;
@property (nonatomic, retain) NSString * gameStatus;
@property (nonatomic, retain) NSNumber * isComplete;
@property (nonatomic, retain) NSNumber * nameEmbeddedInContent;
@property (nonatomic, retain) NSNumber * parentUserId;
@property (nonatomic, retain) NSDate * releasedAt;
@property (nonatomic, retain) NSNumber * remixCount;
@property (nonatomic, retain) NSNumber * repostCount;
@property (nonatomic, retain) NSString * sequenceDescription;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSOrderedSet *comments;
@property (nonatomic, retain) NSOrderedSet *nodes;
@property (nonatomic, retain) VUser *parentUser;
@property (nonatomic, retain) NSSet *pollResults;
@property (nonatomic, retain) NSSet *remixers;
@property (nonatomic, retain) NSSet *reposters;
@property (nonatomic, retain) VUser *user;
@property (nonatomic, retain) NSSet *voteResults;
@end

@interface VSequence (CoreDataGeneratedAccessors)

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

- (void)addRemixersObject:(VUser *)value;
- (void)removeRemixersObject:(VUser *)value;
- (void)addRemixers:(NSSet *)values;
- (void)removeRemixers:(NSSet *)values;

- (void)addRepostersObject:(VUser *)value;
- (void)removeRepostersObject:(VUser *)value;
- (void)addReposters:(NSSet *)values;
- (void)removeReposters:(NSSet *)values;

- (void)addVoteResultsObject:(VVoteResult *)value;
- (void)removeVoteResultsObject:(VVoteResult *)value;
- (void)addVoteResults:(NSSet *)values;
- (void)removeVoteResults:(NSSet *)values;

@end
