//
//  VUser.h
//  victorious
//
//  Created by Sharif Ahmed on 6/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VComment, VConversation, VHashtag, VImageAsset, VMessage, VNotification, VNotificationSettings, VPollResult, VSequence, VUser, VContent;

@interface VUser : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * isBlockedByMainUser;
@property (nonatomic, retain) NSNumber * isCreator;
@property (nonatomic, retain) NSNumber * isDirectMessagingDisabled;
@property (nonatomic, retain) NSNumber * isFollowedByMainUser;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSNumber * levelProgressPercentage;
@property (nonatomic, retain) NSNumber * levelProgressPoints;
@property (nonatomic, retain) NSString * tier;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numberOfFollowers;
@property (nonatomic, retain) NSNumber * numberOfFollowing;
@property (nonatomic, retain) NSNumber * likesGiven;
@property (nonatomic, retain) NSNumber * likesReceived;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSNumber * completedProfile;
@property (nonatomic, retain) NSString * tagline;
@property (nonatomic, retain) NSString * token;
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
@property (nonatomic, retain) NSNumber * isVIPSubscriber; //< Transient (so that validation only comes from the backend and is never read from disk)
@property (nonatomic, retain) NSDate * vipEndDate; //< Transient
@property (nonatomic, retain) id achievementsUnlocked;
@property (nonatomic, retain) NSString * avatarBadgeType;
@property (nonatomic, retain) NSSet<VContent *> *content;

@end
