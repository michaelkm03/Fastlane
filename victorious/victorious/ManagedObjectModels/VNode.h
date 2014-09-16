//
//  VNode.h
//  victorious
//
//  Created by Will Long on 9/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VAsset, VInteraction, VNodeAction, VSequence;

@interface VNode : NSManagedObject

@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSString * shareUrlPath;
@property (nonatomic, retain) NSOrderedSet *assets;
@property (nonatomic, retain) NSSet *interactions;
@property (nonatomic, retain) VNodeAction *nodeAction;
@property (nonatomic, retain) VSequence *sequence;
@end

@interface VNode (CoreDataGeneratedAccessors)

- (void)insertObject:(VAsset *)value inAssetsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAssetsAtIndex:(NSUInteger)idx;
- (void)insertAssets:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAssetsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAssetsAtIndex:(NSUInteger)idx withObject:(VAsset *)value;
- (void)replaceAssetsAtIndexes:(NSIndexSet *)indexes withAssets:(NSArray *)values;
- (void)addAssetsObject:(VAsset *)value;
- (void)removeAssetsObject:(VAsset *)value;
- (void)addAssets:(NSOrderedSet *)values;
- (void)removeAssets:(NSOrderedSet *)values;
- (void)addInteractionsObject:(VInteraction *)value;
- (void)removeInteractionsObject:(VInteraction *)value;
- (void)addInteractions:(NSSet *)values;
- (void)removeInteractions:(NSSet *)values;

@end
