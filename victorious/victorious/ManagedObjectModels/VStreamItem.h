//
//  VStreamItem.h
//  victorious
//
//  Created by Will Long on 9/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VStream;

@interface VStreamItem : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id previewImagesObject;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) NSString * streamContentType;
@property (nonatomic, retain) NSSet *streams;
@end

@interface VStreamItem (CoreDataGeneratedAccessors)

- (void)addStreamsObject:(VStream *)value;
- (void)removeStreamsObject:(VStream *)value;
- (void)addStreams:(NSSet *)values;
- (void)removeStreams:(NSSet *)values;

@end
