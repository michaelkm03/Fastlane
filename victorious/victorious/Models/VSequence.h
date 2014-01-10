//
//  VSequence.h
//  victorious
//
//  Created by Will Long on 1/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VComment, VNode, VUser;

@interface VSequence : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * display_order;
@property (nonatomic, retain) NSString * gameStatus;
@property (nonatomic, retain) NSNumber * isComplete;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id previewImage;
@property (nonatomic, retain) NSDate * releasedAt;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSString * sequenceDescription;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSNumber * createdBy;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *nodes;
@property (nonatomic, retain) VUser *user;
@end

@interface VSequence (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(VComment *)value;
- (void)removeCommentsObject:(VComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addNodesObject:(VNode *)value;
- (void)removeNodesObject:(VNode *)value;
- (void)addNodes:(NSSet *)values;
- (void)removeNodes:(NSSet *)values;

@end
