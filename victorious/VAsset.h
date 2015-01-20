//
//  VAsset.h
//  victorious
//
//  Created by Michael Sena on 1/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VComment, VNode;

@interface VAsset : NSManagedObject

@property (nonatomic, retain) NSString *data;
@property (nonatomic, retain) NSNumber *loop;
@property (nonatomic, retain) NSNumber *nodeId;
@property (nonatomic, retain) NSNumber *remoteId;
@property (nonatomic, retain) NSNumber *speed;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *mimeType;
@property (nonatomic, retain) NSOrderedSet *comments;
@property (nonatomic, retain) VNode *node;

@end

@interface VAsset (CoreDataGeneratedAccessors)

- (void)insertObject:(VComment *)value inCommentsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCommentsAtIndex:(NSUInteger)idx;
- (void)insertComments:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCommentsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCommentsAtIndex:(NSUInteger)idx withObject:(VComment *)value;
- (void)replaceCommentsAtIndexes:(NSIndexSet *)indexes withComments:(NSArray *)values;
- (void)addCommentsObject:(VComment *)value;
- (void)removeCommentsObject:(VComment *)value;
- (void)addComments:(NSOrderedSet *)values;
- (void)removeComments:(NSOrderedSet *)values;

@end
