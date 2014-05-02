//
//  VComment.h
//  victorious
//
//  Created by Will Long on 5/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VSequence, VUser;

@interface VComment : NSManagedObject

@property (nonatomic, retain) NSNumber * dislikes;
@property (nonatomic, retain) NSNumber * display_order;
@property (nonatomic, retain) NSNumber * flags;
@property (nonatomic, retain) NSNumber * likes;
@property (nonatomic, retain) NSString * mediaType;
@property (nonatomic, retain) id mediaUrl;
@property (nonatomic, retain) NSNumber * parentId;
@property (nonatomic, retain) NSDate * postedAt;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSNumber * sequenceId;
@property (nonatomic, retain) NSNumber * shares;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * thumbnailUrl;
@property (nonatomic, retain) VSequence *sequence;
@property (nonatomic, retain) VUser *user;

@end
