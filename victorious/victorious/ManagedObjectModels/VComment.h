//
//  VComment.h
//  victorious
//
//  Created by Sharif Ahmed on 7/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class VMediaAttachment, VSequence, VUser;

@interface VComment : NSManagedObject

@property (nonatomic, retain, nullable) NSNumber * assetOrientation;
@property (nonatomic, retain, nullable) NSNumber * dislikes;
@property (nonatomic, retain, nullable) NSNumber * flags;
@property (nonatomic, retain, nullable) NSNumber * likes;
@property (nonatomic, retain, nullable) NSString * mediaType;
@property (nonatomic, retain, nullable) NSString * mediaUrl;
@property (nonatomic, retain, nullable) NSNumber * parentId;
@property (nonatomic, retain) NSDate * postedAt;
@property (nonatomic, retain, nullable) NSNumber * realtime;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSString * sequenceId;
@property (nonatomic, retain, nullable) NSNumber * shouldAutoplay;
@property (nonatomic, retain, nullable) NSString * text;
@property (nonatomic, retain, nullable) NSString * thumbnailUrl;
@property (nonatomic, retain, nullable) NSNumber * userId;
@property (nonatomic, retain, nullable) VSequence *inStreamSequence;

@property (nonatomic, retain, nullable) VSequence *sequence;
@property (nonatomic, retain, null_unspecified) VUser *user;
@property (nonatomic, retain, nullable) NSNumber *mediaWidth;
@property (nonatomic, retain, nullable) NSNumber *mediaHeight;
@property (nonatomic, retain, null_unspecified) NSNumber *displayOrder;
@property (nonatomic, strong) NSNumber *markedForDeletion;

@end

NS_ASSUME_NONNULL_END
