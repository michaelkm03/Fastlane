//
//  User.h
//  victoriOS
//
//  Created by Will Long on 12/4/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StatSequence;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * access_level;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSDate * token_updated_at;
@property (nonatomic, retain) NSSet *stat_sequences;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addStat_sequencesObject:(StatSequence *)value;
- (void)removeStat_sequencesObject:(StatSequence *)value;
- (void)addStat_sequences:(NSSet *)values;
- (void)removeStat_sequences:(NSSet *)values;

@end
