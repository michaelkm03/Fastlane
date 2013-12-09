//
//  VUser.h
//  victoriOS
//
//  Created by David Keegan on 12/9/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VStatSequence;

@interface VUser : NSManagedObject

@property (nonatomic, retain) NSString * access_level;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSDate * token_updated_at;
@property (nonatomic, retain) NSSet *stat_sequences;
@end

@interface VUser (CoreDataGeneratedAccessors)

- (void)addStat_sequencesObject:(VStatSequence *)value;
- (void)removeStat_sequencesObject:(VStatSequence *)value;
- (void)addStat_sequences:(NSSet *)values;
- (void)removeStat_sequences:(NSSet *)values;

@end
