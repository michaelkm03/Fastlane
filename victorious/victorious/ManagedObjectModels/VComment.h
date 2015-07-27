//
//  VComment.h
//  victorious
//
//  Created by Sharif Ahmed on 7/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VAsset, VNotification, VSequence, VUser, VCommentMedia;

@interface VComment : NSManagedObject

@property (nonatomic, retain) NSNumber * assetId;
@property (nonatomic, retain) NSNumber * assetOrientation;
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
@property (nonatomic, retain) NSNumber * shouldAutoplay;
@property (nonatomic, retain) VAsset *asset;
@property (nonatomic, retain) VSequence *sequence;
@property (nonatomic, retain) VUser *user;
@property (nonatomic, retain) VSequence *inStreamSequence;
@property (nonatomic, retain) NSSet *commentMedia;

@end

@interface VComment (CoreDataGeneratedAccessors)

- (void)addCommentMediaObject:(VCommentMedia *)value;
- (void)removeCommentMediaObject:(VCommentMedia *)value;
- (void)addCommentMedia:(NSSet *)values;
- (void)removeCommentMedia:(NSSet *)values;

@end
