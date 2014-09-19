//
//  VDirectoryItem.h
//  victorious
//
//  Created by Will Long on 9/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VDirectory;

@interface VDirectoryItem : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id previewImagesObject;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSSet *directories;
@end

@interface VDirectoryItem (CoreDataGeneratedAccessors)

- (void)addDirectoriesObject:(VDirectory *)value;
- (void)removeDirectoriesObject:(VDirectory *)value;
- (void)addDirectories:(NSSet *)values;
- (void)removeDirectories:(NSSet *)values;

@end
