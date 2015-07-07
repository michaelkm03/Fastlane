//
//  VStreamItem.h
//  
//
//  Created by Sharif Ahmed on 7/6/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VStream;

@interface VStreamItem : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id previewImagesObject;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) NSString * streamContentType;
@property (nonatomic, retain) NSString * headline;
@property (nonatomic, retain) NSSet *marquees;
@property (nonatomic, retain) NSSet *streams;
@end

@interface VStreamItem (CoreDataGeneratedAccessors)

- (void)addMarqueesObject:(VStream *)value;
- (void)removeMarqueesObject:(VStream *)value;
- (void)addMarquees:(NSSet *)values;
- (void)removeMarquees:(NSSet *)values;

- (void)addStreamsObject:(VStream *)value;
- (void)removeStreamsObject:(VStream *)value;
- (void)addStreams:(NSSet *)values;
- (void)removeStreams:(NSSet *)values;

@end
