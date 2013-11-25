//
//  Sequence.h
//  victoriOS
//
//  Created by Will Long on 11/25/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Node;

@interface Sequence : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * display_order;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * preview_image;
@property (nonatomic, retain) NSString * sequence_description;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *nodes;
@end

@interface Sequence (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(NSManagedObject *)value;
- (void)removeCommentsObject:(NSManagedObject *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addNodesObject:(Node *)value;
- (void)removeNodesObject:(Node *)value;
- (void)addNodes:(NSSet *)values;
- (void)removeNodes:(NSSet *)values;

@end
