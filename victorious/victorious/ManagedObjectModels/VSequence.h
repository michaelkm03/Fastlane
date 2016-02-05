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

@class VAdBreak, VComment, VImageAsset, VNode, VPollResult, VTracking, VUser, VVoteResult;

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
@property (nonatomic, retain, nullable) VAdBreak * adBreak;
@property (nonatomic, retain) NSOrderedSet * comments;
@property (nonatomic, retain, nullable) NSSet * likers;
@property (nonatomic, retain, nullable) NSOrderedSet * nodes;
@property (nonatomic, retain, nullable) VUser * parentUser;
@property (nonatomic, retain, nullable) NSSet * pollResults;
@property (nonatomic, retain, nullable) VUser * recentUser;
@property (nonatomic, retain) NSOrderedSet * reposters;
@property (nonatomic, retain) VUser * user;
@property (nonatomic, retain, nullable) NSSet * voteResults;
@property (nonatomic, retain, nullable) NSOrderedSet * recentComments;
@property (nonatomic, retain) NSNumber * isGifStyle;
@property (nonatomic, retain, nullable) NSString * trendingTopicName;
@property (nonatomic, retain) NSNumber *markForDeletion;

@end

NS_ASSUME_NONNULL_END
