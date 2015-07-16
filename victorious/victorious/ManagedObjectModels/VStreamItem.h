//
//  VStreamItem.h
//  victorious
//
//  Created by Sharif Ahmed on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VEditorializationItem, VStream;

@interface VStreamItem : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id previewImagesObject;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) NSString * streamContentType;
@property (nonatomic, retain) NSString * streamId;
@property (nonatomic, retain) NSString * headline;
@property (nonatomic, retain) NSSet *editorializations;
@property (nonatomic, retain) NSSet *marquees;
@property (nonatomic, retain) NSSet *streams;
@end

@interface VStreamItem (CoreDataGeneratedAccessors)

- (void)addEditorializationsObject:(VEditorializationItem *)value;
- (void)removeEditorializationsObject:(VEditorializationItem *)value;
- (void)addEditorializations:(NSSet *)values;
- (void)removeEditorializations:(NSSet *)values;

- (void)addMarqueesObject:(VStream *)value;
- (void)removeMarqueesObject:(VStream *)value;
- (void)addMarquees:(NSSet *)values;
- (void)removeMarquees:(NSSet *)values;

- (void)addStreamsObject:(VStream *)value;
- (void)removeStreamsObject:(VStream *)value;
- (void)addStreams:(NSSet *)values;
- (void)removeStreams:(NSSet *)values;

@end
