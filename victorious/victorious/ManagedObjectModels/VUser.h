//
//  VUser.h
//  victorious
//
//  Created by Sharif Ahmed on 6/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VComment, VConversation, VHashtag, VImageAsset, VMessage, VNotification, VNotificationSettings, VPollResult, VSequence, VUser;

typedef enum : NSUInteger {
    AvatarBadgeTypeVerified,
    AvatarBadgeTypeNone
} AvatarBadgeType;

@interface VUser : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * isBlockedByMainUser;
@property (nonatomic, retain) NSNumber * isCreator;
@property (nonatomic, retain) NSNumber * isDirectMessagingDisabled;
@property (nonatomic, retain) NSNumber * isFollowedByMainUser;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSNumber * levelProgressPercentage;
@property (nonatomic, retain) NSNumber * levelProgressPoints;
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
@property (nonatomic, retain) NSOrderedSet *conversations;
@property (nonatomic, retain) NSOrderedSet *followers;
@property (nonatomic, retain) NSOrderedSet *following;
@property (nonatomic, retain) NSOrderedSet *followedHashtags;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSSet *notifications;
@property (nonatomic, retain) NSSet *pollResults;
@property (nonatomic, retain) NSOrderedSet *recentSequences;
@property (nonatomic, retain) NSSet *previewAssets;
@property (nonatomic, retain) NSSet *repostedSequences;
@property (nonatomic, retain) NSNumber *maxUploadDuration;
@property (nonatomic, retain) NSNumber *loginType;
@property (nonatomic, retain) VNotificationSettings *notificationSettings;
@property (nonatomic, retain) NSOrderedSet *likedSequences;
@property (nonatomic, retain) NSString * accountIdentifier;  //< Transient
@property (nonatomic, retain) NSNumber * isNewUser; //< Transient
@property (nonatomic, retain) NSNumber * isVIPSubscriber;
@property (nonatomic, retain) NSDate * vipSubscribeDate;
@property (nonatomic, retain) NSString * avatarBadgeType;

- (AvatarBadgeType)badgeType;

@end
