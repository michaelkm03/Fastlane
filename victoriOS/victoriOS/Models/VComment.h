//
//  VComment.h
//  victoriOS
//
//  Created by David Keegan on 12/9/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VSequence;

@interface VComment : NSManagedObject

@property (nonatomic, retain) NSNumber * dislikes;
@property (nonatomic, retain) NSNumber * display_order;
@property (nonatomic, retain) NSNumber * flags;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * likes;
@property (nonatomic, retain) NSString * media_type;
@property (nonatomic, retain) id media_url;
@property (nonatomic, retain) NSNumber * parent_id;
@property (nonatomic, retain) NSDate * posted_at;
@property (nonatomic, retain) NSNumber * sequence_id;
@property (nonatomic, retain) NSNumber * shares;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) VSequence *sequence;

@end
