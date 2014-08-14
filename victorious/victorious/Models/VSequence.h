//
//  VSequence.h
//  victorious
//
//  Created by Will Long on 8/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VComment, VNode, VPollResult, VSequenceFilter, VUser, VVoteResult;

@interface VSequence : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * commentCount;
@property (nonatomic, retain) NSNumber * createdBy;
@property (nonatomic, retain) NSNumber * display_order;
@property (nonatomic, retain) NSDate * expiresAt;
@property (nonatomic, retain) NSString * gameStatus;
@property (nonatomic, retain) NSNumber * isComplete;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * nameEmbeddedInContent;
@property (nonatomic, retain) NSNumber * parentUserId;
@property (nonatomic, retain) id previewImage;
@property (nonatomic, retain) NSDate * releasedAt;
@property (nonatomic, retain) NSNumber * remixCount;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSNumber * repostCount;
@property (nonatomic, retain) NSString * sequenceDescription;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * shareUrlPath;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *filters;
@property (nonatomic, retain) NSSet *nodes;
@property (nonatomic, retain) VUser *parentUser;
@property (nonatomic, retain) NSSet *pollResults;
@property (nonatomic, retain) NSSet *remixers;
@property (nonatomic, retain) NSSet *reposters;
@property (nonatomic, retain) VUser *user;
@property (nonatomic, retain) NSSet *voteResults;
@end

@interface VSequence (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(VComment *)value;
- (void)removeCommentsObject:(VComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addFiltersObject:(VSequenceFilter *)value;
- (void)removeFiltersObject:(VSequenceFilter *)value;
- (void)addFilters:(NSSet *)values;
- (void)removeFilters:(NSSet *)values;

- (void)addNodesObject:(VNode *)value;
- (void)removeNodesObject:(VNode *)value;
- (void)addNodes:(NSSet *)values;
- (void)removeNodes:(NSSet *)values;

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
