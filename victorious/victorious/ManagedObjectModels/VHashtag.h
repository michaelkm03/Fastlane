//
//  VHashtag.h
//  victorious
//
//  Created by Lawrence Leach on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VUser;

@interface VHashtag : NSManagedObject

@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSSet *user;
@end

@interface VHashtag (CoreDataGeneratedAccessors)

- (void)addUserObject:(VUser *)value;
- (void)removeUserObject:(VUser *)value;
- (void)addUser:(NSSet *)values;
- (void)removeUser:(NSSet *)values;

@end
