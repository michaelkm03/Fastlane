//
//  VComment.h
//  victoriOS
//
//  Created by David Keegan on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VSequence;

@interface VComment : NSManagedObject

@property (nonatomic, retain) NSNumber * dislikes;
@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSNumber * flags;
@property (nonatomic, retain) NSNumber * commentId;
@property (nonatomic, retain) NSNumber * likes;
@property (nonatomic, retain) NSString * mediaType;
@property (nonatomic, retain) id mediaUrl;
@property (nonatomic, retain) NSNumber * parentId;
@property (nonatomic, retain) NSDate * postedAt;
@property (nonatomic, retain) NSNumber * sequenceId;
@property (nonatomic, retain) NSNumber * shares;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) VSequence *sequence;

@end
