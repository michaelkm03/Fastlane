//
//  VDirectory.h
//  victorious
//
//  Created by Will Long on 9/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VDirectoryItem.h"

@class VDirectoryItem;

@interface VDirectory : VDirectoryItem

@property (nonatomic, retain) NSSet *directoryItems;
@end

@interface VDirectory (CoreDataGeneratedAccessors)

- (void)addDirectoryItemsObject:(VDirectoryItem *)value;
- (void)removeDirectoryItemsObject:(VDirectoryItem *)value;
- (void)addDirectoryItems:(NSSet *)values;
- (void)removeDirectoryItems:(NSSet *)values;

@end
