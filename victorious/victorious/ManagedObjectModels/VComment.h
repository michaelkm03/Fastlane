//
//  VComment.h
//  victorious
//
//  Created by Will Long on 9/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VAsset, VNotification, VSequence, VUser;

@interface VComment : NSManagedObject

@property (nonatomic, retain) NSNumber * assetId;
@property (nonatomic, retain) NSNumber * dislikes;
@property (nonatomic, retain) NSNumber * flags;
@property (nonatomic, retain) NSNumber * likes;
@property (nonatomic, retain) NSString * mediaType;
@property (nonatomic, retain) NSString * mediaUrl;
@property (nonatomic, retain) NSNumber * parentId;
@property (nonatomic, retain) NSDate * postedAt;
@property (nonatomic, retain) NSNumber * realtime;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSString * sequenceId;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * thumbnailUrl;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * assetOrientation;
@property (nonatomic, retain) VAsset *asset;
@property (nonatomic, retain) VNotification *notification;
@property (nonatomic, retain) VSequence *sequence;
@property (nonatomic, retain) VUser *user;

@end
