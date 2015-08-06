//
//  VStreamItem.h
//  victorious
//
//  Created by Sharif Ahmed on 8/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class VEditorializationItem, VStream;

@interface VStreamItem : NSManagedObject

@property (nonatomic, retain) NSString * __nullable headline;
@property (nonatomic, retain) NSString * __nullable name;
@property (nonatomic, retain) id __nullable previewImagesObject;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) NSString * __nullable streamContentType;
@property (nonatomic, retain) NSString * __nullable streamId;
@property (nonatomic, retain) NSString * __nullable subType;
@property (nonatomic, retain) NSString * __nullable streamType;
@property (nonatomic, retain) NSSet * __nullable editorializations;
@property (nonatomic, retain) NSSet * __nullable marquees;
@property (nonatomic, retain) NSSet * __nullable streams;
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

NS_ASSUME_NONNULL_END

@end
