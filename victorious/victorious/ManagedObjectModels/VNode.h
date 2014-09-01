//
//  VNode.h
//  victorious
//
//  Created by Will Long on 8/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VAsset, VInteraction, VNodeAction, VSequence;

@interface VNode : NSManagedObject

@property (nonatomic, retain) NSNumber * display_order;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSString * shareUrlPath;
@property (nonatomic, retain) NSSet *assets;
@property (nonatomic, retain) NSSet *interactions;
@property (nonatomic, retain) VNodeAction *nodeAction;
@property (nonatomic, retain) VSequence *sequence;
@end

@interface VNode (CoreDataGeneratedAccessors)

- (void)addAssetsObject:(VAsset *)value;
- (void)removeAssetsObject:(VAsset *)value;
- (void)addAssets:(NSSet *)values;
- (void)removeAssets:(NSSet *)values;

- (void)addInteractionsObject:(VInteraction *)value;
- (void)removeInteractionsObject:(VInteraction *)value;
- (void)addInteractions:(NSSet *)values;
- (void)removeInteractions:(NSSet *)values;

@end
