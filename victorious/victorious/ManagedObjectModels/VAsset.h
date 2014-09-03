//
//  VAsset.h
//  victorious
//
//  Created by Lawrence Leach on 9/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VComment, VNode;

@interface VAsset : NSManagedObject

@property (nonatomic, retain) NSString * data;
@property (nonatomic, retain) NSNumber * display_order;
@property (nonatomic, retain) NSNumber * nodeId;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSNumber * loop;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) VNode *node;
@end

@interface VAsset (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(VComment *)value;
- (void)removeCommentsObject:(VComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
