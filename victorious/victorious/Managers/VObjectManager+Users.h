//
//  VObjectManager+Users.h
//  victorious
//
//  Created by Will Long on 1/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

@interface VObjectManager (Users)

- (RKManagedObjectRequestOperation *)fetchUser:(NSNumber*)userId
                              withSuccessBlock:(SuccessBlock)success
                                     failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)fetchUser:(NSNumber*)userId
                         forRelationshipObject:(id)relationshipObject
                              withSuccessBlock:(SuccessBlock)success
                                     failBlock:(FailBlock)fail;
@end
