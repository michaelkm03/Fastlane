//
//  VImageAsset.h
//  victorious
//
//  Created by Patrick Lynch on 4/28/15.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VUser, VSequence;

@interface VImageAsset : NSManagedObject

@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) VUser * user;
@property (nonatomic, retain) NSSet * sequences;

@end

@interface VImageAsset (CoreDataGeneratedAccessors)

- (void)addSequencesObject:(VSequence *)values;
- (void)removeSequencesObject:(VSequence *)values;
- (void)addSequences:(NSSet *)values;
- (void)removeSequences:(NSSet *)values;

@end
