//
//  VSequence.m
//  
//
//  Created by Sharif Ahmed on 7/16/15.
//
//

#import "VSequence.h"
#import "VComment.h"
#import "VImageAsset.h"
#import "VNode.h"
#import "VPollResult.h"
#import "VTracking.h"
#import "VUser.h"
#import "VVoteResult.h"


@implementation VSequence

@dynamic category;
@dynamic commentCount;
@dynamic createdBy;
@dynamic expiresAt;
@dynamic gameStatus;
@dynamic gifCount;
@dynamic hasReposted;
@dynamic isComplete;
@dynamic isLikedByMainUser;
@dynamic hasBeenRepostedByMainUser;
@dynamic isRemix;
@dynamic isRepost;
@dynamic likeCount;
@dynamic memeCount;
@dynamic nameEmbeddedInContent;
@dynamic parentUserId;
@dynamic permissionsMask;
@dynamic previewData;
@dynamic previewType;
@dynamic repostCount;
@dynamic sequenceDescription;
@dynamic adBreaks;
// TODO: Coments (and any other paginated to-many relationship) can be an unordered set now since we will always be ordering through fretch requests and pagination
@dynamic comments;
@dynamic likers;
@dynamic nodes;
@dynamic parentUser;
@dynamic pollResults;
@dynamic recentUser;
@dynamic reposters;
@dynamic tracking;
@dynamic user;
@dynamic voteResults;
@dynamic recentComments;
@dynamic isGifStyle;
@dynamic trendingTopicName;

@end
