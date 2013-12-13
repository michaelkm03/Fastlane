//
//  VUser.h
//  victoriOS
//
//  Created by David Keegan on 12/13/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VComment, VStatSequence;

@interface VUser : NSManagedObject

@property (nonatomic, retain) NSString * accessLevel;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSDate * tokenUpdatedAt;
@property (nonatomic, retain) VComment *comments;
@property (nonatomic, retain) NSSet *statSequences;
@end

@interface VUser (CoreDataGeneratedAccessors)

- (void)addStatSequencesObject:(VStatSequence *)value;
- (void)removeStatSequencesObject:(VStatSequence *)value;
- (void)addStatSequences:(NSSet *)values;
- (void)removeStatSequences:(NSSet *)values;

@end
