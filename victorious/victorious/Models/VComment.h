//
//  VComment.h
//  victorious
//
//  Created by Lawrence Leach on 8/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VAsset, VCommentFilter, VNotification, VSequence, VUser;

@interface VComment : NSManagedObject

@property (nonatomic, retain) NSNumber * assetId;
@property (nonatomic, retain) NSNumber * dislikes;
@property (nonatomic, retain) NSNumber * display_order;
@property (nonatomic, retain) NSNumber * flags;
@property (nonatomic, retain) NSNumber * likes;
@property (nonatomic, retain) NSString * mediaType;
@property (nonatomic, retain) NSString * mediaUrl;
@property (nonatomic, retain) NSNumber * parentId;
@property (nonatomic, retain) NSDate * postedAt;
@property (nonatomic, retain) NSNumber * realtime;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSNumber * sequenceId;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * thumbnailUrl;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) VAsset *asset;
@property (nonatomic, retain) NSSet *filters;
@property (nonatomic, retain) VSequence *sequence;
@property (nonatomic, retain) VUser *user;
@property (nonatomic, retain) VNotification *notification;
@end

@interface VComment (CoreDataGeneratedAccessors)

- (void)addFiltersObject:(VCommentFilter *)value;
- (void)removeFiltersObject:(VCommentFilter *)value;
- (void)addFilters:(NSSet *)values;
- (void)removeFilters:(NSSet *)values;

@end
